import SpriteKit

// MARK: - Scoring Logic
extension GameScene {

    func calculateScore(verticalSpeed: CGFloat, horizontalSpeed: CGFloat, rotation: CGFloat, approachSpeed: CGFloat, platform: LandingPlatform, speedBand: SpeedBand) -> Int {
        // === CONTINUOUS SCORING SYSTEM WITH FUEL + PLATFORM MULTIPLIER ===
        // Max possible: ~20,000 points (2000 base x 2.0 fuel x 5.0 platform)

        let bands = LandingThresholds.bands(for: platform)

        var subtotal: Double = 100

        // 1. SOFT LANDING (0-500 points) — scaled to platform's safe vertical threshold
        let verticalRatio = min(1.0, verticalSpeed / bands.safeVertical)
        let softLandingScore = 500.0 * pow(1.0 - verticalRatio, 2)
        subtotal += softLandingScore

        // 2. HORIZONTAL PRECISION (0-400 points) — scaled to platform's safe horizontal threshold
        let horizontalRatio = min(1.0, horizontalSpeed / bands.safeHorizontal)
        let horizontalScore = 400.0 * pow(1.0 - horizontalRatio, 2)
        subtotal += horizontalScore

        // 3. PLATFORM CENTER (0-600 points) — use the specific platform's position
        let platformX = platform.xFraction * size.width
        let distanceFromCenter = abs(rocket.position.x - platformX)
        let platformHalfWidth = platform.width / 2
        let centerRatio = min(1.0, distanceFromCenter / platformHalfWidth)
        let centerScore = 600.0 * pow(1.0 - centerRatio, 2)
        subtotal += centerScore

        // 4. ROTATION PRECISION (0-250 points)
        let rotationRatio = min(1.0, Double(rotation) / LandingThresholds.maxRotation)
        let rotationScore = 250.0 * pow(1.0 - rotationRatio, 2)
        subtotal += rotationScore

        // 5. APPROACH CONTROL (0-150 points) — scoring quality metric, not a gate
        let approachRatio = min(1.0, Double(approachSpeed) / LandingThresholds.approachSpeedScoringThreshold)
        let approachScore = 150.0 * pow(1.0 - approachRatio, 2)
        subtotal += approachScore

        // Subtotal max: 100 + 500 + 400 + 600 + 250 + 150 = 2000
        // HARD landings: no explicit penalty — velocity components naturally zero out
        // (speeds exceed safe threshold = scoring denominator), losing ~45% of subtotal.

        // 6. FUEL MULTIPLIER (1.0x to 2.0x)
        let fuelMultiplier = 1.0 + (gameState.fuel / 100.0) * 1.0

        // 7. PLATFORM MULTIPLIER
        let platformMultiplier = platform.multiplier

        // Final score
        let totalScore = Int(subtotal * fuelMultiplier * platformMultiplier)

        // Max possible: 2000 x 2.0 x 5.0 = 20,000

        return totalScore
    }

    /// Determines which platform was landed on based on rocket position
    func determineLandedPlatform(contactNode: SKNode?) -> LandingPlatform? {
        // Check by contact node name
        if let name = contactNode?.name {
            for platform in LandingPlatform.allCases {
                if name == "platform_\(platform.rawValue)" {
                    return platform
                }
            }
        }

        // Fallback: determine by proximity
        let rocketX = rocket.position.x
        var closestPlatform: LandingPlatform = .a
        var closestDist: CGFloat = .greatestFiniteMagnitude

        for platform in LandingPlatform.allCases {
            let platX = platform.xFraction * size.width
            let dist = abs(rocketX - platX)
            if dist < closestDist {
                closestDist = dist
                closestPlatform = platform
            }
        }

        return closestPlatform
    }
}
