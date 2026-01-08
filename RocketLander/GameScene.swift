import SpriteKit
import SwiftUI

class GameScene: SKScene, SKPhysicsContactDelegate {

    private var gameState: GameState
    private var rocket: SKNode!
    private var flame: SKEmitterNode?
    private var leftFlame: SKEmitterNode?
    private var rightFlame: SKEmitterNode?
    private var platform: SKShapeNode!
    private var ground: SKShapeNode!
    private var terrain: SKShapeNode!
    private var hasStarted = false
    private var lastUpdateTime: TimeInterval = 0

    // Sound nodes
    private var thrustSound: SKAudioNode?
    private var isThrustSoundPlaying = false
    private var wasRotatingLeft = false
    private var wasRotatingRight = false

    // Track approach velocity for scoring and validation
    private var maxDescentSpeed: CGFloat = 0
    private var recentVelocities: [CGFloat] = []
    private let velocityHistorySize = 30  // Track last 30 frames (~0.5 seconds)

    // Physics categories
    private let rocketCategory: UInt32 = 0x1 << 0
    private let platformCategory: UInt32 = 0x1 << 1
    private let groundCategory: UInt32 = 0x1 << 2

    // Landing thresholds
    static let maxSafeVerticalSpeed: CGFloat = 40.0  // Reduced for stricter landing
    static let maxSafeHorizontalSpeed: CGFloat = 25.0
    static let maxSafeRotation: CGFloat = 0.05 // ~3 degrees - must land almost upright
    static let maxSafeApproachSpeed: CGFloat = 80.0  // Can't be falling too fast on approach

    init(gameState: GameState) {
        self.gameState = gameState
        super.init(size: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        physicsWorld.gravity = CGVector(dx: 0, dy: -2.0)
        physicsWorld.contactDelegate = self

        setupScene()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        if size.width > 0 && size.height > 0 {
            removeAllChildren()
            setupScene()
        }
    }

    private func setupScene() {
        guard size.width > 0 && size.height > 0 else { return }

        createStarfield()
        createTerrain()
        createGround()
        createPlatform()
        createRocket()

        hasStarted = false
        gameState.gameOver = false
        gameState.landed = false
        gameState.fuel = 100
        gameState.score = 0
        gameState.verticalVelocity = 0
        gameState.horizontalVelocity = 0
        gameState.rotation = 0

        // Reset tracking
        maxDescentSpeed = 0
        recentVelocities = []

        // Reset sound state
        stopThrustSound()
        wasRotatingLeft = false
        wasRotatingRight = false
    }

    // MARK: - Sound Methods

    private func startThrustSound() {
        guard !isThrustSoundPlaying else { return }

        // Use URL-based initializer for more reliable loading
        if let url = Bundle.main.url(forResource: "thrust", withExtension: "wav") {
            thrustSound = SKAudioNode(url: url)
            if let sound = thrustSound {
                sound.autoplayLooped = true
                addChild(sound)
                // SKAudioNode with autoplayLooped starts automatically when added
                // But we need to ensure it plays by running a play action
                sound.run(SKAction.sequence([
                    SKAction.changeVolume(to: 0.5, duration: 0),
                    SKAction.play()
                ]))
                isThrustSoundPlaying = true
            }
        }
    }

    private func stopThrustSound() {
        if let sound = thrustSound {
            sound.run(SKAction.stop())
            sound.removeFromParent()
        }
        thrustSound = nil
        isThrustSoundPlaying = false
    }

    private func playRotateSound() {
        run(SKAction.playSoundFileNamed("rotate.wav", waitForCompletion: false))
    }

    private func playSuccessSound() {
        run(SKAction.playSoundFileNamed("land_success.wav", waitForCompletion: false))
    }

    private func playExplosionSound() {
        run(SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false))
    }

