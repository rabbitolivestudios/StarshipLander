import SpriteKit
import SwiftUI
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Properties (accessible to extensions)
    var gameState: GameState
    var rocket: SKNode!
    var flame: SKEmitterNode?
    var leftFlame: SKEmitterNode?
    var rightFlame: SKEmitterNode?
    var platforms: [SKShapeNode] = []
    var ground: SKShapeNode!
    var terrain: SKShapeNode!
    var hasStarted = false
    var lastUpdateTime: TimeInterval = 0

    // Sound nodes
    var thrustSound: SKAudioNode?
    var isThrustSoundPlaying = false
    var wasRotatingLeft = false
    var wasRotatingRight = false

    // Accelerometer
    private let motionManager = CMMotionManager()
    private var accelerometerTilt: CGFloat = 0

    // Velocity tracking
    var maxDescentSpeed: CGFloat = 0
    var recentVelocities: [CGFloat] = []
    let velocityHistorySize = 30

    // Campaign: wind state
    private var windForce: CGFloat = 0
    private var windTime: TimeInterval = 0

    // Campaign: Jupiter gust state
    private var gustActive = false
    private var gustTimer: TimeInterval = 0
    private var gustDirection: CGFloat = 1
    private var gustCalmDuration: TimeInterval = 3.0
    private var gustActiveDuration: TimeInterval = 2.0

    // Campaign: moving platforms (per-platform state)
    private var platformDirections: [CGFloat] = [1, 1, 1]
    private var platformOriginalPositions: [CGPoint] = []

    // Physics categories
    let rocketCategory: UInt32 = 0x1 << 0
    let platformCategory: UInt32 = 0x1 << 1
    let groundCategory: UInt32 = 0x1 << 2

    // Landing thresholds
    static let maxSafeVerticalSpeed: CGFloat = 40.0
    static let maxSafeHorizontalSpeed: CGFloat = 25.0
    static let maxSafeRotation: CGFloat = 0.05
    static let maxSafeApproachSpeed: CGFloat = 80.0

    // MARK: - Init

    init(gameState: GameState) {
        self.gameState = gameState
        super.init(size: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        backgroundColor = .clear

        // Set gravity based on mode
        let gravity: CGFloat
        if gameState.currentMode == .campaign,
           let level = LevelDefinition.level(for: gameState.currentLevelId) {
            gravity = level.gravity
        } else {
            gravity = -2.0  // Classic mode default
        }
        physicsWorld.gravity = CGVector(dx: 0, dy: gravity)
        physicsWorld.contactDelegate = self

        setupScene()
        setupAccelerometer()
    }

    override func willMove(from view: SKView) {
        motionManager.stopAccelerometerUpdates()
    }

    private func setupAccelerometer() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 1.0 / 60.0
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
                guard let self = self, let data = data else { return }
                self.accelerometerTilt = CGFloat(data.acceleration.x)
            }
        }
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        if size.width > 0 && size.height > 0 && !gameState.gameOver {
            let sizeChanged = abs(oldSize.width - size.width) > 1 || abs(oldSize.height - size.height) > 1
            if oldSize == .zero || sizeChanged {
                removeAllChildren()
                setupScene()
            }
        }
    }

    // MARK: - Setup

    func setupScene() {
        guard size.width > 0 && size.height > 0 else { return }

        createStarfield()
        createCelestialBody()
        createTerrain()
        createGround()
        createPlatforms()
        platformOriginalPositions = platforms.map { $0.position }
        createRocket()

        hasStarted = false
        gameState.gameOver = false
        gameState.landed = false
        gameState.fuel = 100
        gameState.score = 0
        gameState.verticalVelocity = 0
        gameState.horizontalVelocity = 0
        gameState.rotation = 0
        gameState.landedPlatform = nil
        gameState.landingMessage = ""
        gameState.crashNudge = ""
        gameState.starsEarned = 0

        maxDescentSpeed = 0
        recentVelocities = []

        stopThrustSound()
        wasRotatingLeft = false
        wasRotatingRight = false

        // Set gravity for campaign levels
        if gameState.currentMode == .campaign,
           let level = LevelDefinition.level(for: gameState.currentLevelId) {
            physicsWorld.gravity = CGVector(dx: 0, dy: level.gravity)

            // Start level-specific effects
            startLevelEffects(level)
        } else {
            physicsWorld.gravity = CGVector(dx: 0, dy: -2.0)
        }
    }

    func startGame() {
        guard rocket != nil else { return }
        if !hasStarted {
            hasStarted = true
            rocket.physicsBody?.isDynamic = true
        }
    }

    // MARK: - Level-Specific Effects

    private func startLevelEffects(_ level: LevelDefinition) {
        switch level.specialMechanic {
        case .lightWind:
            windForce = CGFloat.random(in: -1.5...1.5)
            createWindParticles(intensity: .light)
        case .heavyTurbulence:
            windForce = 0  // Will oscillate in update
            createWindParticles(intensity: .heavy)
        case .extremeWind:
            windForce = 0  // Will oscillate in update
            createWindParticles(intensity: .extreme)
        case .heatShimmer:
            createHeatShimmer()
        case .volcanicEruptions:
            createVolcanicEruption()
        case .denseAtmosphere:
            rocket.physicsBody?.linearDamping = 0.5
            createAtmosphereHaze()
        case .iceSurface:
            rocket.physicsBody?.friction = 0.01
            createIceShimmer()
        default:
            break
        }
    }

    // MARK: - Update Loop

    override func update(_ currentTime: TimeInterval) {
        guard !gameState.gameOver, rocket != nil else { return }

        // Auto-start
        if !hasStarted && (gameState.isThrusting || gameState.isRotatingLeft || gameState.isRotatingRight) {
            hasStarted = true
            rocket.physicsBody?.isDynamic = true
        }

        guard hasStarted else { return }

        let dt = lastUpdateTime > 0 ? currentTime - lastUpdateTime : 0
        lastUpdateTime = currentTime

        // Check for reset
        if gameState.shouldReset {
            gameState.shouldReset = false
            removeAllChildren()
            removeAction(forKey: "heatShimmer")
            removeAction(forKey: "volcanicEruption")
            removeAction(forKey: "windParticles")
            removeAction(forKey: "atmosphereHaze")
            removeAction(forKey: "iceShimmer")
            lastUpdateTime = 0
            setupScene()
            return
        }

        // Track velocity
        if let velocity = rocket.physicsBody?.velocity {
            let currentVerticalSpeed = max(0, -velocity.dy)

            if currentVerticalSpeed > maxDescentSpeed {
                maxDescentSpeed = currentVerticalSpeed
            }

            recentVelocities.append(currentVerticalSpeed)
            if recentVelocities.count > velocityHistorySize {
                recentVelocities.removeFirst()
            }

            DispatchQueue.main.async {
                self.gameState.verticalVelocity = currentVerticalSpeed
                self.gameState.horizontalVelocity = abs(velocity.dx)
                self.gameState.rotation = abs(self.rocket.zRotation)
            }
        }

        // Apply main thrust
        if gameState.isThrusting && gameState.fuel > 0 {
            guard var velocity = rocket.physicsBody?.velocity else { return }

            // Per-level thrust in campaign, fixed 12.0 in classic
            let thrustPower: CGFloat
            if gameState.currentMode == .campaign,
               let level = LevelDefinition.level(for: gameState.currentLevelId) {
                thrustPower = level.thrustPower
            } else {
                thrustPower = 12.0
            }
            let angle = rocket.zRotation + .pi / 2
            let dx = cos(angle) * thrustPower
            let dy = sin(angle) * thrustPower

            velocity.dx += dx
            velocity.dy += dy

            // Proportional thrust vectoring — lateral force scales with tilt angle
            // sin(rotation) naturally gives 0 when upright, increases with tilt
            // 0.15 factor: at 30° tilt, ~7.5% of thrust power goes lateral
            let lateralFactor: CGFloat = 0.15
            let lateralForce = sin(rocket.zRotation) * thrustPower * lateralFactor
            velocity.dx += lateralForce

            rocket.physicsBody?.velocity = velocity

            if flame == nil && rocket.children.filter({ $0.position.y == -42 }).isEmpty {
                createMainFlame()
            }

            startThrustSound()
            HapticManager.shared.thrustPulse()

            DispatchQueue.main.async {
                self.gameState.fuel = max(0, self.gameState.fuel - 0.3)
            }
        } else {
            removeFlames()
            stopThrustSound()
        }

        // Apply rotation
        if gameState.fuel > 0 {
            let rotationPower: CGFloat = 0.04  // Increased from 0.025

            if gameState.useAccelerometer {
                let deadZone: CGFloat = 0.1
                let sensitivity: CGFloat = 0.06

                if abs(accelerometerTilt) > deadZone {
                    let tiltAmount = accelerometerTilt - (accelerometerTilt > 0 ? deadZone : -deadZone)
                    rocket.physicsBody?.angularVelocity += tiltAmount * sensitivity

                    let fuelConsumption = abs(tiltAmount) * 0.04
                    DispatchQueue.main.async {
                        self.gameState.fuel = max(0, self.gameState.fuel - fuelConsumption)
                    }
                }
            } else {
                if gameState.isRotatingLeft {
                    if !wasRotatingLeft {
                        playRotateSound()
                        HapticManager.shared.rotationStart()
                    }
                    rocket.physicsBody?.angularVelocity += rotationPower
                    DispatchQueue.main.async {
                        self.gameState.fuel = max(0, self.gameState.fuel - 0.08)
                    }
                }

                if gameState.isRotatingRight {
                    if !wasRotatingRight {
                        playRotateSound()
                        HapticManager.shared.rotationStart()
                    }
                    rocket.physicsBody?.angularVelocity -= rotationPower
                    DispatchQueue.main.async {
                        self.gameState.fuel = max(0, self.gameState.fuel - 0.08)
                    }
                }
            }
        }

        wasRotatingLeft = gameState.isRotatingLeft
        wasRotatingRight = gameState.isRotatingRight

        // Apply campaign special mechanics
        applyCampaignMechanics(dt: dt, currentTime: currentTime)

        // Screen wrap
        if rocket.position.x < -20 {
            rocket.position.x = size.width + 20
        } else if rocket.position.x > size.width + 20 {
            rocket.position.x = -20
        }

        // Check if rocket fell off screen
        if rocket.position.y < -100 {
            crashRocket()
        }
    }

    // MARK: - Campaign Mechanics

    private func applyCampaignMechanics(dt: TimeInterval, currentTime: TimeInterval) {
        guard gameState.currentMode == .campaign,
              let level = LevelDefinition.level(for: gameState.currentLevelId) else { return }

        switch level.specialMechanic {
        case .lightWind:
            // Constant light wind
            rocket.physicsBody?.applyForce(CGVector(dx: windForce, dy: 0))

        case .heavyTurbulence:
            // Venus: vertical updrafts/downdrafts instead of horizontal wind
            windTime += dt
            let verticalForce = CGFloat(sin(windTime * 1.5)) * 4.0 + CGFloat.random(in: -0.5...0.5)
            rocket.physicsBody?.applyForce(CGVector(dx: 0, dy: verticalForce))

        case .extremeWind:
            // Jupiter: sudden gusts with calm windows
            gustTimer += dt
            if gustActive {
                let gustForce: CGFloat = 15.0 * gustDirection + CGFloat.random(in: -2...2)
                rocket.physicsBody?.applyForce(CGVector(dx: gustForce, dy: 0))
                if gustTimer >= gustActiveDuration {
                    gustActive = false
                    gustTimer = 0
                    gustCalmDuration = Double.random(in: 2.5...4.0)
                }
            } else {
                rocket.physicsBody?.applyForce(CGVector(dx: CGFloat.random(in: -1...1), dy: 0))
                if gustTimer >= gustCalmDuration {
                    gustActive = true
                    gustTimer = 0
                    gustDirection = Bool.random() ? 1.0 : -1.0
                    gustActiveDuration = Double.random(in: 1.5...2.5)
                }
            }

        case .heatShimmer:
            // Mercury: heat interference — random thrust perturbation when thrusting
            if gameState.isThrusting && gameState.fuel > 0 {
                let dx = CGFloat.random(in: -1.5...1.5)
                let dy = CGFloat.random(in: -0.8...0.8)
                rocket.physicsBody?.velocity.dx += dx
                rocket.physicsBody?.velocity.dy += dy
            }

        case .movingPlatform:
            // Platform A (left):   slow vertical bob only
            // Platform B (center): horizontal sway, constrained to center zone
            // Platform C (right):  horizontal + vertical bob, constrained to right zone
            let speeds: [CGFloat] = [12, 25, 30]
            let hRanges: [CGFloat] = [0, 30, 20]    // horizontal displacement limit
            let vRange: CGFloat = 15                  // vertical displacement limit

            // Compute safe horizontal bounds to prevent overlap
            let widths: [CGFloat] = platforms.enumerated().map { (i, _) in
                LandingPlatform.allCases[i].width
            }

            for (i, plat) in platforms.enumerated() {
                guard i < platformOriginalPositions.count && i < platformDirections.count else { continue }
                let origin = platformOriginalPositions[i]
                let speed = speeds[min(i, speeds.count - 1)]
                let hRange = hRanges[min(i, hRanges.count - 1)]

                if i == 0 {
                    // Platform A: gentle vertical bob only
                    plat.position.y += platformDirections[i] * speed * CGFloat(dt)
                    if abs(plat.position.y - origin.y) > vRange {
                        platformDirections[i] *= -1
                    }
                } else if i == 1 {
                    // Platform B: horizontal sway within center zone
                    plat.position.x += platformDirections[i] * speed * CGFloat(dt)
                    if abs(plat.position.x - origin.x) > hRange {
                        platformDirections[i] *= -1
                    }
                    // Clamp to avoid overlapping neighbors
                    let leftEdge = platforms[0].position.x + widths[0] / 2 + widths[1] / 2 + 10
                    let rightEdge = platforms[2].position.x - widths[2] / 2 - widths[1] / 2 - 10
                    plat.position.x = max(leftEdge, min(rightEdge, plat.position.x))
                } else {
                    // Platform C: horizontal + vertical bob
                    plat.position.x += platformDirections[i] * speed * CGFloat(dt)
                    if abs(plat.position.x - origin.x) > hRange {
                        platformDirections[i] *= -1
                    }
                    plat.position.y = origin.y + CGFloat(sin(currentTime * 1.2)) * vRange
                    // Clamp to avoid overlapping center platform
                    let leftEdge = platforms[1].position.x + widths[1] / 2 + widths[2] / 2 + 10
                    plat.position.x = max(leftEdge, plat.position.x)
                }
            }

        default:
            break
        }
    }

    // MARK: - Collision

    func didBegin(_ contact: SKPhysicsContact) {
        guard !gameState.gameOver else { return }

        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if collision == rocketCategory | platformCategory {
            // Determine which platform node was contacted
            let platformNode: SKNode?
            if contact.bodyA.categoryBitMask == platformCategory {
                platformNode = contact.bodyA.node
            } else {
                platformNode = contact.bodyB.node
            }
            checkLanding(contactNode: platformNode)
        } else if collision == rocketCategory | groundCategory {
            crashRocket()
        }
    }

    private func checkLanding(contactNode: SKNode?) {
        guard let velocity = rocket.physicsBody?.velocity else { return }

        let verticalSpeed = max(0, -velocity.dy)
        let horizontalSpeed = abs(velocity.dx)
        let rotation = abs(rocket.zRotation)

        let approachSpeed = recentVelocities.isEmpty ? verticalSpeed : recentVelocities.reduce(0, +) / CGFloat(recentVelocities.count)

        DispatchQueue.main.async {
            self.gameState.verticalVelocity = verticalSpeed
            self.gameState.horizontalVelocity = horizontalSpeed
            self.gameState.rotation = rotation
        }

        let verticalOK = verticalSpeed <= GameScene.maxSafeVerticalSpeed
        let horizontalOK = horizontalSpeed <= GameScene.maxSafeHorizontalSpeed
        let rotationOK = rotation <= GameScene.maxSafeRotation
        let approachOK = approachSpeed <= GameScene.maxSafeApproachSpeed

        if verticalOK && horizontalOK && rotationOK && approachOK {
            let landedPlatform = determineLandedPlatform(contactNode: contactNode) ?? .a
            successfulLanding(
                verticalSpeed: verticalSpeed,
                horizontalSpeed: horizontalSpeed,
                rotation: rotation,
                approachSpeed: approachSpeed,
                platform: landedPlatform
            )
        } else {
            crashRocket()
        }
    }

    private func successfulLanding(verticalSpeed: CGFloat, horizontalSpeed: CGFloat, rotation: CGFloat, approachSpeed: CGFloat, platform: LandingPlatform) {
        gameState.gameOver = true
        gameState.landed = true

        rocket.physicsBody?.isDynamic = false
        removeFlames()
        stopThrustSound()

        playSuccessSound()
        HapticManager.shared.landingSuccess()

        let totalScore = calculateScore(
            verticalSpeed: verticalSpeed,
            horizontalSpeed: horizontalSpeed,
            rotation: rotation,
            approachSpeed: approachSpeed,
            platform: platform
        )

        let message = LandingMessages.successMessage(platform: platform, score: totalScore)

        DispatchQueue.main.async {
            self.gameState.score = totalScore
            self.gameState.landedPlatform = platform
            self.gameState.starsEarned = platform.stars
            self.gameState.landingMessage = message
        }

        createSuccessEffect()
    }

    private func crashRocket() {
        guard !gameState.gameOver else { return }

        gameState.gameOver = true
        gameState.landed = false

        rocket.physicsBody?.isDynamic = false
        removeFlames()
        stopThrustSound()

        playExplosionSound()
        HapticManager.shared.crash()

        let crashResult = LandingMessages.crashMessage()
        DispatchQueue.main.async {
            self.gameState.landingMessage = crashResult.message
            self.gameState.crashNudge = crashResult.nudge
        }

        createExplosion(at: rocket.position)
        rocket.alpha = 0
    }
}
