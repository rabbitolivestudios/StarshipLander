import XCTest
@testable import RocketLander

final class GameStateTests: XCTestCase {

    private let accelKey = "useAccelerometer"

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: accelKey)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: accelKey)
        super.tearDown()
    }

    func testInitialValues() {
        let state = GameState()
        XCTAssertEqual(state.fuel, 100)
        XCTAssertEqual(state.score, 0)
        XCTAssertFalse(state.gameOver)
        XCTAssertFalse(state.landed)
        XCTAssertEqual(state.verticalVelocity, 0)
        XCTAssertEqual(state.horizontalVelocity, 0)
        XCTAssertEqual(state.rotation, 0)
    }

    func testReset() {
        let state = GameState()
        // Modify state
        state.fuel = 42
        state.score = 5000
        state.gameOver = true
        state.landed = true
        state.verticalVelocity = 30
        state.horizontalVelocity = 15
        state.rotation = 0.03
        state.isThrusting = true
        state.landedPlatform = .c
        state.landingMessage = "Great!"
        state.crashNudge = "Try again"
        state.starsEarned = 3

        state.reset()

        XCTAssertEqual(state.fuel, 100)
        XCTAssertEqual(state.score, 0)
        XCTAssertFalse(state.gameOver)
        XCTAssertFalse(state.landed)
        XCTAssertTrue(state.shouldReset)
        XCTAssertEqual(state.verticalVelocity, 0)
        XCTAssertEqual(state.horizontalVelocity, 0)
        XCTAssertEqual(state.rotation, 0)
        XCTAssertFalse(state.isThrusting)
        XCTAssertFalse(state.isRotatingLeft)
        XCTAssertFalse(state.isRotatingRight)
        XCTAssertNil(state.landedPlatform)
        XCTAssertEqual(state.landingMessage, "")
        XCTAssertEqual(state.crashNudge, "")
        XCTAssertEqual(state.starsEarned, 0)
    }

    func testAccelerometerPersistence() {
        let state = GameState()
        state.useAccelerometer = true
        XCTAssertTrue(UserDefaults.standard.bool(forKey: accelKey))

        state.useAccelerometer = false
        XCTAssertFalse(UserDefaults.standard.bool(forKey: accelKey))
    }
}
