import XCTest
@testable import RocketLander

final class ScoringTests: XCTestCase {

    // MARK: - Helpers

    private let sceneWidth: CGFloat = 393  // iPhone 16 Pro width in points

    /// Convenience: call the static scoring function with named defaults
    private func score(
        verticalSpeed: CGFloat = 0,
        horizontalSpeed: CGFloat = 0,
        rotation: CGFloat = 0,
        approachSpeed: CGFloat = 0,
        fuel: Double = 100,
        platform: LandingPlatform = .c,
        speedBand: SpeedBand = .safe,
        rocketOffset: CGFloat = 0  // offset from platform center
    ) -> Int {
        let rocketX = platform.xFraction * sceneWidth + rocketOffset
        return ScoringHelper.calculateScore(
            verticalSpeed: verticalSpeed,
            horizontalSpeed: horizontalSpeed,
            rotation: rotation,
            approachSpeed: approachSpeed,
            fuel: fuel,
            rocketX: rocketX,
            sceneWidth: sceneWidth,
            platform: platform,
            speedBand: speedBand
        )
    }

    // MARK: - Formula Verification

    func testTheoreticalMax() {
        // 0 speed, 0 rotation, 100% fuel, dead-center platform C
        // Subtotal: 100 + 550 + 450 + 600 + 250 + 150 = 2100
        // Fuel mult: 2.2, Platform mult: 5.0 → 23,100
        let result = score()
        XCTAssertEqual(result, 23100, "Theoretical max should be 23,100")
    }

    func testMinimalScore() {
        // At hard thresholds, max rotation, 0% fuel, at platform edge → minimal score
        let bands = LandingThresholds.bands(for: .a)
        let result = score(
            verticalSpeed: bands.hardVertical,
            horizontalSpeed: bands.hardHorizontal,
            rotation: CGFloat(LandingThresholds.maxRotation),
            approachSpeed: CGFloat(LandingThresholds.approachSpeedScoringThreshold),
            fuel: 0, platform: .a,
            rocketOffset: LandingPlatform.a.width / 2  // at edge → 0 center points
        )
        // All components zeroed at hard thresholds except base (100)
        // Subtotal = 100, fuel mult = 1.0, platform mult = 1.0
        XCTAssertEqual(result, 100, "At hard thresholds with 0 fuel at platform edge, score should be base 100")
    }

    func testFuelMultiplierRange() {
        // Same perfect landing, vary fuel only
        let score0   = score(fuel: 0)
        let score50  = score(fuel: 50)
        let score100 = score(fuel: 100)

        // Subtotal = 2100 for all. Platform C = 5.0x
        // fuel=0:   2100 * 1.0 * 5.0 = 10,500
        // fuel=50:  2100 * 1.6 * 5.0 = 16,800
        // fuel=100: 2100 * 2.2 * 5.0 = 23,100
        XCTAssertEqual(score0, 10500)
        XCTAssertEqual(score50, 16800)
        XCTAssertEqual(score100, 23100)
    }

    func testPlatformMultipliers() {
        // Same perfect landing on each platform
        let scoreA = score(fuel: 100, platform: .a)
        let scoreB = score(fuel: 100, platform: .b)
        let scoreC = score(fuel: 100, platform: .c)

        // Ratios should be 1:2:5
        XCTAssertEqual(scoreA * 2, scoreB, "B should be 2x A")
        XCTAssertEqual(scoreA * 5, scoreC, "C should be 5x A")
    }

    func testSoftLandingComponent() {
        // Isolate vertical speed effect on platform A
        let bands = LandingThresholds.bands(for: .a)
        let perfectV = score(verticalSpeed: 0, fuel: 0, platform: .a, rocketOffset: 0)
        let halfV = score(verticalSpeed: bands.safeVertical / 2, fuel: 0, platform: .a, rocketOffset: 0)
        let maxV = score(verticalSpeed: bands.safeVertical, fuel: 0, platform: .a, rocketOffset: 0)

        XCTAssertGreaterThan(perfectV, halfV)
        XCTAssertGreaterThan(halfV, maxV)
    }

    func testCenterPrecisionComponent() {
        // Dead center vs edge of platform
        let center = score(fuel: 0, platform: .a, rocketOffset: 0)
        let edge = score(fuel: 0, platform: .a, rocketOffset: LandingPlatform.a.width / 2)

        // Center gets full 600 points, edge gets 0
        XCTAssertGreaterThan(center, edge)
        XCTAssertEqual(center - edge, 600, accuracy: 1)
    }

