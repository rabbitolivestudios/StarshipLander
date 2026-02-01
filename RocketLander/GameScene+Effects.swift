import SpriteKit

enum WindIntensity {
    case light, heavy, extreme
}

// MARK: - Visual Effects
extension GameScene {

    func createMainFlame() {
        flame?.removeFromParent()

        if let emitter = SKEmitterNode(fileNamed: "RocketFlame") {
            emitter.position = CGPoint(x: 0, y: -42)
            emitter.zPosition = -1
            emitter.targetNode = self
            rocket.addChild(emitter)
            flame = emitter
        } else {
            let flameNode = createManualFlame(width: 18, height: 45)
            flameNode.position = CGPoint(x: 0, y: -42)
            flameNode.zPosition = -1
            rocket.addChild(flameNode)
        }
    }

    func createManualFlame(width: CGFloat, height: CGFloat) -> SKNode {
        let container = SKNode()

        // Outer flame
        let outerPath = CGMutablePath()
        outerPath.move(to: CGPoint(x: -width/2, y: 0))
        outerPath.addQuadCurve(to: CGPoint(x: 0, y: -height), control: CGPoint(x: -width/4, y: -height * 0.7))
        outerPath.addQuadCurve(to: CGPoint(x: width/2, y: 0), control: CGPoint(x: width/4, y: -height * 0.7))
        outerPath.closeSubpath()

        let outer = SKShapeNode(path: outerPath)
        outer.fillColor = SKColor(red: 1.0, green: 0.4, blue: 0.1, alpha: 0.9)
        outer.strokeColor = .clear
        container.addChild(outer)

        // Inner flame
        let innerPath = CGMutablePath()
        innerPath.move(to: CGPoint(x: -width/3, y: 0))
        innerPath.addQuadCurve(to: CGPoint(x: 0, y: -height * 0.7), control: CGPoint(x: -width/6, y: -height * 0.5))
        innerPath.addQuadCurve(to: CGPoint(x: width/3, y: 0), control: CGPoint(x: width/6, y: -height * 0.5))
        innerPath.closeSubpath()

        let inner = SKShapeNode(path: innerPath)
        inner.fillColor = SKColor(red: 1.0, green: 0.9, blue: 0.5, alpha: 0.95)
        inner.strokeColor = .clear
        container.addChild(inner)

        // Core
        let corePath = CGMutablePath()
        corePath.move(to: CGPoint(x: -width/5, y: 0))
        corePath.addQuadCurve(to: CGPoint(x: 0, y: -height * 0.4), control: CGPoint(x: -width/10, y: -height * 0.3))
        corePath.addQuadCurve(to: CGPoint(x: width/5, y: 0), control: CGPoint(x: width/10, y: -height * 0.3))
        corePath.closeSubpath()

        let core = SKShapeNode(path: corePath)
        core.fillColor = SKColor(red: 1.0, green: 1.0, blue: 0.9, alpha: 1.0)
        core.strokeColor = .clear
        container.addChild(core)

        let flicker = SKAction.sequence([
            SKAction.scaleY(to: 1.1, duration: 0.05),
            SKAction.scaleY(to: 0.9, duration: 0.05),
            SKAction.scaleY(to: 1.0, duration: 0.05)
        ])
        container.run(SKAction.repeatForever(flicker))

        return container
    }

    func removeFlames() {
        rocket.children.filter { $0.position.y < -38 && $0 is SKEmitterNode || $0.children.count > 0 && $0.position.y == -42 }.forEach { $0.removeFromParent() }
        flame = nil
    }

