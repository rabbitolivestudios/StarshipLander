import XCTest
@testable import RocketLander

final class LandingEvaluationTests: XCTestCase {

    // MARK: - Rotation Gate Tests

    func testRotationFailure() {
        // Rotation 0.06 should fail on any platform
        for platform in LandingPlatform.allCases {
            let result = LandingThresholds.evaluate(
                verticalSpeed: 10, horizontalSpeed: 5,
                rotation: 0.06, platform: platform
            )
            XCTAssertFalse(result.success, "Rotation 0.06 should fail on \(platform.rawValue)")
            XCTAssertTrue(result.rotationFailed, "rotationFailed should be true")
        }
    }

    func testRotationPass() {
        // Rotation 0.04 should pass (speed-dependent for overall result)
        let result = LandingThresholds.evaluate(
            verticalSpeed: 10, horizontalSpeed: 5,
            rotation: 0.04, platform: .a
        )
        XCTAssertTrue(result.success)
        XCTAssertFalse(result.rotationFailed)
    }

    // MARK: - Platform A Band Tests

    func testPlatformA_SafeBand() {
        let result = LandingThresholds.evaluate(
            verticalSpeed: 79, horizontalSpeed: 59,
            rotation: 0.03, platform: .a
        )
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.speedBand, .safe)
    }

    func testPlatformA_HardBand() {
        let result = LandingThresholds.evaluate(
            verticalSpeed: 81, horizontalSpeed: 61,
            rotation: 0.03, platform: .a
        )
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.speedBand, .hard)
    }

    func testPlatformA_FailBand() {
        let result = LandingThresholds.evaluate(
            verticalSpeed: 121, horizontalSpeed: 101,
            rotation: 0.03, platform: .a
        )
        XCTAssertFalse(result.success)
        XCTAssertEqual(result.speedBand, .fail)
    }

    // MARK: - Platform B Band Tests

    func testPlatformB_SafeBand() {
        let result = LandingThresholds.evaluate(
            verticalSpeed: 54, horizontalSpeed: 44,
            rotation: 0.03, platform: .b
        )
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.speedBand, .safe)
    }

    func testPlatformB_HardBand() {
        let result = LandingThresholds.evaluate(
            verticalSpeed: 56, horizontalSpeed: 46,
            rotation: 0.03, platform: .b
        )
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.speedBand, .hard)
    }

    func testPlatformB_FailBand() {
        let result = LandingThresholds.evaluate(
            verticalSpeed: 86, horizontalSpeed: 76,
            rotation: 0.03, platform: .b
        )
        XCTAssertFalse(result.success)
        XCTAssertEqual(result.speedBand, .fail)
    }

    // MARK: - Platform C Band Tests

    func testPlatformC_SafeBand() {
        let result = LandingThresholds.evaluate(
            verticalSpeed: 34, horizontalSpeed: 29,
            rotation: 0.03, platform: .c
        )
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.speedBand, .safe)
    }

    func testPlatformC_HardBand() {
        let result = LandingThresholds.evaluate(
            verticalSpeed: 36, horizontalSpeed: 31,
            rotation: 0.03, platform: .c
        )
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.speedBand, .hard)
    }

    func testPlatformC_FailBand() {
        let result = LandingThresholds.evaluate(
            verticalSpeed: 56, horizontalSpeed: 51,
            rotation: 0.03, platform: .c
        )
        XCTAssertFalse(result.success)
        XCTAssertEqual(result.speedBand, .fail)
    }

    // MARK: - Exact Boundary Tests

    func testExactBoundary_Safe() {
        // V=80 on A → .safe (≤ is safe)
        let result = LandingThresholds.evaluate(
            verticalSpeed: 80, horizontalSpeed: 5,
            rotation: 0.03, platform: .a
        )
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.speedBand, .safe)
    }

    func testExactBoundary_Hard() {
        // V=120 on A → .hard (≤ is hard)
        let result = LandingThresholds.evaluate(
            verticalSpeed: 120, horizontalSpeed: 5,
            rotation: 0.03, platform: .a
        )
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.speedBand, .hard)
    }

    func testExactBoundary_HorizontalSafe() {
        // H=60 on A → .safe (≤ is safe)
        let result = LandingThresholds.evaluate(
            verticalSpeed: 5, horizontalSpeed: 60,
            rotation: 0.03, platform: .a
        )
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.speedBand, .safe)
    }

    // MARK: - Composite Tests

    func testWorstBandWins() {
        // V in SAFE (V=50 for A), H in HARD (H=70 for A) → result is .hard
        let result = LandingThresholds.evaluate(
            verticalSpeed: 50, horizontalSpeed: 70,
            rotation: 0.03, platform: .a
        )
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.speedBand, .hard, "Worst band (H in HARD) should determine overall band")
    }

    func testRotationOverridesSpeed() {
        // Rotation fail + speed safe → fail, rotationFailed=true
        let result = LandingThresholds.evaluate(
            verticalSpeed: 10, horizontalSpeed: 5,
            rotation: 0.10, platform: .a
        )
        XCTAssertFalse(result.success)
        XCTAssertTrue(result.rotationFailed)
    }

    // MARK: - Band Classification Direct Tests

    func testVerticalBandClassification() {
        XCTAssertEqual(LandingThresholds.verticalBand(80, platform: .a), .safe)
        XCTAssertEqual(LandingThresholds.verticalBand(81, platform: .a), .hard)
        XCTAssertEqual(LandingThresholds.verticalBand(120, platform: .a), .hard)
        XCTAssertEqual(LandingThresholds.verticalBand(121, platform: .a), .fail)
    }

    func testHorizontalBandClassification() {
        XCTAssertEqual(LandingThresholds.horizontalBand(60, platform: .a), .safe)
        XCTAssertEqual(LandingThresholds.horizontalBand(61, platform: .a), .hard)
        XCTAssertEqual(LandingThresholds.horizontalBand(100, platform: .a), .hard)
        XCTAssertEqual(LandingThresholds.horizontalBand(101, platform: .a), .fail)
    }
}