    func testCenterPrecisionCanUseLivePlatformPosition() {
        // Earth moves platforms at runtime, so scoring must use the contacted node's
        // live X position rather than the static LandingPlatform.xFraction value.
        let movedPlatformX = LandingPlatform.b.xFraction * sceneWidth + 35
        let scoreAtLiveCenter = ScoringHelper.calculateScore(
            verticalSpeed: 0,
            horizontalSpeed: 0,
            rotation: 0,
            approachSpeed: 0,
            fuel: 0,
            rocketX: movedPlatformX,
            sceneWidth: sceneWidth,
            platform: .b,
            platformCenterX: movedPlatformX
        )
        let scoreUsingStaticCenter = ScoringHelper.calculateScore(
            verticalSpeed: 0,
            horizontalSpeed: 0,
            rotation: 0,
            approachSpeed: 0,
            fuel: 0,
            rocketX: movedPlatformX,
            sceneWidth: sceneWidth,
            platform: .b
        )

        XCTAssertGreaterThan(scoreAtLiveCenter, scoreUsingStaticCenter)
    }

    func testSubtotalMax() {
        // Perfect landing, fuel 0 (mult 1.0), platform A (mult 1.0)
        let result = score(fuel: 0, platform: .a)
        XCTAssertEqual(result, 2100, "Subtotal before multipliers should be 2100")
    }

    // MARK: - Hard Landing Natural Penalty

    func testHardLandingPartialCredit() {
        // Velocity components use hard threshold as denominator — smooth curve means
        // HARD landings (speed between safe and hard) still get partial credit.
        // Perfect SAFE: 100+550+450+600+250+150 = 2100
        let safeScore = score(fuel: 0, platform: .a, speedBand: .safe)
        XCTAssertEqual(safeScore, 2100)

        // HARD landing at midpoint of hard band — gets meaningful partial credit
        let bands = LandingThresholds.bands(for: .a)
        let midV = (bands.safeVertical + bands.hardVertical) / 2
        let midH = (bands.safeHorizontal + bands.hardHorizontal) / 2
        let hardScore = score(
            verticalSpeed: midV,
            horizontalSpeed: midH,
            fuel: 0, platform: .a, speedBand: .hard
        )
        // Should be less than perfect safe but still meaningful
        XCTAssertGreaterThan(hardScore, 1100, "HARD landing should get partial credit")
        XCTAssertLessThan(hardScore, safeScore, "HARD should be less than perfect SAFE")
    }

    // MARK: - HARD-C > SAFE-B > SAFE-A Constraint

    func testHardCBeatsSafeB() {
        // A HARD landing on C should score better than a SAFE landing on B
        // at multiple fuel levels.
        // HARD-C: partial credit on velocity components + 5.0x platform
        // SAFE-B (perfect): full subtotal but only 2.0x platform
        let bands = LandingThresholds.bands(for: .c)
        for fuel in stride(from: 0.0, through: 100.0, by: 25.0) {
            let hardC = score(
                verticalSpeed: bands.safeVertical + 1,  // just into HARD band
                horizontalSpeed: bands.safeHorizontal + 1,
                fuel: fuel, platform: .c, speedBand: .hard
            )
            let safeB = score(fuel: fuel, platform: .b, speedBand: .safe)

            XCTAssertGreaterThan(hardC, safeB,
                "HARD-C (\(hardC)) should beat perfect SAFE-B (\(safeB)) at fuel \(fuel)%")
        }
    }

    func testHardCBeatsSafeA() {
        let bands = LandingThresholds.bands(for: .c)
        for fuel in stride(from: 0.0, through: 100.0, by: 25.0) {
            let hardC = score(
                verticalSpeed: bands.safeVertical + 1,
                horizontalSpeed: bands.safeHorizontal + 1,
                fuel: fuel, platform: .c, speedBand: .hard
            )
            let safeA = score(fuel: fuel, platform: .a, speedBand: .safe)

            XCTAssertGreaterThan(hardC, safeA,
                "HARD-C (\(hardC)) should beat perfect SAFE-A (\(safeA)) at fuel \(fuel)%")
        }
    }

