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
        var planetName = "Moon"

        if gameState.currentMode == .campaign,
           let level = LevelDefinition.level(for: gameState.currentLevelId) {
            celestial = level.celestialBody
            planetName = level.name
            posX = size.width * 0.8
            posY = size.height * 0.75
        } else {
            celestial = .moon
            posX = size.width * 0.8
            posY = size.height * 0.75
        }

        let r = celestial.radius

        // Base sphere
        let body = SKShapeNode(circleOfRadius: r)
        body.fillColor = celestial.color
        body.strokeColor = .clear
        body.position = CGPoint(x: posX, y: posY)
        body.zPosition = -5

        // Craters (Moon, Mercury, Ganymede)
        for _ in 0..<celestial.craterCount {
            let craterR = CGFloat.random(in: 3...8)
            let crater = SKShapeNode(circleOfRadius: craterR)
            crater.fillColor = celestial.color.withAlphaComponent(0.6)
            crater.strokeColor = celestial.color.withAlphaComponent(0.4)
            crater.lineWidth = 0.5
            let angle = CGFloat.random(in: 0...(.pi * 2))
            let dist = CGFloat.random(in: 0...r * 0.7)
            crater.position = CGPoint(x: cos(angle) * dist, y: sin(angle) * dist)
            body.addChild(crater)

            // Inner shadow for depth
            let inner = SKShapeNode(circleOfRadius: craterR * 0.6)
            inner.fillColor = celestial.color.withAlphaComponent(0.45)
            inner.strokeColor = .clear
            inner.position = CGPoint(x: craterR * 0.15, y: -craterR * 0.15)
            crater.addChild(inner)
        }

        // Planet-specific surface features
        switch celestial.name {
        case "Earth":
            addEarthFeatures(to: body, radius: r)
        case "Mars":
            addMarsFeatures(to: body, radius: r)
        case "Jupiter":
            addJupiterBands(to: body, radius: r)
        case "Venus":
            addVenusFeatures(to: body, radius: r)
        case "Saturn":
            addSaturnFeatures(to: body, radius: r, hasRings: celestial.hasRings)
        case "Mercury":
            break // craters are enough
        default:
            break
        }

        // Level-specific surface overlays
        switch planetName {
        case "Europa":
            addEuropaFeatures(to: body, radius: r)
        case "Titan":
            break // Saturn parent handled above
        case "Ganymede", "Io":
            if planetName == "Io" {
                addIoFeatures(to: body, radius: r)
            }
        default:
            break
        }

        // Atmospheric glow for planets with atmosphere
        let hasAtmosphere = ["Earth", "Mars", "Venus", "Saturn"].contains(celestial.name)
            || ["Titan", "Jupiter", "Io"].contains(planetName)
        if hasAtmosphere {
            let glow = SKShapeNode(circleOfRadius: r + 3)
            glow.fillColor = .clear
            glow.strokeColor = celestial.color.withAlphaComponent(0.25)
            glow.lineWidth = 4
            glow.glowWidth = 6
            body.addChild(glow)
        }

        // Terminator shadow (dark edge for 3D effect)
        let shadowPath = CGMutablePath()
        shadowPath.addArc(center: .zero, radius: r, startAngle: -.pi / 2, endAngle: .pi / 2, clockwise: false)
        shadowPath.addLine(to: CGPoint(x: r * 0.3, y: -r))
        shadowPath.closeSubpath()
        let shadow = SKShapeNode(path: shadowPath)
        shadow.fillColor = SKColor.black.withAlphaComponent(0.2)
        shadow.strokeColor = .clear
        shadow.zPosition = 2
        body.addChild(shadow)

        // Rings for Saturn/Titan
        if celestial.hasRings {
            // Back ring (behind planet)
            let backRing = SKShapeNode(ellipseOf: CGSize(width: r * 3.2, height: r * 0.7))
            backRing.strokeColor = SKColor(red: 0.8, green: 0.7, blue: 0.5, alpha: 0.25)
            backRing.lineWidth = 5
            backRing.fillColor = .clear
            backRing.zPosition = -1
            body.addChild(backRing)

            // Front ring
            let frontRing = SKShapeNode(ellipseOf: CGSize(width: r * 3, height: r * 0.6))
            frontRing.strokeColor = SKColor(red: 0.85, green: 0.75, blue: 0.55, alpha: 0.4)
            frontRing.lineWidth = 4
            frontRing.fillColor = .clear
            frontRing.zPosition = 3
            body.addChild(frontRing)

            let innerRing = SKShapeNode(ellipseOf: CGSize(width: r * 2.5, height: r * 0.5))
            innerRing.strokeColor = SKColor(red: 0.7, green: 0.6, blue: 0.4, alpha: 0.3)
            innerRing.lineWidth = 3
            innerRing.fillColor = .clear
            innerRing.zPosition = 3
            body.addChild(innerRing)
        }

        addChild(body)
    }

    // MARK: - Planet Surface Features

    private func addEarthFeatures(to body: SKShapeNode, radius r: CGFloat) {
        // Continents as irregular blobs
        let continentColor = SKColor(red: 0.2, green: 0.55, blue: 0.2, alpha: 0.7)
        let continents: [(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat)] = [
            (-0.25, 0.3, 0.35, 0.25),   // North America
            (-0.15, -0.1, 0.2, 0.3),     // South America
            (0.15, 0.25, 0.25, 0.35),    // Europe/Africa
            (0.35, 0.15, 0.25, 0.2),     // Asia
            (0.3, -0.25, 0.2, 0.15),     // Australia
        ]

        for c in continents {
            let path = CGMutablePath()
            let cx = c.x * r
            let cy = c.y * r
            let w = c.w * r
            let h = c.h * r
            path.addEllipse(in: CGRect(x: cx - w/2, y: cy - h/2, width: w, height: h))
            let continent = SKShapeNode(path: path)
            continent.fillColor = continentColor
            continent.strokeColor = SKColor(red: 0.15, green: 0.4, blue: 0.15, alpha: 0.5)
            continent.lineWidth = 0.5
            continent.zPosition = 1
            body.addChild(continent)
        }

        // Polar ice caps
        for ySign: CGFloat in [-1, 1] {
            let cap = SKShapeNode(ellipseOf: CGSize(width: r * 0.8, height: r * 0.2))
            cap.fillColor = SKColor.white.withAlphaComponent(0.5)
            cap.strokeColor = .clear
            cap.position = CGPoint(x: 0, y: ySign * r * 0.8)
            cap.zPosition = 1
            body.addChild(cap)
        }

        // Cloud wisps
        for _ in 0..<4 {
            let cloud = SKShapeNode(ellipseOf: CGSize(
                width: CGFloat.random(in: r * 0.3...r * 0.6),
                height: CGFloat.random(in: r * 0.06...r * 0.12)
            ))
            cloud.fillColor = SKColor.white.withAlphaComponent(0.2)
            cloud.strokeColor = .clear
            let angle = CGFloat.random(in: 0...(.pi * 2))
            let dist = CGFloat.random(in: 0...r * 0.6)
            cloud.position = CGPoint(x: cos(angle) * dist, y: sin(angle) * dist)
            cloud.zPosition = 1.5
            body.addChild(cloud)
        }
    }

    private func addMarsFeatures(to body: SKShapeNode, radius r: CGFloat) {
        // Darker regions (maria)
        let darkColor = SKColor(red: 0.55, green: 0.2, blue: 0.12, alpha: 0.4)
        for _ in 0..<5 {
            let patch = SKShapeNode(ellipseOf: CGSize(
                width: CGFloat.random(in: r * 0.2...r * 0.5),
                height: CGFloat.random(in: r * 0.15...r * 0.35)
            ))
            patch.fillColor = darkColor
            patch.strokeColor = .clear
            let angle = CGFloat.random(in: 0...(.pi * 2))
            let dist = CGFloat.random(in: 0...r * 0.5)
            patch.position = CGPoint(x: cos(angle) * dist, y: sin(angle) * dist)
            patch.zPosition = 1
            body.addChild(patch)
        }

        // Polar cap
        let cap = SKShapeNode(ellipseOf: CGSize(width: r * 0.5, height: r * 0.15))
        cap.fillColor = SKColor.white.withAlphaComponent(0.4)
        cap.strokeColor = .clear
        cap.position = CGPoint(x: 0, y: r * 0.75)
        cap.zPosition = 1
        body.addChild(cap)

        // Olympus Mons hint
        let volcano = SKShapeNode(circleOfRadius: r * 0.1)
        volcano.fillColor = SKColor(red: 0.7, green: 0.25, blue: 0.15, alpha: 0.5)
        volcano.strokeColor = SKColor(red: 0.5, green: 0.15, blue: 0.1, alpha: 0.3)
        volcano.lineWidth = 1
        volcano.position = CGPoint(x: -r * 0.3, y: r * 0.2)
        volcano.zPosition = 1
        body.addChild(volcano)
    }

    private func addJupiterBands(to body: SKShapeNode, radius r: CGFloat) {
        let bandColors: [SKColor] = [
            SKColor(red: 0.85, green: 0.75, blue: 0.55, alpha: 0.3),
            SKColor(red: 0.7, green: 0.55, blue: 0.35, alpha: 0.35),
            SKColor(red: 0.9, green: 0.8, blue: 0.6, alpha: 0.25),
            SKColor(red: 0.65, green: 0.5, blue: 0.3, alpha: 0.3),
            SKColor(red: 0.85, green: 0.7, blue: 0.5, alpha: 0.2),
        ]

        for (i, color) in bandColors.enumerated() {
            let yPos = r * (-0.6 + CGFloat(i) * 0.3)
            let bandHeight = r * CGFloat.random(in: 0.1...0.18)
            let halfWidth = sqrt(max(0, r * r - yPos * yPos))

            let band = SKShapeNode(rectOf: CGSize(width: halfWidth * 2, height: bandHeight))
            band.fillColor = color
            band.strokeColor = .clear
            band.position = CGPoint(x: 0, y: yPos)
            band.zPosition = 1
            body.addChild(band)
        }

        // Great Red Spot
        let spot = SKShapeNode(ellipseOf: CGSize(width: r * 0.25, height: r * 0.15))
        spot.fillColor = SKColor(red: 0.8, green: 0.35, blue: 0.2, alpha: 0.5)
        spot.strokeColor = SKColor(red: 0.7, green: 0.3, blue: 0.15, alpha: 0.3)
        spot.lineWidth = 1
        spot.position = CGPoint(x: r * 0.2, y: -r * 0.2)
        spot.zPosition = 1.5
        body.addChild(spot)
    }

    private func addVenusFeatures(to body: SKShapeNode, radius r: CGFloat) {
        // Thick cloud bands
        for i in 0..<4 {
            let yPos = r * (-0.4 + CGFloat(i) * 0.25)
            let cloud = SKShapeNode(ellipseOf: CGSize(
                width: r * CGFloat.random(in: 1.2...1.6),
                height: r * CGFloat.random(in: 0.12...0.2)
            ))
            cloud.fillColor = SKColor(red: 0.95, green: 0.8, blue: 0.5, alpha: 0.15)
            cloud.strokeColor = .clear
            cloud.position = CGPoint(x: CGFloat.random(in: -r * 0.2...r * 0.2), y: yPos)
            cloud.zPosition = 1
            body.addChild(cloud)
        }
    }

    private func addSaturnFeatures(to body: SKShapeNode, radius r: CGFloat, hasRings: Bool) {
        // Subtle bands
        for i in 0..<3 {
            let yPos = r * (-0.3 + CGFloat(i) * 0.3)
            let band = SKShapeNode(ellipseOf: CGSize(width: r * 1.5, height: r * 0.12))
            band.fillColor = SKColor(red: 0.85, green: 0.75, blue: 0.55, alpha: 0.15)
            band.strokeColor = .clear
            band.position = CGPoint(x: 0, y: yPos)
            band.zPosition = 1
            body.addChild(band)
        }
    }

    private func addEuropaFeatures(to body: SKShapeNode, radius r: CGFloat) {
        // Ice cracks
        let crackColor = SKColor(red: 0.5, green: 0.4, blue: 0.3, alpha: 0.4)
        for _ in 0..<8 {
            let path = CGMutablePath()
            let startAngle = CGFloat.random(in: 0...(.pi * 2))
            let startDist = CGFloat.random(in: r * 0.1...r * 0.5)
            var x = cos(startAngle) * startDist
            var y = sin(startAngle) * startDist
            path.move(to: CGPoint(x: x, y: y))

            for _ in 0..<3 {
                x += CGFloat.random(in: -r * 0.3...r * 0.3)
                y += CGFloat.random(in: -r * 0.3...r * 0.3)
                path.addLine(to: CGPoint(x: x, y: y))
            }

            let crack = SKShapeNode(path: path)
            crack.strokeColor = crackColor
            crack.lineWidth = 0.8
            crack.zPosition = 1
            body.addChild(crack)
        }
    }

    private func addIoFeatures(to body: SKShapeNode, radius r: CGFloat) {
        // Volcanic spots
        let colors: [SKColor] = [
            SKColor(red: 0.9, green: 0.8, blue: 0.1, alpha: 0.5),
            SKColor(red: 0.85, green: 0.5, blue: 0.1, alpha: 0.5),
            SKColor(red: 0.7, green: 0.3, blue: 0.1, alpha: 0.4),
        ]
        for _ in 0..<6 {
            let spotR = CGFloat.random(in: r * 0.05...r * 0.12)
            let spot = SKShapeNode(circleOfRadius: spotR)
            spot.fillColor = colors.randomElement()!
            spot.strokeColor = .clear
            let angle = CGFloat.random(in: 0...(.pi * 2))
            let dist = CGFloat.random(in: 0...r * 0.65)
            spot.position = CGPoint(x: cos(angle) * dist, y: sin(angle) * dist)
            spot.zPosition = 1
            body.addChild(spot)
        }
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

        let bodyColor = SKColor(red: 0.82, green: 0.83, blue: 0.85, alpha: 1.0)
        let bodyHighlight = SKColor(red: 0.88, green: 0.89, blue: 0.91, alpha: 1.0)
        let bodyStroke = SKColor(red: 0.6, green: 0.6, blue: 0.63, alpha: 1.0)
        let flapColor = SKColor(red: 0.18, green: 0.18, blue: 0.2, alpha: 1.0)
        let flapStroke = SKColor(red: 0.3, green: 0.3, blue: 0.33, alpha: 1.0)
        let darkMetal = SKColor(red: 0.15, green: 0.15, blue: 0.17, alpha: 1.0)

        let bodyWidth: CGFloat = 26
        let bodyHeight: CGFloat = 70

        // Main body (cylindrical with dome nose)
        let bodyPath = CGMutablePath()
        bodyPath.move(to: CGPoint(x: -bodyWidth/2, y: -bodyHeight/2 + 5))
        bodyPath.addLine(to: CGPoint(x: -bodyWidth/2, y: bodyHeight/2 - 18))
        bodyPath.addQuadCurve(to: CGPoint(x: bodyWidth/2, y: bodyHeight/2 - 18),
                              control: CGPoint(x: 0, y: bodyHeight/2 + 12))
        bodyPath.addLine(to: CGPoint(x: bodyWidth/2, y: -bodyHeight/2 + 5))
        bodyPath.addLine(to: CGPoint(x: -bodyWidth/2, y: -bodyHeight/2 + 5))
        bodyPath.closeSubpath()

        let body = SKShapeNode(path: bodyPath)
        body.fillColor = bodyColor
        body.strokeColor = bodyStroke
        body.lineWidth = 1.5
        rocket.addChild(body)

        // Body highlight strip (left side reflection)
        let highlightPath = CGMutablePath()
        highlightPath.move(to: CGPoint(x: -bodyWidth/2 + 3, y: -bodyHeight/2 + 8))
        highlightPath.addLine(to: CGPoint(x: -bodyWidth/2 + 3, y: bodyHeight/2 - 20))
        highlightPath.addLine(to: CGPoint(x: -bodyWidth/2 + 7, y: bodyHeight/2 - 22))
        highlightPath.addLine(to: CGPoint(x: -bodyWidth/2 + 7, y: -bodyHeight/2 + 8))
        highlightPath.closeSubpath()
        let highlight = SKShapeNode(path: highlightPath)
        highlight.fillColor = bodyHighlight
        highlight.strokeColor = .clear
        rocket.addChild(highlight)

        // Panel seam lines (horizontal)
        for yPos: CGFloat in [-15, 0, 15] {
            let seam = SKShapeNode(rectOf: CGSize(width: bodyWidth - 4, height: 0.5))
            seam.position = CGPoint(x: 0, y: yPos)
            seam.fillColor = bodyStroke.withAlphaComponent(0.5)
            seam.strokeColor = .clear
            rocket.addChild(seam)
        }

        // Vertical panel seam (center)
        let vSeam = SKShapeNode(rectOf: CGSize(width: 0.5, height: bodyHeight * 0.6))
        vSeam.position = CGPoint(x: 0, y: -2)
        vSeam.fillColor = bodyStroke.withAlphaComponent(0.3)
        vSeam.strokeColor = .clear
        rocket.addChild(vSeam)

        // Forward flaps (larger, more angular)
        for offset in [-1, 1] {
            let flapPath = CGMutablePath()
            let flapBaseY: CGFloat = 16
            let flapTopY: CGFloat = 30
            let flapInnerX = CGFloat(offset) * bodyWidth/2
            let flapOuterX = CGFloat(offset) * (bodyWidth/2 + 16)
            let flapOuterTipX = CGFloat(offset) * (bodyWidth/2 + 12)

            flapPath.move(to: CGPoint(x: flapInnerX, y: flapBaseY))
            flapPath.addLine(to: CGPoint(x: flapOuterX, y: flapBaseY - 3))
            flapPath.addLine(to: CGPoint(x: flapOuterTipX, y: flapTopY))
            flapPath.addLine(to: CGPoint(x: flapInnerX, y: flapTopY - 2))
            flapPath.closeSubpath()

            let flap = SKShapeNode(path: flapPath)
            flap.fillColor = flapColor
            flap.strokeColor = flapStroke
            flap.lineWidth = 1
            rocket.addChild(flap)

            // Flap hinge detail
            let hinge = SKShapeNode(rectOf: CGSize(width: 2, height: 12))
            hinge.position = CGPoint(x: flapInnerX, y: (flapBaseY + flapTopY) / 2)
            hinge.fillColor = flapStroke
            hinge.strokeColor = .clear
            rocket.addChild(hinge)
        }

        // Aft flaps (larger, more prominent)
        for offset in [-1, 1] {
            let flapPath = CGMutablePath()
            let flapBaseY: CGFloat = -28
            let flapTopY: CGFloat = -12
            let flapInnerX = CGFloat(offset) * bodyWidth/2
            let flapOuterX = CGFloat(offset) * (bodyWidth/2 + 18)
            let flapOuterBottomX = CGFloat(offset) * (bodyWidth/2 + 14)

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

            // Aft flap hinge
            let hinge = SKShapeNode(rectOf: CGSize(width: 2, height: 14))
            hinge.position = CGPoint(x: flapInnerX, y: (flapBaseY + flapTopY) / 2)
            hinge.fillColor = flapStroke
            hinge.strokeColor = .clear
            rocket.addChild(hinge)
        }

        // Engine skirt (wider, tapered)
        let enginePath = CGMutablePath()
        enginePath.move(to: CGPoint(x: -bodyWidth/2, y: -bodyHeight/2 + 5))
        enginePath.addLine(to: CGPoint(x: -bodyWidth/2 - 3, y: -bodyHeight/2 - 8))
        enginePath.addLine(to: CGPoint(x: bodyWidth/2 + 3, y: -bodyHeight/2 - 8))
        enginePath.addLine(to: CGPoint(x: bodyWidth/2, y: -bodyHeight/2 + 5))
        enginePath.closeSubpath()

        let engine = SKShapeNode(path: enginePath)
        engine.fillColor = darkMetal
        engine.strokeColor = flapStroke
        engine.lineWidth = 1
        rocket.addChild(engine)

        // Engine nozzles (3 Raptor engines)
        for i in -1...1 {
            let nozzlePath = CGMutablePath()
            let nx = CGFloat(i) * 8
            let ny = -bodyHeight/2 - 5
            nozzlePath.move(to: CGPoint(x: nx - 3, y: ny + 3))
            nozzlePath.addLine(to: CGPoint(x: nx - 4, y: ny - 4))
            nozzlePath.addLine(to: CGPoint(x: nx + 4, y: ny - 4))
            nozzlePath.addLine(to: CGPoint(x: nx + 3, y: ny + 3))
            nozzlePath.closeSubpath()

            let nozzle = SKShapeNode(path: nozzlePath)
            nozzle.fillColor = SKColor(red: 0.1, green: 0.1, blue: 0.12, alpha: 1.0)
            nozzle.strokeColor = darkMetal
            nozzle.lineWidth = 0.5
            rocket.addChild(nozzle)

            // Nozzle inner glow
            let inner = SKShapeNode(circleOfRadius: 2)
            inner.position = CGPoint(x: nx, y: ny - 1)
            inner.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.22, alpha: 1.0)
            inner.strokeColor = .clear
            rocket.addChild(inner)
        }

        // Landing legs (sturdier)
        for offset in [-1, 1] {
            let legPath = CGMutablePath()
            legPath.move(to: CGPoint(x: CGFloat(offset) * 8, y: -bodyHeight/2 + 2))
            legPath.addLine(to: CGPoint(x: CGFloat(offset) * 22, y: -bodyHeight/2 - 18))
            legPath.addLine(to: CGPoint(x: CGFloat(offset) * 25, y: -bodyHeight/2 - 17))
            legPath.addLine(to: CGPoint(x: CGFloat(offset) * 12, y: -bodyHeight/2 + 4))
            legPath.closeSubpath()

            let leg = SKShapeNode(path: legPath)
            leg.fillColor = SKColor(red: 0.45, green: 0.45, blue: 0.48, alpha: 1.0)
            leg.strokeColor = flapStroke
            leg.lineWidth = 1
            rocket.addChild(leg)

            // Foot pad
            let foot = SKShapeNode(rectOf: CGSize(width: 8, height: 2.5), cornerRadius: 1)
            foot.position = CGPoint(x: CGFloat(offset) * 23.5, y: -bodyHeight/2 - 18)
            foot.fillColor = SKColor(red: 0.35, green: 0.35, blue: 0.38, alpha: 1.0)
            foot.strokeColor = .clear
            rocket.addChild(foot)
        }

        // Position rocket — upper-left for multi-platform layout
        let startX = size.width * 0.15
        rocket.position = CGPoint(x: startX, y: size.height - 100)

        // Physics body
        rocket.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 54, height: 85))
        rocket.physicsBody?.mass = 1.0
        rocket.physicsBody?.linearDamping = 0.0
        rocket.physicsBody?.angularDamping = 0.7
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
