import Foundation
@testable import RocketLander

/// Test-only replica of the scoring formula from GameScene+Scoring.swift.
/// Kept in the test target so the app code remains untouched.
/// Constants must match GameScene's static properties exactly.
enum ScoringHelper {

    // Constants matching GameScene (GameScene.swift lines 55-58)
    static let maxSafeVerticalSpeed: CGFloat = 40.0
    static let maxSafeHorizontalSpeed: CGFloat = 25.0
    static let maxSafeRotation: CGFloat = 0.05
    static let maxSafeApproachSpeed: CGFloat = 80.0

    /// Pure scoring calculation — replicates GameScene.calculateScore() exactly.
    static func calculateScore(
        verticalSpeed: CGFloat,
        horizontalSpeed: CGFloat,
        rotation: CGFloat,
        approachSpeed: CGFloat,
        fuel: Double,
        rocketX: CGFloat,
        sceneWidth: CGFloat,
        platform: LandingPlatform
    ) -> Int {
        var subtotal: Double = 100

        // 1. SOFT LANDING (0-500 points)
        let verticalRatio = min(1.0, verticalSpeed / maxSafeVerticalSpeed)
        let softLandingScore = 500.0 * pow(1.0 - verticalRatio, 2)
        subtotal += softLandingScore

        // 2. HORIZONTAL PRECISION (0-400 points)
        let horizontalRatio = min(1.0, horizontalSpeed / maxSafeHorizontalSpeed)
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
        let rotationRatio = min(1.0, Double(rotation) / maxSafeRotation)
        let rotationScore = 250.0 * pow(1.0 - rotationRatio, 2)
        subtotal += rotationScore

        // 5. APPROACH CONTROL (0-150 points)
        let approachRatio = min(1.0, Double(approachSpeed) / maxSafeApproachSpeed)
        let approachScore = 150.0 * pow(1.0 - approachRatio, 2)
        subtotal += approachScore

        // Subtotal max: 100 + 500 + 400 + 600 + 250 + 150 = 2000

        // 6. FUEL MULTIPLIER (1.0x to 2.0x)
        let fuelMultiplier = 1.0 + (fuel / 100.0) * 1.0

        // 7. PLATFORM MULTIPLIER
        let platformMultiplier = platform.multiplier

        // Final score
        let totalScore = Int(subtotal * fuelMultiplier * platformMultiplier)

        return totalScore
    }
}