    func createSuccessEffect() {
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

    func createExplosion(at position: CGPoint) {
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

    // MARK: - Wind Particles (Mars, Venus, Jupiter)
    func createWindParticles(intensity: WindIntensity) {
        let key = "windParticles"
        removeAction(forKey: key)

        let (count, speed, alpha, color): (Int, CGFloat, CGFloat, SKColor) = {
            switch intensity {
            case .light:  return (1, 120, 0.3, SKColor(red: 0.8, green: 0.6, blue: 0.4, alpha: 1.0))  // Mars dust
            case .heavy:  return (2, 200, 0.4, SKColor(red: 0.9, green: 0.7, blue: 0.3, alpha: 1.0))  // Venus haze
            case .extreme: return (3, 350, 0.5, SKColor.white)                                          // Jupiter streaks
            }
        }()

        // Venus (heavy): vertical particles; others: horizontal
        let isVertical = (intensity == .heavy)

        let spawn = SKAction.sequence([
            SKAction.run { [weak self] in
                guard let self = self else { return }
                for _ in 0..<count {
                    let streakSize: CGSize
                    let startPos: CGPoint
                    let moveAction: SKAction

                    if isVertical {
                        // Vertical streaks for Venus updrafts
                        streakSize = CGSize(
                            width: CGFloat.random(in: 1...2),
                            height: CGFloat.random(in: 15...40)
                        )
                        startPos = CGPoint(
                            x: CGFloat.random(in: 50...self.size.width - 50),
                            y: -20
                        )
                        moveAction = SKAction.moveBy(
                            x: CGFloat.random(in: -30...30),
                            y: self.size.height + 60,
                            duration: Double(self.size.height / speed)
                        )
                    } else {
                        // Horizontal streaks for Mars/Jupiter
                        streakSize = CGSize(
                            width: CGFloat.random(in: 15...40),
                            height: CGFloat.random(in: 1...2)
                        )
                        startPos = CGPoint(
                            x: self.size.width + 20,
                            y: CGFloat.random(in: 100...self.size.height - 50)
                        )
                        moveAction = SKAction.moveBy(
                            x: -(self.size.width + 60),
                            y: CGFloat.random(in: -30...30),
                            duration: Double(self.size.width / speed)
                        )
                    }

                    let streak = SKShapeNode(rectOf: streakSize)
                    streak.fillColor = color.withAlphaComponent(alpha)
                    streak.strokeColor = .clear
                    streak.position = startPos
                    streak.zPosition = 5
                    self.addChild(streak)

                    streak.run(SKAction.sequence([moveAction, SKAction.removeFromParent()]))
                }
            },
            SKAction.wait(forDuration: Double.random(in: 0.15...0.4))
        ])
        run(SKAction.repeatForever(spawn), withKey: key)
    }

    // MARK: - Atmosphere Haze (Titan)
    func createAtmosphereHaze() {
        // Semi-transparent orange gradient overlay at top of screen
        let haze = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height * 0.4))
        haze.position = CGPoint(x: size.width / 2, y: size.height * 0.8)
        haze.fillColor = SKColor(red: 0.5, green: 0.4, blue: 0.2, alpha: 0.15)
        haze.strokeColor = .clear
        haze.zPosition = 4
        haze.name = "atmosphereHaze"
        addChild(haze)

        // Drifting haze particles
        let spawn = SKAction.sequence([
            SKAction.run { [weak self] in
                guard let self = self else { return }
                let cloud = SKShapeNode(ellipseOf: CGSize(
                    width: CGFloat.random(in: 60...120),
                    height: CGFloat.random(in: 15...30)
                ))
                cloud.fillColor = SKColor(red: 0.5, green: 0.4, blue: 0.2, alpha: 0.08)
                cloud.strokeColor = .clear
                cloud.position = CGPoint(
                    x: self.size.width + 60,
                    y: CGFloat.random(in: self.size.height * 0.4...self.size.height)
                )
                cloud.zPosition = 4
                self.addChild(cloud)

                let drift = SKAction.moveBy(x: -(self.size.width + 150), y: 0, duration: Double.random(in: 8...14))
                cloud.run(SKAction.sequence([drift, SKAction.removeFromParent()]))
            },
            SKAction.wait(forDuration: Double.random(in: 1.5...3.0))
        ])
        run(SKAction.repeatForever(spawn), withKey: "atmosphereHaze")
    }

