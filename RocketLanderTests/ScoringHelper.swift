import Foundation
@testable import RocketLander

/// Test-only replica of the scoring formula from GameScene+Scoring.swift.
/// Kept in the test target so the app code remains untouched.
/// Constants reference LandingThresholds as the single source of truth.
enum ScoringHelper {

    /// Pure scoring calculation — replicates GameScene.calculateScore() exactly.
    static func calculateScore(
        verticalSpeed: CGFloat,
        horizontalSpeed: CGFloat,
        rotation: CGFloat,
        approachSpeed: CGFloat,
        fuel: Double,
        rocketX: CGFloat,
        sceneWidth: CGFloat,
        platform: LandingPlatform,
        speedBand: SpeedBand = .safe
    ) -> Int {
        let bands = LandingThresholds.bands(for: platform)

        var subtotal: Double = 100

        // 1. SOFT LANDING (0-500 points)
        let verticalRatio = min(1.0, verticalSpeed / bands.safeVertical)
        let softLandingScore = 500.0 * pow(1.0 - verticalRatio, 2)
        subtotal += softLandingScore

        // 2. HORIZONTAL PRECISION (0-400 points)
        let horizontalRatio = min(1.0, horizontalSpeed / bands.safeHorizontal)
        let horizontalScore = 400.0 * pow(1.0 - horizontalRatio, 2)
        subtotal += horizontalScore

        // 3. PLATFORM CENTER (0-600 points)
        let platformX = platform.xFraction * sceneWidth
        let distanceFromCenter = abs(rocketX - platformX)
        let platformHalfWidth = platform.width / 2
        let centerRatio = min(1.0, distanceFromCenter / platformHalfWidth)
        let centerScore = 600.0 * pow(1.0 - centerRatio, 2)
        subtotal += centerScore

        // 4. ROTATION PRECISION (0-250 points)
        let rotationRatio = min(1.0, Double(rotation) / LandingThresholds.maxRotation)
        let rotationScore = 250.0 * pow(1.0 - rotationRatio, 2)
        subtotal += rotationScore

        // 5. APPROACH CONTROL (0-150 points)
        let approachRatio = min(1.0, Double(approachSpeed) / LandingThresholds.approachSpeedScoringThreshold)
        let approachScore = 150.0 * pow(1.0 - approachRatio, 2)
        subtotal += approachScore

        // Subtotal max: 100 + 500 + 400 + 600 + 250 + 150 = 2000
        // HARD landings: no explicit penalty — velocity components naturally zero out.

        // 6. FUEL MULTIPLIER (1.0x to 2.0x)
        let fuelMultiplier = 1.0 + (fuel / 100.0) * 1.0

        // 7. PLATFORM MULTIPLIER
        let platformMultiplier = platform.multiplier

        // Final score
        let totalScore = Int(subtotal * fuelMultiplier * platformMultiplier)

        return totalScore
    }
}
