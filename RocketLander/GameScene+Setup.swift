import SpriteKit

// MARK: - Scene Setup
extension GameScene {

    func createStarfield() {
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

                let twinkle = SKAction.sequence([
                    SKAction.fadeAlpha(to: CGFloat(alpha * 0.3), duration: Double.random(in: 0.5...2.0)),
                    SKAction.fadeAlpha(to: CGFloat(alpha), duration: Double.random(in: 0.5...2.0))
                ])
                star.run(SKAction.repeatForever(twinkle))

                addChild(star)
            }
        }
    }

    func createCelestialBody() {
        let celestial: CelestialBody
        let posX: CGFloat
        let posY: CGFloat

        if gameState.currentMode == .campaign,
           let level = LevelDefinition.level(for: gameState.currentLevelId) {
            celestial = level.celestialBody
            posX = size.width * 0.8
            posY = size.height * 0.75
        } else {
            // Classic mode: moon
            celestial = .moon
            posX = size.width * 0.8
            posY = size.height * 0.75
        }

        let body = SKShapeNode(circleOfRadius: celestial.radius)
        body.fillColor = celestial.color
        body.strokeColor = .clear
        body.position = CGPoint(x: posX, y: posY)
        body.zPosition = -5

        // Craters
        for _ in 0..<celestial.craterCount {
            let crater = SKShapeNode(circleOfRadius: CGFloat.random(in: 3...8))
            crater.fillColor = celestial.color.withAlphaComponent(0.7)
            crater.strokeColor = .clear
            crater.position = CGPoint(
                x: CGFloat.random(in: -celestial.radius * 0.6...celestial.radius * 0.6),
                y: CGFloat.random(in: -celestial.radius * 0.6...celestial.radius * 0.6)
            )
            body.addChild(crater)
        }

        // Rings for Saturn/Titan
        if celestial.hasRings {
            let ring = SKShapeNode(ellipseOf: CGSize(width: celestial.radius * 3, height: celestial.radius * 0.6))
            ring.strokeColor = celestial.color.withAlphaComponent(0.4)
            ring.lineWidth = 3
            ring.fillColor = .clear
            ring.zPosition = -1
            body.addChild(ring)
        }

        addChild(body)
    }

    func createTerrain() {
        let terrainPath = CGMutablePath()
        terrainPath.move(to: CGPoint(x: 0, y: 0))

        let segmentWidth: CGFloat = 20
        var heights: [CGFloat] = []
        var x: CGFloat = 0

        // Get platform positions to create valleys
        let platformPositions = LandingPlatform.allCases.map { $0.xFraction * size.width }
        let platformWidths = LandingPlatform.allCases.map { $0.width }

        while x <= size.width {
            var baseHeight: CGFloat = 180 + CGFloat.random(in: -20...40)

            // Create valleys near platform positions
            for (i, platX) in platformPositions.enumerated() {
                let halfWidth = platformWidths[i] / 2 + 30 // Extra margin
                let dist = abs(x - platX)
                if dist < halfWidth {
                    // Create a valley — lower the terrain near platforms
                    let valleyDepth: CGFloat = 60
                    let valleyFactor = 1.0 - (dist / halfWidth)
                    baseHeight -= valleyDepth * valleyFactor
                }
            }

            // Deep craters for Ganymede level
            if gameState.currentMode == .campaign && gameState.currentLevelId == 8 {
                let isNearPlatform = platformPositions.contains { abs(x - $0) < 80 }
                if !isNearPlatform && Int.random(in: 0...3) == 0 {
                    baseHeight += CGFloat.random(in: 30...60)
                }
            }

            heights.append(baseHeight)
            x += segmentWidth
        }

        // Smooth heights
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

        // Determine terrain colors
        let fillColor: SKColor
        let strokeColor: SKColor

        if gameState.currentMode == .campaign,
           let level = LevelDefinition.level(for: gameState.currentLevelId) {
            fillColor = level.terrainColor
            strokeColor = level.terrainStrokeColor
        } else {
            fillColor = SKColor(red: 0.25, green: 0.2, blue: 0.15, alpha: 1.0)
            strokeColor = SKColor(red: 0.35, green: 0.3, blue: 0.25, alpha: 1.0)
        }

        terrain = SKShapeNode(path: terrainPath)
        terrain.fillColor = fillColor
        terrain.strokeColor = strokeColor
        terrain.lineWidth = 2
        terrain.zPosition = 1

        // Texture rocks
        for _ in 0..<30 {
            let rock = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...6))
            rock.fillColor = fillColor.withAlphaComponent(0.5)
            rock.strokeColor = .clear
            rock.position = CGPoint(
                x: CGFloat.random(in: 20...size.width - 20),
                y: CGFloat.random(in: 100...200)
            )
            terrain.addChild(rock)
        }

        addChild(terrain)
    }

    func createGround() {
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

    func createPlatforms() {
        platforms = []

        for platformDef in LandingPlatform.allCases {
            let platformWidth = platformDef.width
            let platformHeight: CGFloat = 8
            let platformX = platformDef.xFraction * size.width

            let platformNode = SKShapeNode(rectOf: CGSize(width: platformWidth, height: platformHeight), cornerRadius: 2)
            platformNode.position = CGPoint(x: platformX, y: 220 + platformHeight / 2)
            platformNode.fillColor = SKColor(red: 0.3, green: 0.3, blue: 0.35, alpha: 1.0)
            platformNode.strokeColor = SKColor(red: 0.5, green: 0.5, blue: 0.55, alpha: 1.0)
            platformNode.lineWidth = 2
            platformNode.zPosition = 3
            platformNode.name = "platform_\(platformDef.rawValue)"

            platformNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: platformWidth, height: platformHeight))
            platformNode.physicsBody?.isDynamic = false
            platformNode.physicsBody?.categoryBitMask = platformCategory
            platformNode.physicsBody?.contactTestBitMask = rocketCategory

            // Ice surface for Europa
            if gameState.currentMode == .campaign && gameState.currentLevelId == 4 {
                platformNode.physicsBody?.friction = 0.05
            } else {
                platformNode.physicsBody?.friction = 0.8
            }

            // Platform legs
            for offset in [-1, 1] {
                let leg = SKShapeNode(rectOf: CGSize(width: 6, height: 20))
                leg.fillColor = SKColor(red: 0.25, green: 0.25, blue: 0.3, alpha: 1.0)
                leg.strokeColor = .clear
                leg.position = CGPoint(x: CGFloat(offset) * (platformWidth / 2 - 15), y: -14)
                platformNode.addChild(leg)
            }

            // Landing marking
            let marking = SKShapeNode(rectOf: CGSize(width: platformWidth - 20, height: 2))
            marking.fillColor = platformDef.lightColor
            marking.strokeColor = .clear
            marking.position = CGPoint(x: 0, y: 0)
            platformNode.addChild(marking)

            // Landing lights
            let lightColor = platformDef.lightColor
            for offset in [-1, 1] {
                let light = SKShapeNode(circleOfRadius: 4)
                light.position = CGPoint(x: CGFloat(offset) * (platformWidth / 2 - 8), y: platformHeight / 2 + 4)
                light.fillColor = lightColor
                light.strokeColor = .clear
                light.zPosition = 1

                let glow = SKShapeNode(circleOfRadius: 8)
                glow.fillColor = lightColor.withAlphaComponent(0.3)
                glow.strokeColor = .clear
                glow.zPosition = -1
                light.addChild(glow)

                let pulse = SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.5, duration: 0.5),
                    SKAction.fadeAlpha(to: 1.0, duration: 0.5)
                ])
                light.run(SKAction.repeatForever(pulse))

                platformNode.addChild(light)
            }

            // Platform label below
            let label = SKLabelNode(text: "\(platformDef.label)")
            label.fontSize = 10
            label.fontName = "Helvetica-Bold"
            label.fontColor = platformDef.lightColor
            label.position = CGPoint(x: 0, y: -32)
            platformNode.addChild(label)

            let multiplierLabel = SKLabelNode(text: "\(Int(platformDef.multiplier))x")
            multiplierLabel.fontSize = 12
            multiplierLabel.fontName = "Helvetica-Bold"
            multiplierLabel.fontColor = SKColor.white
            multiplierLabel.position = CGPoint(x: 0, y: -44)
            platformNode.addChild(multiplierLabel)

            addChild(platformNode)
            platforms.append(platformNode)
        }
    }

    func createRocket() {
        rocket = SKNode()
        rocket.zPosition = 10

        let bodyColor = SKColor(red: 0.91, green: 0.91, blue: 0.93, alpha: 1.0)
        let bodyStroke = SKColor(red: 0.75, green: 0.75, blue: 0.78, alpha: 1.0)
        let flapColor = SKColor(red: 0.23, green: 0.23, blue: 0.24, alpha: 1.0)
        let flapStroke = SKColor(red: 0.35, green: 0.35, blue: 0.37, alpha: 1.0)

        let bodyWidth: CGFloat = 24
        let bodyHeight: CGFloat = 65

        // Main body
        let bodyPath = CGMutablePath()
        bodyPath.move(to: CGPoint(x: -bodyWidth/2, y: -bodyHeight/2 + 5))
        bodyPath.addLine(to: CGPoint(x: -bodyWidth/2, y: bodyHeight/2 - 15))
        bodyPath.addQuadCurve(to: CGPoint(x: bodyWidth/2, y: bodyHeight/2 - 15),
                              control: CGPoint(x: 0, y: bodyHeight/2 + 10))
        bodyPath.addLine(to: CGPoint(x: bodyWidth/2, y: -bodyHeight/2 + 5))
        bodyPath.addLine(to: CGPoint(x: -bodyWidth/2, y: -bodyHeight/2 + 5))
        bodyPath.closeSubpath()

        let body = SKShapeNode(path: bodyPath)
        body.fillColor = bodyColor
        body.strokeColor = bodyStroke
        body.lineWidth = 1
        rocket.addChild(body)

        // Forward flaps
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

        // Aft flaps
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

        // Engine section
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

        // Engine nozzles
        for i in -1...1 {
            let nozzle = SKShapeNode(rectOf: CGSize(width: 5, height: 4), cornerRadius: 1)
            nozzle.position = CGPoint(x: CGFloat(i) * 7, y: -bodyHeight/2 - 3)
            nozzle.fillColor = SKColor(red: 0.15, green: 0.15, blue: 0.17, alpha: 1.0)
            nozzle.strokeColor = .clear
            rocket.addChild(nozzle)
        }

        // Landing legs
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

            let foot = SKShapeNode(rectOf: CGSize(width: 6, height: 2), cornerRadius: 1)
            foot.position = CGPoint(x: CGFloat(offset) * 21.5, y: -bodyHeight/2 - 15)
            foot.fillColor = SKColor(red: 0.4, green: 0.4, blue: 0.42, alpha: 1.0)
            foot.strokeColor = .clear
            rocket.addChild(foot)
        }

        // Position rocket — upper-left for multi-platform layout
        let startX = size.width * 0.15
        rocket.position = CGPoint(x: startX, y: size.height - 100)

        // Physics body
        rocket.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 80))
        rocket.physicsBody?.mass = 1.0
        rocket.physicsBody?.linearDamping = 0.0
        rocket.physicsBody?.angularDamping = 0.7  // Reduced from 1.0 for better lateral control
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
}
