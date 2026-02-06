import SpriteKit

// MARK: - Scoring Logic
extension GameScene {

    func calculateScore(verticalSpeed: CGFloat, horizontalSpeed: CGFloat, rotation: CGFloat, approachSpeed: CGFloat, platform: LandingPlatform, speedBand: SpeedBand) -> Int {
        // === CONTINUOUS SCORING SYSTEM WITH FUEL + PLATFORM MULTIPLIER ===
        // Max possible: ~23,100 points (2100 base x 2.2 fuel x 5.0 platform)

        let bands = LandingThresholds.bands(for: platform)

        var subtotal: Double = 100

        // 1. SOFT LANDING (0-550 points) — single quadratic curve using hard threshold
        //    Smooth from max at speed=0 to 0 at hard threshold. HARD landings get
        //    partial credit (speed between safe and hard still scores > 0).
        let verticalRatio = min(1.0, verticalSpeed / bands.hardVertical)
        let softLandingScore = 550.0 * pow(1.0 - verticalRatio, 2)
        subtotal += softLandingScore

        // 2. HORIZONTAL PRECISION (0-450 points) — same smooth curve using hard threshold
        let horizontalRatio = min(1.0, horizontalSpeed / bands.hardHorizontal)
        let horizontalScore = 450.0 * pow(1.0 - horizontalRatio, 2)
        subtotal += horizontalScore

        // 3. PLATFORM CENTER (0-600 points) — use the specific platform's position
        let platformX = platform.xFraction * size.width
        let distanceFromCenter = abs(rocket.position.x - platformX)
        let platformHalfWidth = platform.width / 2
        let centerRatio = min(1.0, distanceFromCenter / platformHalfWidth)
        let centerScore = 600.0 * pow(1.0 - centerRatio, 2)
        subtotal += centerScore

        // 4. ROTATION PRECISION (0-250 points) — smooth curve using hard tilt threshold
        let rotationRatio = min(1.0, Double(rotation) / LandingThresholds.hardTilt)
        let rotationScore = 250.0 * pow(1.0 - rotationRatio, 2)
        subtotal += rotationScore

        // 5. APPROACH CONTROL (0-150 points) — scoring quality metric, not a gate
        let approachRatio = min(1.0, Double(approachSpeed) / LandingThresholds.approachSpeedScoringThreshold)
        let approachScore = 150.0 * pow(1.0 - approachRatio, 2)
        subtotal += approachScore

        // Subtotal max: 100 + 550 + 450 + 600 + 250 + 150 = 2100
        // HARD landings get partial credit (25% of velocity components) instead of zeroing out.

        // 6. FUEL MULTIPLIER (1.0x to 2.2x)
        let fuelMultiplier = 1.0 + (gameState.fuel / 100.0) * 1.2

        // 7. PLATFORM MULTIPLIER
        let platformMultiplier = platform.multiplier

        // Final score
        let totalScore = Int(subtotal * fuelMultiplier * platformMultiplier)

        // Max possible: 2100 x 2.2 x 5.0 = 23,100

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
