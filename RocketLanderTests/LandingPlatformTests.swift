import XCTest
@testable import RocketLander

final class LandingPlatformTests: XCTestCase {

    func testMultipliers() {
        XCTAssertEqual(LandingPlatform.a.multiplier, 1.0)
        XCTAssertEqual(LandingPlatform.b.multiplier, 2.0)
        XCTAssertEqual(LandingPlatform.c.multiplier, 5.0)
    }

    func testStars() {
        XCTAssertEqual(LandingPlatform.a.stars, 1)
        XCTAssertEqual(LandingPlatform.b.stars, 2)
        XCTAssertEqual(LandingPlatform.c.stars, 3)
    }

    func testWidths() {
        XCTAssertEqual(LandingPlatform.a.width, 130)
        XCTAssertEqual(LandingPlatform.b.width, 110)
        XCTAssertEqual(LandingPlatform.c.width, 80)
    }

    func testPositions() {
        XCTAssertEqual(LandingPlatform.a.xFraction, 0.18)
        XCTAssertEqual(LandingPlatform.b.xFraction, 0.50)
        XCTAssertEqual(LandingPlatform.c.xFraction, 0.82)
    }

    func testAllCases() {
        XCTAssertEqual(LandingPlatform.allCases.count, 3)
    }
}
