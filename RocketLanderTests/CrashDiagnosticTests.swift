import XCTest
@testable import RocketLander

final class CrashDiagnosticTests: XCTestCase {

    // MARK: - Single Cause Tests

    func testTiltTooHigh() {
        let result = LandingMessages.diagnosticCrashMessage(
            verticalSpeed: 20, horizontalSpeed: 10, rotation: 0.15,
            approachSpeed: 30, platform: .a, hitTerrain: false
        )
        XCTAssertTrue(result.primaryMessage.contains("Tilt too high"))
        XCTAssertTrue(result.primaryMessage.contains("°"))
        XCTAssertNil(result.secondaryHint)
    }

    func testVerticalTooFast() {
        // V=150 exceeds Platform A's FAIL threshold (>120)
        let result = LandingMessages.diagnosticCrashMessage(
            verticalSpeed: 150, horizontalSpeed: 10, rotation: 0.02,
            approachSpeed: 30, platform: .a, hitTerrain: false
        )
        XCTAssertTrue(result.primaryMessage.contains("Vertical speed too high"))
        XCTAssertNil(result.secondaryHint)
    }

    func testHorizontalTooFast() {
        // H=110 exceeds Platform A's FAIL threshold (>100)
        let result = LandingMessages.diagnosticCrashMessage(
            verticalSpeed: 20, horizontalSpeed: 110, rotation: 0.02,
            approachSpeed: 30, platform: .a, hitTerrain: false
        )
        XCTAssertTrue(result.primaryMessage.contains("Horizontal drift too high"))
        XCTAssertNil(result.secondaryHint)
    }

    func testTerrainCollision() {
        let result = LandingMessages.diagnosticCrashMessage(
            verticalSpeed: 20, horizontalSpeed: 10, rotation: 0.02,
            approachSpeed: 30, platform: .a, hitTerrain: true
        )
        XCTAssertTrue(result.primaryMessage.contains("Missed the platform"))
        XCTAssertNil(result.secondaryHint)
    }

    func testOutOfBounds() {
        let result = LandingMessages.diagnosticCrashMessage(
            verticalSpeed: 20, horizontalSpeed: 10, rotation: 0.02,
            approachSpeed: 30, platform: .a, hitTerrain: false
        )
        XCTAssertTrue(result.primaryMessage.contains("Ship lost"))
        XCTAssertNil(result.secondaryHint)
    }

    // MARK: - Precedence Tests

    func testPrecedenceOrder_TiltOverVertical() {
        let result = LandingMessages.diagnosticCrashMessage(
            verticalSpeed: 150, horizontalSpeed: 10, rotation: 0.15,
            approachSpeed: 30, platform: .a, hitTerrain: false
        )
        XCTAssertTrue(result.primaryMessage.contains("Tilt too high"))
        XCTAssertNotNil(result.secondaryHint)
        XCTAssertTrue(result.secondaryHint!.contains("Vertical speed"))
    }

    func testPrecedenceOrder_VerticalOverHorizontal() {
        let result = LandingMessages.diagnosticCrashMessage(
            verticalSpeed: 150, horizontalSpeed: 110, rotation: 0.02,
            approachSpeed: 30, platform: .a, hitTerrain: false
        )
        XCTAssertTrue(result.primaryMessage.contains("Vertical speed"))
        XCTAssertNotNil(result.secondaryHint)
        XCTAssertTrue(result.secondaryHint!.contains("Horizontal drift"))
    }

    // MARK: - Secondary Hint Tests

    func testSecondaryHintPresent() {
        let result = LandingMessages.diagnosticCrashMessage(
            verticalSpeed: 150, horizontalSpeed: 110, rotation: 0.15,
            approachSpeed: 100, platform: .a, hitTerrain: false
        )
        XCTAssertTrue(result.primaryMessage.contains("Tilt too high"))
        XCTAssertNotNil(result.secondaryHint)
        XCTAssertTrue(result.secondaryHint!.contains("Vertical speed"))
    }

    // MARK: - Determinism Test