    // MARK: - Ice Surface Shimmer (Europa)
    func createIceShimmer() {
        // Periodic sparkle particles on the lower portion of screen (near platforms)
        let sparkle = SKAction.sequence([
            SKAction.run { [weak self] in
                guard let self = self else { return }
                for _ in 0..<3 {
                    let spark = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...3))
                    spark.fillColor = SKColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 0.8)
                    spark.strokeColor = .clear
                    spark.position = CGPoint(
                        x: CGFloat.random(in: 20...self.size.width - 20),
                        y: CGFloat.random(in: 160...240)
                    )
                    spark.zPosition = 6
                    self.addChild(spark)

                    let twinkle = SKAction.sequence([
                        SKAction.fadeIn(withDuration: 0.2),
                        SKAction.wait(forDuration: Double.random(in: 0.1...0.3)),
                        SKAction.fadeOut(withDuration: 0.3),
                        SKAction.removeFromParent()
                    ])
                    spark.run(twinkle)
                }
            },
            SKAction.wait(forDuration: Double.random(in: 0.3...0.8))
        ])
        run(SKAction.repeatForever(sparkle), withKey: "iceShimmer")
    }

    // MARK: - Heat Shimmer Effect (Mercury)
    func createHeatShimmer() {
        guard gameState.currentMode == .campaign && gameState.currentLevelId == 7 else { return }

        let shimmer = SKAction.sequence([
            SKAction.run { [weak self] in
                guard let self = self, let rocket = self.rocket else { return }
                // Slight visual distortion by rapidly offsetting
                let dx = CGFloat.random(in: -1.5...1.5)
                let dy = CGFloat.random(in: -0.5...0.5)
                let distort = SKAction.sequence([
                    SKAction.moveBy(x: dx, y: dy, duration: 0.05),
                    SKAction.moveBy(x: -dx, y: -dy, duration: 0.05)
                ])
                rocket.run(distort)
            },
            SKAction.wait(forDuration: 0.3)
        ])
        run(SKAction.repeatForever(shimmer), withKey: "heatShimmer")
    }

    // MARK: - Volcanic Eruptions (Io)
    func createVolcanicEruption() {
        guard gameState.currentMode == .campaign && gameState.currentLevelId == 9 else { return }

        let erupt = SKAction.sequence([
            SKAction.wait(forDuration: Double.random(in: 2.0...5.0)),
            SKAction.run { [weak self] in
                guard let self = self else { return }
                let eruptX = CGFloat.random(in: 50...self.size.width - 50)
                let eruptY: CGFloat = 180

                for _ in 0..<8 {
                    let radius = CGFloat.random(in: 3...7)
                    let particle = SKShapeNode(circleOfRadius: radius)
                    particle.fillColor = [SKColor.orange, SKColor.red, SKColor.yellow].randomElement()!
                    particle.strokeColor = .clear
                    particle.position = CGPoint(x: eruptX, y: eruptY)
                    particle.zPosition = 15

                    // Deadly volcanic debris — collides with rocket
                    particle.physicsBody = SKPhysicsBody(circleOfRadius: radius)
                    particle.physicsBody?.isDynamic = false
                    particle.physicsBody?.categoryBitMask = self.groundCategory
                    particle.physicsBody?.contactTestBitMask = self.rocketCategory

                    self.addChild(particle)

                    let dx = CGFloat.random(in: -40...40)
                    let dy = CGFloat.random(in: 80...200)

                    let move = SKAction.moveBy(x: dx, y: dy, duration: Double.random(in: 0.6...1.2))
                    let removePhysics = SKAction.run { particle.physicsBody = nil }
                    let fall = SKAction.moveBy(x: 0, y: -dy * 1.5, duration: 0.8)
                    let fade = SKAction.fadeOut(withDuration: 0.5)
                    let seq = SKAction.sequence([move, removePhysics, SKAction.group([fall, fade]), SKAction.removeFromParent()])
                    particle.run(seq)
                }
            }
        ])
        run(SKAction.repeatForever(erupt), withKey: "volcanicEruption")
    }
}
