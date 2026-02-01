import XCTest
@testable import RocketLander

final class CrashDiagnosticTests: XCTestCase {

    // MARK: - Single Cause Tests

    func testTiltTooHigh() {
        let result = LandingMessages.diagnosticCrashMessage(
            verticalSpeed: 20, horizontalSpeed: 10, rotation: 0.15,
            approachSpeed: 30, hitTerrain: false
        )
        XCTAssertTrue(result.primaryMessage.contains("Tilt too high"))
        XCTAssertTrue(result.primaryMessage.contains("°"))
        XCTAssertNil(result.secondaryHint)
    }

    func testVerticalTooFast() {
        let result = LandingMessages.diagnosticCrashMessage(
            verticalSpeed: 60, horizontalSpeed: 10, rotation: 0.02,
            approachSpeed: 30, hitTerrain: false
        )
        XCTAssertTrue(result.primaryMessage.contains("Vertical speed too high"))
        XCTAssertNil(result.secondaryHint)
    }

    func testHorizontalTooFast() {
        let result = LandingMessages.diagnosticCrashMessage(
            verticalSpeed: 20, horizontalSpeed: 35, rotation: 0.02,
            approachSpeed: 30, hitTerrain: false
        )
        XCTAssertTrue(result.primaryMessage.contains("Horizontal drift too high"))
        XCTAssertNil(result.secondaryHint)
    }

    func testApproachTooFast() {
        let result = LandingMessages.diagnosticCrashMessage(
            verticalSpeed: 20, horizontalSpeed: 10, rotation: 0.02,
            approachSpeed: 100, hitTerrain: false
        )
        XCTAssertTrue(result.primaryMessage.contains("Approach speed too high"))
        XCTAssertNil(result.secondaryHint)
    }

    func testTerrainCollision() {
        let result = LandingMessages.diagnosticCrashMessage(
            verticalSpeed: 20, horizontalSpeed: 10, rotation: 0.02,
            approachSpeed: 30, hitTerrain: true
        )
        XCTAssertTrue(result.primaryMessage.contains("Missed the platform"))
        XCTAssertNil(result.secondaryHint)
    }

    func testOutOfBounds() {
        let result = LandingMessages.diagnosticCrashMessage(
            verticalSpeed: 20, horizontalSpeed: 10, rotation: 0.02,
            approachSpeed: 30, hitTerrain: false
        )
        XCTAssertTrue(result.primaryMessage.contains("Ship lost"))
        XCTAssertNil(result.secondaryHint)
    }

    // MARK: - Precedence Tests

    func testPrecedenceOrder_TiltOverVertical() {
        let result = LandingMessages.diagnosticCrashMessage(
            verticalSpeed: 60, horizontalSpeed: 10, rotation: 0.15,
            approachSpeed: 30, hitTerrain: false
        )
        // Tilt is highest priority, should be primary
        XCTAssertTrue(result.primaryMessage.contains("Tilt too high"))
        // Vertical should be secondary
        XCTAssertNotNil(result.secondaryHint)
        XCTAssertTrue(result.secondaryHint!.contains("Vertical speed"))
    }

    func testPrecedenceOrder_VerticalOverHorizontal() {
        let result = LandingMessages.diagnosticCrashMessage(
            verticalSpeed: 60, horizontalSpeed: 35, rotation: 0.02,
            approachSpeed: 30, hitTerrain: false
        )
        XCTAssertTrue(result.primaryMessage.contains("Vertical speed"))
        XCTAssertNotNil(result.secondaryHint)
        XCTAssertTrue(result.secondaryHint!.contains("Horizontal drift"))
    }

    // MARK: - Secondary Hint Tests

    func testSecondaryHintPresent() {
        let result = LandingMessages.diagnosticCrashMessage(
            verticalSpeed: 60, horizontalSpeed: 35, rotation: 0.15,
            approachSpeed: 100, hitTerrain: false
        )
        // Multiple failures — primary is tilt, secondary is vertical
        XCTAssertTrue(result.primaryMessage.contains("Tilt too high"))
        XCTAssertNotNil(result.secondaryHint)
        XCTAssertTrue(result.secondaryHint!.contains("Vertical speed"))
    }

    // MARK: - Determinism Test

    func testDeterminism() {
        let inputs: [(CGFloat, CGFloat, CGFloat, CGFloat, Bool)] = [
            (60, 35, 0.15, 100, false),
            (20, 10, 0.02, 30, true),
            (45, 30, 0.08, 90, false),
        ]

        for (vSpeed, hSpeed, rot, aSpeed, terrain) in inputs {
            let first = LandingMessages.diagnosticCrashMessage(
                verticalSpeed: vSpeed, horizontalSpeed: hSpeed,
                rotation: rot, approachSpeed: aSpeed, hitTerrain: terrain
            )

            // Run 100 times, verify same output
            for _ in 0..<100 {
                let result = LandingMessages.diagnosticCrashMessage(
                    verticalSpeed: vSpeed, horizontalSpeed: hSpeed,
                    rotation: rot, approachSpeed: aSpeed, hitTerrain: terrain
                )
                XCTAssertEqual(result.primaryMessage, first.primaryMessage)
                XCTAssertEqual(result.secondaryHint, first.secondaryHint)
            }
        }
    }

    // MARK: - Edge Case: All Safe Values

    func testAllSafeWithTerrain() {
        // All values safe but hit terrain — should get terrain message
        let result = LandingMessages.diagnosticCrashMessage(
            verticalSpeed: 20, horizontalSpeed: 10, rotation: 0.03,
            approachSpeed: 40, hitTerrain: true
        )
        XCTAssertTrue(result.primaryMessage.contains("Missed the platform"))
    }

    func testAllSafeOutOfBounds() {
        // All values safe but fell off screen
        let result = LandingMessages.diagnosticCrashMessage(
            verticalSpeed: 20, horizontalSpeed: 10, rotation: 0.03,
            approachSpeed: 40, hitTerrain: false
        )
        XCTAssertTrue(result.primaryMessage.contains("Ship lost"))
    }

    // MARK: - Value Display Tests

    func testTiltValueDisplayedInDegrees() {
        let rotation: CGFloat = 0.20  // ~11.5°
        let result = LandingMessages.diagnosticCrashMessage(
            verticalSpeed: 20, horizontalSpeed: 10, rotation: rotation,
            approachSpeed: 30, hitTerrain: false
        )
        // Should contain the degree value
        XCTAssertTrue(result.primaryMessage.contains("11.5"))
    }

    func testVerticalSpeedValueDisplayed() {
        let result = LandingMessages.diagnosticCrashMessage(
            verticalSpeed: 75, horizontalSpeed: 10, rotation: 0.02,
            approachSpeed: 30, hitTerrain: false
        )
        XCTAssertTrue(result.primaryMessage.contains("75"))
    }
}
