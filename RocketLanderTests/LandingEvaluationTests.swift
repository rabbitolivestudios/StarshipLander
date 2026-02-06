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
        // V≤70, H≤50 → safe
        let result = LandingThresholds.evaluate(
            verticalSpeed: 69, horizontalSpeed: 49,
            rotation: 0.03, platform: .a
        )
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.speedBand, .safe)
    }

    func testPlatformA_HardBand() {
        // V>70 ≤100, H>50 ≤80 → hard
        let result = LandingThresholds.evaluate(
            verticalSpeed: 71, horizontalSpeed: 51,
            rotation: 0.03, platform: .a
        )
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.speedBand, .hard)
    }

    func testPlatformA_FailBand() {
        // V>100, H>80 → fail
        let result = LandingThresholds.evaluate(
            verticalSpeed: 101, horizontalSpeed: 81,
            rotation: 0.03, platform: .a
        )
        XCTAssertFalse(result.success)
        XCTAssertEqual(result.speedBand, .fail)
    }

    // MARK: - Platform B Band Tests

    func testPlatformB_SafeBand() {
        // V≤50, H≤40 → safe
        let result = LandingThresholds.evaluate(
            verticalSpeed: 49, horizontalSpeed: 39,
            rotation: 0.03, platform: .b
        )
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.speedBand, .safe)
    }

    func testPlatformB_HardBand() {
        // V>50 ≤75, H>40 ≤60 → hard
        let result = LandingThresholds.evaluate(
            verticalSpeed: 51, horizontalSpeed: 41,
            rotation: 0.03, platform: .b
        )
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.speedBand, .hard)
    }

    func testPlatformB_FailBand() {
        // V>75, H>60 → fail
        let result = LandingThresholds.evaluate(
            verticalSpeed: 76, horizontalSpeed: 61,
            rotation: 0.03, platform: .b
        )
        XCTAssertFalse(result.success)
        XCTAssertEqual(result.speedBand, .fail)
    }

    // MARK: - Platform C Band Tests

    func testPlatformC_SafeBand() {
        // V≤33, H≤28 → safe
        let result = LandingThresholds.evaluate(
            verticalSpeed: 32, horizontalSpeed: 27,
            rotation: 0.03, platform: .c
        )
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.speedBand, .safe)
    }

    func testPlatformC_HardBand() {
        // V>33 ≤52, H>28 ≤48 → hard
        let result = LandingThresholds.evaluate(
            verticalSpeed: 34, horizontalSpeed: 29,
            rotation: 0.03, platform: .c
        )
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.speedBand, .hard)
    }

    func testPlatformC_FailBand() {
        // V>52, H>48 → fail
        let result = LandingThresholds.evaluate(
            verticalSpeed: 53, horizontalSpeed: 49,
            rotation: 0.03, platform: .c
        )
        XCTAssertFalse(result.success)
        XCTAssertEqual(result.speedBand, .fail)
    }

    // MARK: - Exact Boundary Tests

    func testExactBoundary_Safe() {
        // V=70 on A → .safe (≤ is safe)
        let result = LandingThresholds.evaluate(
            verticalSpeed: 70, horizontalSpeed: 5,
            rotation: 0.03, platform: .a
        )
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.speedBand, .safe)
    }

    func testExactBoundary_Hard() {
        // V=100 on A → .hard (≤ is hard)
        let result = LandingThresholds.evaluate(
            verticalSpeed: 100, horizontalSpeed: 5,
            rotation: 0.03, platform: .a
        )
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.speedBand, .hard)
    }

    func testExactBoundary_HorizontalSafe() {
        // H=50 on A → .safe (≤ is safe)
        let result = LandingThresholds.evaluate(
            verticalSpeed: 5, horizontalSpeed: 50,
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
        // Platform A: safeV=70, hardV=100
        XCTAssertEqual(LandingThresholds.verticalBand(70, platform: .a), .safe)
        XCTAssertEqual(LandingThresholds.verticalBand(71, platform: .a), .hard)
        XCTAssertEqual(LandingThresholds.verticalBand(100, platform: .a), .hard)
        XCTAssertEqual(LandingThresholds.verticalBand(101, platform: .a), .fail)
    }

    func testHorizontalBandClassification() {
        // Platform A: safeH=50, hardH=80
        XCTAssertEqual(LandingThresholds.horizontalBand(50, platform: .a), .safe)
        XCTAssertEqual(LandingThresholds.horizontalBand(51, platform: .a), .hard)
        XCTAssertEqual(LandingThresholds.horizontalBand(80, platform: .a), .hard)
        XCTAssertEqual(LandingThresholds.horizontalBand(81, platform: .a), .fail)
    }
}