    func testDeterminism() {
        let inputs: [(CGFloat, CGFloat, CGFloat, CGFloat, LandingPlatform?, Bool)] = [
            (150, 110, 0.15, 100, .a, false),
            (20, 10, 0.02, 30, .b, true),
            (90, 80, 0.08, 90, .c, false),
        ]

        for (vSpeed, hSpeed, rot, aSpeed, plat, terrain) in inputs {
            let first = LandingMessages.diagnosticCrashMessage(
                verticalSpeed: vSpeed, horizontalSpeed: hSpeed,
                rotation: rot, approachSpeed: aSpeed,
                platform: plat, hitTerrain: terrain
            )

            for _ in 0..<100 {
                let result = LandingMessages.diagnosticCrashMessage(
                    verticalSpeed: vSpeed, horizontalSpeed: hSpeed,
                    rotation: rot, approachSpeed: aSpeed,
                    platform: plat, hitTerrain: terrain
                )
                XCTAssertEqual(result.primaryMessage, first.primaryMessage)
                XCTAssertEqual(result.secondaryHint, first.secondaryHint)
            }
        }
    }

    // MARK: - Edge Case: All Safe Values

    func testAllSafeWithTerrain() {
        let result = LandingMessages.diagnosticCrashMessage(
            verticalSpeed: 20, horizontalSpeed: 10, rotation: 0.03,
            approachSpeed: 40, platform: .a, hitTerrain: true
        )
        XCTAssertTrue(result.primaryMessage.contains("Missed the platform"))
    }

    func testAllSafeOutOfBounds() {
        let result = LandingMessages.diagnosticCrashMessage(
            verticalSpeed: 20, horizontalSpeed: 10, rotation: 0.03,
            approachSpeed: 40, platform: .a, hitTerrain: false
        )
        XCTAssertTrue(result.primaryMessage.contains("Ship lost"))
    }

    // MARK: - Value Display Tests

    func testTiltValueDisplayedInDegrees() {
        let rotation: CGFloat = 0.20  // ~11.5°
        let result = LandingMessages.diagnosticCrashMessage(
            verticalSpeed: 20, horizontalSpeed: 10, rotation: rotation,
            approachSpeed: 30, platform: .a, hitTerrain: false
        )
        XCTAssertTrue(result.primaryMessage.contains("11.5"))
    }

    func testVerticalSpeedValueDisplayed() {
        // V=150 exceeds Platform A's FAIL threshold
        let result = LandingMessages.diagnosticCrashMessage(
            verticalSpeed: 150, horizontalSpeed: 10, rotation: 0.02,
            approachSpeed: 30, platform: .a, hitTerrain: false
        )
        XCTAssertTrue(result.primaryMessage.contains("150"))
    }

    // MARK: - Platform-Specific Threshold Tests

    func testPlatformCStricterThanA() {
        // V=60 should fail on C (>55) but pass on A (<120)
        let resultC = LandingMessages.diagnosticCrashMessage(
            verticalSpeed: 60, horizontalSpeed: 10, rotation: 0.02,
            approachSpeed: 30, platform: .c, hitTerrain: false
        )
        let resultA = LandingMessages.diagnosticCrashMessage(
            verticalSpeed: 60, horizontalSpeed: 10, rotation: 0.02,
            approachSpeed: 30, platform: .a, hitTerrain: false
        )
        XCTAssertTrue(resultC.primaryMessage.contains("Vertical speed too high"),
            "V=60 should trigger vertical crash on Platform C")
        XCTAssertTrue(resultA.primaryMessage.contains("Ship lost"),
            "V=60 should not trigger speed crash on Platform A")
    }

    func testNilPlatformDefaultsToPlatformC() {
        // nil platform should use Platform C (strictest) thresholds
        let result = LandingMessages.diagnosticCrashMessage(
            verticalSpeed: 60, horizontalSpeed: 10, rotation: 0.02,
            approachSpeed: 30, platform: nil, hitTerrain: false
        )
        XCTAssertTrue(result.primaryMessage.contains("Vertical speed too high"),
            "nil platform should default to C's thresholds (V>55 = fail)")
    }
}
