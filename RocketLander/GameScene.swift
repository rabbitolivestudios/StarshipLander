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

    // Campaign: moving platform
    private var movingPlatformDirection: CGFloat = 1
    private var movingPlatformSpeed: CGFloat = 40

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
        case .heavyTurbulence:
            windForce = 0  // Will oscillate in update
        case .heatShimmer:
            createHeatShimmer()
        case .volcanicEruptions:
            createVolcanicEruption()
        case .denseAtmosphere:
            // Increase damping on rocket when it's created
            rocket.physicsBody?.linearDamping = 0.5
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

            let thrustPower: CGFloat = 12.0
            let angle = rocket.zRotation + .pi / 2
            let dx = cos(angle) * thrustPower
            let dy = sin(angle) * thrustPower

            velocity.dx += dx
            velocity.dy += dy
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

        // Lateral assist: when tilted >5°, apply small horizontal nudge
        let tiltThreshold: CGFloat = 0.087  // ~5 degrees in radians
        if abs(rocket.zRotation) > tiltThreshold {
            let lateralAssist: CGFloat = 2.0
            let nudge = rocket.zRotation > 0 ? -lateralAssist : lateralAssist
            rocket.physicsBody?.velocity.dx += nudge * CGFloat(dt)
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
            // Variable sine-wave wind
            windTime += dt
            windForce = CGFloat(sin(windTime * 2.0)) * 5.0 + CGFloat.random(in: -1...1)
            rocket.physicsBody?.applyForce(CGVector(dx: windForce, dy: 0))

        case .extremeWind:
            // Extreme gusts
            windTime += dt
            windForce = CGFloat(sin(windTime * 1.5)) * 12.0 + CGFloat.random(in: -3...3)
            rocket.physicsBody?.applyForce(CGVector(dx: windForce, dy: 0))

        case .movingPlatform:
            // Move platform B (center, index 1)
            if platforms.count > 1 {
                let platB = platforms[1]
                let minX = size.width * 0.3
                let maxX = size.width * 0.7

                platB.position.x += movingPlatformDirection * movingPlatformSpeed * CGFloat(dt)

                if platB.position.x > maxX {
                    platB.position.x = maxX
                    movingPlatformDirection = -1
                } else if platB.position.x < minX {
                    platB.position.x = minX
                    movingPlatformDirection = 1
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