    private func createStarfield() {
        // Create parallax star layers
        for layer in 0..<3 {
            let starCount = 30 + layer * 20
            let alpha = 0.3 + Double(layer) * 0.25

            for _ in 0..<starCount {
                let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.5...2.0))
                star.fillColor = .white
                star.strokeColor = .clear
                star.alpha = CGFloat(alpha * Double.random(in: 0.5...1.0))
                star.position = CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: size.height * 0.3...size.height)
                )
                star.zPosition = -10 + CGFloat(layer)

                // Twinkling animation
                let twinkle = SKAction.sequence([
                    SKAction.fadeAlpha(to: CGFloat(alpha * 0.3), duration: Double.random(in: 0.5...2.0)),
                    SKAction.fadeAlpha(to: CGFloat(alpha), duration: Double.random(in: 0.5...2.0))
                ])
                star.run(SKAction.repeatForever(twinkle))

                addChild(star)
            }
        }

        // Add a moon/planet
        let moon = SKShapeNode(circleOfRadius: 40)
        moon.fillColor = SKColor(red: 0.85, green: 0.85, blue: 0.8, alpha: 1.0)
        moon.strokeColor = .clear
        moon.position = CGPoint(x: size.width * 0.8, y: size.height * 0.75)
        moon.zPosition = -5

        // Moon craters
        for _ in 0..<5 {
            let crater = SKShapeNode(circleOfRadius: CGFloat.random(in: 3...8))
            crater.fillColor = SKColor(red: 0.7, green: 0.7, blue: 0.65, alpha: 1.0)
            crater.strokeColor = .clear
            crater.position = CGPoint(
                x: CGFloat.random(in: -25...25),
                y: CGFloat.random(in: -25...25)
            )
            moon.addChild(crater)
        }
        addChild(moon)
    }

    private func createTerrain() {
        let terrainPath = CGMutablePath()
        terrainPath.move(to: CGPoint(x: 0, y: 0))

        // Generate rocky terrain - raised to match higher platform
        var x: CGFloat = 0
        let segmentWidth: CGFloat = 20
        var heights: [CGFloat] = []

        while x <= size.width {
            let baseHeight: CGFloat = 180 + CGFloat.random(in: -20...40)
            heights.append(baseHeight)
            x += segmentWidth
        }

        // Smooth the heights
        for i in 1..<heights.count - 1 {
            heights[i] = (heights[i-1] + heights[i] + heights[i+1]) / 3
        }

        // Draw terrain
        x = 0
        for height in heights {
            terrainPath.addLine(to: CGPoint(x: x, y: height))
            x += segmentWidth
        }

        terrainPath.addLine(to: CGPoint(x: size.width, y: 0))
        terrainPath.closeSubpath()

        terrain = SKShapeNode(path: terrainPath)
        terrain.fillColor = SKColor(red: 0.25, green: 0.2, blue: 0.15, alpha: 1.0)
        terrain.strokeColor = SKColor(red: 0.35, green: 0.3, blue: 0.25, alpha: 1.0)
        terrain.lineWidth = 2
        terrain.zPosition = 1

        // Add texture effect with smaller rocks
        for _ in 0..<30 {
            let rock = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...6))
            rock.fillColor = SKColor(red: 0.3, green: 0.25, blue: 0.2, alpha: 0.5)
            rock.strokeColor = .clear
            rock.position = CGPoint(
                x: CGFloat.random(in: 20...size.width - 20),
                y: CGFloat.random(in: 140...200)
            )
            terrain.addChild(rock)
        }

        addChild(terrain)
    }

    private func createGround() {
        ground = SKShapeNode(rectOf: CGSize(width: size.width * 2, height: 10))
        ground.position = CGPoint(x: size.width / 2, y: 5)
        ground.fillColor = SKColor(red: 0.2, green: 0.15, blue: 0.1, alpha: 1.0)
        ground.strokeColor = .clear
        ground.zPosition = 2

        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 2, height: 10))
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = groundCategory
        ground.physicsBody?.contactTestBitMask = rocketCategory
        ground.physicsBody?.friction = 0.5

        addChild(ground)
    }

    private func createPlatform() {
        let platformWidth: CGFloat = 120
        let platformHeight: CGFloat = 8

        // Random position for platform
        let minX = platformWidth / 2 + 60
        let maxX = size.width - platformWidth / 2 - 60
        let platformX = CGFloat.random(in: minX...maxX)

        // Platform base - positioned high enough to be above controls (bottom 200pt)
        platform = SKShapeNode(rectOf: CGSize(width: platformWidth, height: platformHeight), cornerRadius: 2)
        platform.position = CGPoint(x: platformX, y: 220 + platformHeight / 2)
        platform.fillColor = SKColor(red: 0.3, green: 0.3, blue: 0.35, alpha: 1.0)
        platform.strokeColor = SKColor(red: 0.5, green: 0.5, blue: 0.55, alpha: 1.0)
        platform.lineWidth = 2
        platform.zPosition = 3

        platform.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: platformWidth, height: platformHeight))
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.categoryBitMask = platformCategory
        platform.physicsBody?.contactTestBitMask = rocketCategory
        platform.physicsBody?.friction = 0.8

        // Platform legs
        for offset in [-1, 1] {
            let leg = SKShapeNode(rectOf: CGSize(width: 6, height: 20))
            leg.fillColor = SKColor(red: 0.25, green: 0.25, blue: 0.3, alpha: 1.0)
            leg.strokeColor = .clear
            leg.position = CGPoint(x: CGFloat(offset) * (platformWidth / 2 - 15), y: -14)
            platform.addChild(leg)
        }

        // Landing markings
        let marking = SKShapeNode(rectOf: CGSize(width: platformWidth - 20, height: 2))
        marking.fillColor = .yellow
        marking.strokeColor = .clear
        marking.position = CGPoint(x: 0, y: 0)
        platform.addChild(marking)

        // Landing lights
        for offset in [-1, 1] {
            let light = SKShapeNode(circleOfRadius: 4)
            light.position = CGPoint(x: CGFloat(offset) * (platformWidth / 2 - 8), y: platformHeight / 2 + 4)
            light.fillColor = .green
            light.strokeColor = .clear
            light.zPosition = 1

            let glow = SKShapeNode(circleOfRadius: 8)
            glow.fillColor = SKColor.green.withAlphaComponent(0.3)
            glow.strokeColor = .clear
            glow.zPosition = -1
            light.addChild(glow)

            let pulse = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.5, duration: 0.5),
                SKAction.fadeAlpha(to: 1.0, duration: 0.5)
            ])
            light.run(SKAction.repeatForever(pulse))

            platform.addChild(light)
        }

        addChild(platform)
    }

    private func createRocket() {
        rocket = SKNode()
        rocket.zPosition = 10

        // Starship colors
        let bodyColor = SKColor(red: 0.91, green: 0.91, blue: 0.93, alpha: 1.0)  // #E8E8EC
        let bodyStroke = SKColor(red: 0.75, green: 0.75, blue: 0.78, alpha: 1.0)
        let flapColor = SKColor(red: 0.23, green: 0.23, blue: 0.24, alpha: 1.0)  // #3A3A3C
        let flapStroke = SKColor(red: 0.35, green: 0.35, blue: 0.37, alpha: 1.0)

        // Main cylindrical body
        let bodyWidth: CGFloat = 24
        let bodyHeight: CGFloat = 65

        let bodyPath = CGMutablePath()
        bodyPath.move(to: CGPoint(x: -bodyWidth/2, y: -bodyHeight/2 + 5))
        bodyPath.addLine(to: CGPoint(x: -bodyWidth/2, y: bodyHeight/2 - 15))
        // Dome nose cone
        bodyPath.addQuadCurve(to: CGPoint(x: bodyWidth/2, y: bodyHeight/2 - 15),
                              control: CGPoint(x: 0, y: bodyHeight/2 + 10))
        bodyPath.addLine(to: CGPoint(x: bodyWidth/2, y: -bodyHeight/2 + 5))
        // Flat bottom
        bodyPath.addLine(to: CGPoint(x: -bodyWidth/2, y: -bodyHeight/2 + 5))
        bodyPath.closeSubpath()

        let body = SKShapeNode(path: bodyPath)
        body.fillColor = bodyColor
        body.strokeColor = bodyStroke
        body.lineWidth = 1
        rocket.addChild(body)

        // Forward flaps (2 flaps near the nose)
        for offset in [-1, 1] {
            let flapPath = CGMutablePath()
            let flapBaseY: CGFloat = 18
            let flapTopY: CGFloat = 28
            let flapInnerX = CGFloat(offset) * bodyWidth/2
            let flapOuterX = CGFloat(offset) * (bodyWidth/2 + 14)
            let flapOuterTipX = CGFloat(offset) * (bodyWidth/2 + 10)

            flapPath.move(to: CGPoint(x: flapInnerX, y: flapBaseY))
            flapPath.addLine(to: CGPoint(x: flapOuterX, y: flapBaseY - 2))
            flapPath.addLine(to: CGPoint(x: flapOuterTipX, y: flapTopY))
            flapPath.addLine(to: CGPoint(x: flapInnerX, y: flapTopY - 2))
            flapPath.closeSubpath()

            let flap = SKShapeNode(path: flapPath)
            flap.fillColor = flapColor
            flap.strokeColor = flapStroke
            flap.lineWidth = 1
            rocket.addChild(flap)
        }

        // Aft flaps (2 flaps near the base)
        for offset in [-1, 1] {
            let flapPath = CGMutablePath()
            let flapBaseY: CGFloat = -25
            let flapTopY: CGFloat = -12
            let flapInnerX = CGFloat(offset) * bodyWidth/2
            let flapOuterX = CGFloat(offset) * (bodyWidth/2 + 16)
            let flapOuterBottomX = CGFloat(offset) * (bodyWidth/2 + 12)

            flapPath.move(to: CGPoint(x: flapInnerX, y: flapTopY))
            flapPath.addLine(to: CGPoint(x: flapOuterX, y: flapTopY + 2))
            flapPath.addLine(to: CGPoint(x: flapOuterBottomX, y: flapBaseY))
            flapPath.addLine(to: CGPoint(x: flapInnerX, y: flapBaseY + 3))
            flapPath.closeSubpath()

            let flap = SKShapeNode(path: flapPath)
            flap.fillColor = flapColor
            flap.strokeColor = flapStroke
            flap.lineWidth = 1
            rocket.addChild(flap)
        }

        // Engine section (dark bottom)
        let enginePath = CGMutablePath()
        enginePath.move(to: CGPoint(x: -bodyWidth/2, y: -bodyHeight/2 + 5))
        enginePath.addLine(to: CGPoint(x: -bodyWidth/2 - 2, y: -bodyHeight/2 - 5))
        enginePath.addLine(to: CGPoint(x: bodyWidth/2 + 2, y: -bodyHeight/2 - 5))
        enginePath.addLine(to: CGPoint(x: bodyWidth/2, y: -bodyHeight/2 + 5))
        enginePath.closeSubpath()

        let engine = SKShapeNode(path: enginePath)
        engine.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.22, alpha: 1.0)
        engine.strokeColor = flapStroke
        engine.lineWidth = 1
        rocket.addChild(engine)

        // Engine nozzles (3 visible)
        for i in -1...1 {
            let nozzle = SKShapeNode(rectOf: CGSize(width: 5, height: 4), cornerRadius: 1)
            nozzle.position = CGPoint(x: CGFloat(i) * 7, y: -bodyHeight/2 - 3)
            nozzle.fillColor = SKColor(red: 0.15, green: 0.15, blue: 0.17, alpha: 1.0)
            nozzle.strokeColor = .clear
            rocket.addChild(nozzle)
        }

        // Landing legs (deployable, 4 legs)
        for offset in [-1, 1] {
            let legPath = CGMutablePath()
            legPath.move(to: CGPoint(x: CGFloat(offset) * 8, y: -bodyHeight/2))
            legPath.addLine(to: CGPoint(x: CGFloat(offset) * 20, y: -bodyHeight/2 - 15))
            legPath.addLine(to: CGPoint(x: CGFloat(offset) * 23, y: -bodyHeight/2 - 14))
            legPath.addLine(to: CGPoint(x: CGFloat(offset) * 11, y: -bodyHeight/2 + 2))
            legPath.closeSubpath()

            let leg = SKShapeNode(path: legPath)
            leg.fillColor = SKColor(red: 0.5, green: 0.5, blue: 0.52, alpha: 1.0)
            leg.strokeColor = flapStroke
            leg.lineWidth = 1
            rocket.addChild(leg)

            // Leg foot pad
            let foot = SKShapeNode(rectOf: CGSize(width: 6, height: 2), cornerRadius: 1)
            foot.position = CGPoint(x: CGFloat(offset) * 21.5, y: -bodyHeight/2 - 15)
            foot.fillColor = SKColor(red: 0.4, green: 0.4, blue: 0.42, alpha: 1.0)
            foot.strokeColor = .clear
            rocket.addChild(foot)
        }

        // Position rocket at top
        let startX = size.width / 2 + CGFloat.random(in: -50...50)
        rocket.position = CGPoint(x: startX, y: size.height - 100)

        // Physics body - adjusted for new Starship shape
        rocket.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 80))
        rocket.physicsBody?.mass = 1.0
        rocket.physicsBody?.linearDamping = 0.0
        rocket.physicsBody?.angularDamping = 1.0
        rocket.physicsBody?.allowsRotation = true
        rocket.physicsBody?.categoryBitMask = rocketCategory
        rocket.physicsBody?.contactTestBitMask = platformCategory | groundCategory
        rocket.physicsBody?.collisionBitMask = platformCategory | groundCategory
        rocket.physicsBody?.isDynamic = false
        rocket.physicsBody?.restitution = 0.0
        rocket.physicsBody?.friction = 0.5
        rocket.physicsBody?.affectedByGravity = true

        addChild(rocket)
    }

    private func createMainFlame() {
        flame?.removeFromParent()

        if let emitter = SKEmitterNode(fileNamed: "RocketFlame") {
            emitter.position = CGPoint(x: 0, y: -42)
            emitter.zPosition = -1
            emitter.targetNode = self
            rocket.addChild(emitter)
            flame = emitter
        } else {
            // Fallback: create flame manually for Starship engines
            let flameNode = createManualFlame(width: 18, height: 45)
            flameNode.position = CGPoint(x: 0, y: -42)
            flameNode.zPosition = -1
            rocket.addChild(flameNode)
        }
    }

    private func createManualFlame(width: CGFloat, height: CGFloat) -> SKNode {
        let container = SKNode()

        // Outer flame (orange/red)
        let outerPath = CGMutablePath()
        outerPath.move(to: CGPoint(x: -width/2, y: 0))
        outerPath.addQuadCurve(to: CGPoint(x: 0, y: -height), control: CGPoint(x: -width/4, y: -height * 0.7))
        outerPath.addQuadCurve(to: CGPoint(x: width/2, y: 0), control: CGPoint(x: width/4, y: -height * 0.7))
        outerPath.closeSubpath()

        let outer = SKShapeNode(path: outerPath)
        outer.fillColor = SKColor(red: 1.0, green: 0.4, blue: 0.1, alpha: 0.9)
        outer.strokeColor = .clear
        container.addChild(outer)

        // Inner flame (yellow/white)
        let innerPath = CGMutablePath()
        innerPath.move(to: CGPoint(x: -width/3, y: 0))
        innerPath.addQuadCurve(to: CGPoint(x: 0, y: -height * 0.7), control: CGPoint(x: -width/6, y: -height * 0.5))
        innerPath.addQuadCurve(to: CGPoint(x: width/3, y: 0), control: CGPoint(x: width/6, y: -height * 0.5))
        innerPath.closeSubpath()

        let inner = SKShapeNode(path: innerPath)
        inner.fillColor = SKColor(red: 1.0, green: 0.9, blue: 0.5, alpha: 0.95)
        inner.strokeColor = .clear
        container.addChild(inner)

        // Core (white)
        let corePath = CGMutablePath()
        corePath.move(to: CGPoint(x: -width/5, y: 0))
        corePath.addQuadCurve(to: CGPoint(x: 0, y: -height * 0.4), control: CGPoint(x: -width/10, y: -height * 0.3))
        corePath.addQuadCurve(to: CGPoint(x: width/5, y: 0), control: CGPoint(x: width/10, y: -height * 0.3))
        corePath.closeSubpath()

        let core = SKShapeNode(path: corePath)
        core.fillColor = SKColor(red: 1.0, green: 1.0, blue: 0.9, alpha: 1.0)
        core.strokeColor = .clear
        container.addChild(core)

        // Animate flame
        let flicker = SKAction.sequence([
            SKAction.scaleY(to: 1.1, duration: 0.05),
            SKAction.scaleY(to: 0.9, duration: 0.05),
            SKAction.scaleY(to: 1.0, duration: 0.05)
        ])
        container.run(SKAction.repeatForever(flicker))

        return container
    }

    private func removeFlames() {
        rocket.children.filter { $0.position.y < -38 && $0 is SKEmitterNode || $0.children.count > 0 && $0.position.y == -42 }.forEach { $0.removeFromParent() }
        flame = nil
    }

    func startGame() {
        guard rocket != nil else { return }
        if !hasStarted {
            hasStarted = true
            rocket.physicsBody?.isDynamic = true
        }
    }

    override func update(_ currentTime: TimeInterval) {
        guard !gameState.gameOver, rocket != nil else { return }

        // Auto-start game when any control is pressed
        if !hasStarted && (gameState.isThrusting || gameState.isRotatingLeft || gameState.isRotatingRight) {
            hasStarted = true
            rocket.physicsBody?.isDynamic = true
        }

        guard hasStarted else { return }

        // Calculate delta time
        let dt = lastUpdateTime > 0 ? currentTime - lastUpdateTime : 0
        lastUpdateTime = currentTime

        // Check for reset
        if gameState.shouldReset {
            gameState.shouldReset = false
            removeAllChildren()
            lastUpdateTime = 0
            setupScene()
            return
        }

        // Get velocity and track for approach speed validation
        if let velocity = rocket.physicsBody?.velocity {
            let currentVerticalSpeed = max(0, -velocity.dy)  // Positive = falling

            // Track max descent speed
            if currentVerticalSpeed > maxDescentSpeed {
                maxDescentSpeed = currentVerticalSpeed
            }

            // Track recent velocities for approach validation
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

        // Apply main thrust - directly modify velocity for reliable control
        if gameState.isThrusting && gameState.fuel > 0 {
            guard var velocity = rocket.physicsBody?.velocity else { return }

            let thrustPower: CGFloat = 12.0  // Velocity change per frame - strong enough to overcome gravity
            let angle = rocket.zRotation + .pi / 2
            let dx = cos(angle) * thrustPower
            let dy = sin(angle) * thrustPower

            velocity.dx += dx
            velocity.dy += dy
            rocket.physicsBody?.velocity = velocity

            // Show flame if not already showing
            if flame == nil && rocket.children.filter({ $0.position.y == -42 }).isEmpty {
                createMainFlame()
            }

            // Start thrust sound
            startThrustSound()

            // Consume fuel
            DispatchQueue.main.async {
                self.gameState.fuel = max(0, self.gameState.fuel - 0.3)
            }
        } else {
            removeFlames()
            stopThrustSound()
        }

        // Apply rotation thrust - directly modify angular velocity
        if gameState.fuel > 0 {
            let rotationPower: CGFloat = 0.05

            if gameState.isRotatingLeft {
                // Play rotate sound on initial press
                if !wasRotatingLeft {
                    playRotateSound()
                }
                rocket.physicsBody?.angularVelocity += rotationPower
                DispatchQueue.main.async {
                    self.gameState.fuel = max(0, self.gameState.fuel - 0.08)
                }
            }

            if gameState.isRotatingRight {
                // Play rotate sound on initial press
                if !wasRotatingRight {
                    playRotateSound()
                }
                rocket.physicsBody?.angularVelocity -= rotationPower
                DispatchQueue.main.async {
                    self.gameState.fuel = max(0, self.gameState.fuel - 0.08)
                }
            }
        }

        // Track rotation state for sound triggers
        wasRotatingLeft = gameState.isRotatingLeft
        wasRotatingRight = gameState.isRotatingRight

        // Screen wrap - appear on other side when going off screen
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

    func didBegin(_ contact: SKPhysicsContact) {
        guard !gameState.gameOver else { return }

        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if collision == rocketCategory | platformCategory {
            checkLanding()
        } else if collision == rocketCategory | groundCategory {
            crashRocket()
        }
    }

    private func checkLanding() {
        guard let velocity = rocket.physicsBody?.velocity else { return }

        let verticalSpeed = max(0, -velocity.dy)  // Only count downward velocity
        let horizontalSpeed = abs(velocity.dx)
        let rotation = abs(rocket.zRotation)

        // Calculate average approach speed from recent history
        let approachSpeed = recentVelocities.isEmpty ? verticalSpeed : recentVelocities.reduce(0, +) / CGFloat(recentVelocities.count)

        // Update HUD with final values
        DispatchQueue.main.async {
            self.gameState.verticalVelocity = verticalSpeed
            self.gameState.horizontalVelocity = horizontalSpeed
            self.gameState.rotation = rotation
        }

        // Check landing conditions - must be under ALL thresholds
        let verticalOK = verticalSpeed <= GameScene.maxSafeVerticalSpeed
        let horizontalOK = horizontalSpeed <= GameScene.maxSafeHorizontalSpeed
        let rotationOK = rotation <= GameScene.maxSafeRotation
        let approachOK = approachSpeed <= GameScene.maxSafeApproachSpeed  // Can't brake too late

        if verticalOK && horizontalOK && rotationOK && approachOK {
            successfulLanding(verticalSpeed: verticalSpeed, horizontalSpeed: horizontalSpeed, rotation: rotation, approachSpeed: approachSpeed)
        } else {
            crashRocket()
        }
    }

    private func successfulLanding(verticalSpeed: CGFloat, horizontalSpeed: CGFloat, rotation: CGFloat, approachSpeed: CGFloat) {
        gameState.gameOver = true
        gameState.landed = true

        // Stop rocket and sounds
        rocket.physicsBody?.isDynamic = false
        removeFlames()
        stopThrustSound()

        // Play success sound
        playSuccessSound()

        // === NEW SCORING SYSTEM ===
        // Base score for successful landing
        var totalScore = 100

        // 1. FUEL EFFICIENCY (0-500 points) - THE MAIN DIFFERENTIATOR
        // Uses exponential scaling - saving fuel matters a LOT
        let fuelRatio = gameState.fuel / 100.0
        let fuelScore = Int(pow(fuelRatio, 1.5) * 500)
        totalScore += fuelScore

        // 2. SOFT LANDING BONUS (0-300 points) - based on vertical speed
        // Lower vertical speed = bigger bonus
        if verticalSpeed < 5 {
            totalScore += 300  // Feather-light touch
        } else if verticalSpeed < 15 {
            totalScore += 200  // Very soft
        } else if verticalSpeed < 25 {
            totalScore += 100  // Soft
        } else if verticalSpeed < 35 {
            totalScore += 50   // Acceptable
        }
        // Otherwise no bonus

        // 3. HORIZONTAL PRECISION (0-200 points) - drift control
        if horizontalSpeed < 3 {
            totalScore += 200  // Perfect stillness
        } else if horizontalSpeed < 10 {
            totalScore += 125  // Very controlled
        } else if horizontalSpeed < 18 {
            totalScore += 50   // Controlled
        }
        // Otherwise no bonus

        // 4. PLATFORM CENTER BONUS (0-150 points) - land in the middle
        let platformCenterX = platform.position.x
        let distanceFromCenter = abs(rocket.position.x - platformCenterX)
        if distanceFromCenter < 10 {
            totalScore += 150  // Bullseye!
        } else if distanceFromCenter < 25 {
            totalScore += 100  // Center zone
        } else if distanceFromCenter < 45 {
            totalScore += 50   // On platform
        }
        // Otherwise no bonus

        // 5. ROTATION PRECISION (0-100 points) - land upright
        if rotation < 0.01 {
            totalScore += 100  // Perfectly upright
        } else if rotation < 0.025 {
            totalScore += 60   // Nearly perfect
        } else if rotation < 0.04 {
            totalScore += 25   // Acceptable
        }
        // Otherwise no bonus

        // 6. APPROACH CONTROL BONUS (0-100 points) - didn't come in too hot
        let avgApproachSpeed = approachSpeed
        if avgApproachSpeed < 30 {
            totalScore += 100  // Very controlled approach
        } else if avgApproachSpeed < 50 {
            totalScore += 60   // Good approach
        } else if avgApproachSpeed < 70 {
            totalScore += 25   // Acceptable
        }
        // Otherwise no bonus

        // Max possible: 100 + 500 + 300 + 200 + 150 + 100 + 100 = 1450

        DispatchQueue.main.async {
            self.gameState.score = totalScore
        }

        // Success particles
        createSuccessEffect()
    }

    private func crashRocket() {
        guard !gameState.gameOver else { return }

        gameState.gameOver = true
        gameState.landed = false

        rocket.physicsBody?.isDynamic = false
        removeFlames()
        stopThrustSound()

        // Play explosion sound
        playExplosionSound()

        createExplosion(at: rocket.position)
        rocket.alpha = 0
    }

    private func createSuccessEffect() {
        // Green particles rising
        for _ in 0..<20 {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...5))
            particle.fillColor = [SKColor.green, SKColor.yellow, SKColor.white].randomElement()!
            particle.strokeColor = .clear
            particle.position = CGPoint(
                x: rocket.position.x + CGFloat.random(in: -30...30),
                y: rocket.position.y - 30
            )
            particle.zPosition = 20
            addChild(particle)

            let moveUp = SKAction.moveBy(x: CGFloat.random(in: -20...20), y: CGFloat.random(in: 50...100), duration: 1.0)
            let fade = SKAction.fadeOut(withDuration: 1.0)
            let group = SKAction.group([moveUp, fade])
            particle.run(SKAction.sequence([group, SKAction.removeFromParent()]))
        }
    }

    private func createExplosion(at position: CGPoint) {
        // Multiple explosion layers
        for i in 0..<3 {
            let delay = Double(i) * 0.1

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                // Fire particles
                for _ in 0..<15 {
                    let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 4...12))
                    particle.fillColor = [SKColor.orange, SKColor.red, SKColor.yellow].randomElement()!
                    particle.strokeColor = .clear
                    particle.position = position
                    particle.zPosition = 20
                    self.addChild(particle)

                    let angle = CGFloat.random(in: 0...(2 * .pi))
                    let distance = CGFloat.random(in: 60...150)
                    let dx = cos(angle) * distance
                    let dy = sin(angle) * distance

                    let move = SKAction.moveBy(x: dx, y: dy, duration: Double.random(in: 0.4...0.8))
                    let fade = SKAction.fadeOut(withDuration: 0.6)
                    let scale = SKAction.scale(to: 0.1, duration: 0.6)
                    let group = SKAction.group([move, fade, scale])
                    particle.run(SKAction.sequence([group, SKAction.removeFromParent()]))
                }

                // Debris
                for _ in 0..<8 {
                    let debris = SKShapeNode(rectOf: CGSize(
                        width: CGFloat.random(in: 3...10),
                        height: CGFloat.random(in: 3...10)
                    ))
                    debris.fillColor = SKColor(white: CGFloat.random(in: 0.3...0.7), alpha: 1.0)
                    debris.strokeColor = .clear
                    debris.position = position
                    debris.zPosition = 19
                    debris.zRotation = CGFloat.random(in: 0...(2 * .pi))
                    self.addChild(debris)

                    let angle = CGFloat.random(in: 0...(2 * .pi))
                    let distance = CGFloat.random(in: 40...120)
                    let dx = cos(angle) * distance
                    let dy = sin(angle) * distance + 50

                    let move = SKAction.moveBy(x: dx, y: dy, duration: 0.8)
                    let fall = SKAction.moveBy(x: 0, y: -100, duration: 0.6)
                    let rotate = SKAction.rotate(byAngle: CGFloat.random(in: -5...5), duration: 1.4)
                    let fade = SKAction.fadeOut(withDuration: 1.4)
                    let sequence = SKAction.sequence([move, fall])
                    let group = SKAction.group([sequence, rotate, fade])
                    debris.run(SKAction.sequence([group, SKAction.removeFromParent()]))
                }
            }
        }

        // Screen shake
        let shake = SKAction.sequence([
            SKAction.moveBy(x: -8, y: 0, duration: 0.05),
            SKAction.moveBy(x: 16, y: 0, duration: 0.05),
            SKAction.moveBy(x: -16, y: 0, duration: 0.05),
            SKAction.moveBy(x: 8, y: 0, duration: 0.05)
        ])
        self.run(shake)
    }
}