    func testNoPenaltyDiscontinuity() {
        // Score at V=32 (just under SAFE threshold on C) should be close to
        // score at V=34 (just into HARD band on C). Smooth curve = no cliff.
        let bandsC = LandingThresholds.bands(for: .c)
        let justSafe = score(
            verticalSpeed: bandsC.safeVertical - 1,
            horizontalSpeed: bandsC.safeHorizontal - 1,
            fuel: 75, platform: .c, speedBand: .safe
        )
        let justHard = score(
            verticalSpeed: bandsC.safeVertical + 1,
            horizontalSpeed: bandsC.safeHorizontal + 1,
            fuel: 75, platform: .c, speedBand: .hard
        )

        let gap = abs(justSafe - justHard)
        XCTAssertLessThan(gap, 500,
            "Score gap at SAFE/HARD boundary should be small (was \(gap)): SAFE=\(justSafe), HARD=\(justHard)")
    }

    func testApproachSpeedImpact() {
        // Zero approach speed vs max approach speed should differ by 150 pts (component range)
        let zeroApproach = score(
            approachSpeed: 0,
            fuel: 0, platform: .a, speedBand: .safe
        )
        let maxApproach = score(
            approachSpeed: CGFloat(LandingThresholds.approachSpeedScoringThreshold),
            fuel: 0, platform: .a, speedBand: .safe
        )

        let diff = zeroApproach - maxApproach
        XCTAssertEqual(diff, 150, accuracy: 1,
            "Approach component should contribute 150 points (was \(diff))")
    }

    // MARK: - Realistic Best-Achievable Scenarios

    /// Realistic inputs for a near-perfect human landing
    private func realisticScore(
        fuel: Double,
        platform: LandingPlatform
    ) -> Int {
        return score(
            verticalSpeed: 2.0,
            horizontalSpeed: 1.0,
            rotation: 0.005,
            approachSpeed: 10.0,
            fuel: fuel,
            platform: platform,
            rocketOffset: 3.0
        )
    }

    func testRealisticBestScoreClassic() {
        let scoreA = realisticScore(fuel: 75, platform: .a)
        let scoreB = realisticScore(fuel: 75, platform: .b)
        let scoreC = realisticScore(fuel: 75, platform: .c)

        XCTAssertGreaterThan(scoreA, 2500)
        XCTAssertGreaterThan(scoreB, 5000)
        XCTAssertGreaterThan(scoreC, 12000)
        XCTAssertGreaterThan(scoreC, scoreB)
        XCTAssertGreaterThan(scoreB, scoreA)
    }

    func testRealisticBestScorePerLevel() {
        let fuelByLevel: [Int: Double] = [
            1: 85, 2: 80, 3: 78, 4: 75, 5: 72,
            6: 68, 7: 65, 8: 62, 9: 58, 10: 52
        ]

        var previousScoreC: Int = Int.max
        for levelId in 1...10 {
            let fuel = fuelByLevel[levelId]!
            let scoreC = realisticScore(fuel: fuel, platform: .c)

            XCTAssertGreaterThan(scoreC, 6000, "Level \(levelId) should produce meaningful score on C")

            if levelId > 1 {
                XCTAssertLessThan(scoreC, previousScoreC,
                    "Level \(levelId) with less fuel should score lower than level \(levelId - 1)")
            }
            previousScoreC = scoreC
        }
    }

    func testScoreDecreaseWithFuel() {
        let highFuel = realisticScore(fuel: 85, platform: .c)
        let lowFuel = realisticScore(fuel: 52, platform: .c)

        XCTAssertGreaterThan(highFuel, lowFuel)
        let ratio = Double(highFuel) / Double(lowFuel)
        XCTAssertGreaterThan(ratio, 1.15, "85% vs 52% fuel should produce >15% score difference")
    }

    func testPlatformCAlwaysHighest() {
        for fuel in stride(from: 20.0, through: 100.0, by: 20.0) {
            let a = realisticScore(fuel: fuel, platform: .a)
            let b = realisticScore(fuel: fuel, platform: .b)
            let c = realisticScore(fuel: fuel, platform: .c)
            XCTAssertGreaterThan(c, b, "C > B at fuel \(fuel)")
            XCTAssertGreaterThan(b, a, "B > A at fuel \(fuel)")
        }
    }
}
