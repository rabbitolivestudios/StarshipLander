import XCTest
@testable import RocketLander

final class GameStateTests: XCTestCase {

    private let accelKey = "useAccelerometer"
    private let gameCenterTrackingKey = "gcAchievementTracking"

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: accelKey)
        UserDefaults.standard.removeObject(forKey: gameCenterTrackingKey)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: accelKey)
        UserDefaults.standard.removeObject(forKey: gameCenterTrackingKey)
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
        state.starsEarned = 3
        state.dailyChallengeWasNewBest = true
        state.dailyRewardResult = DailyRewardResult(baseReward: 1, streakBonus: 3, newStreak: 5)
        state.campaignMilestoneRewards = [CampaignMilestoneReward(requiredStars: 10, blueStarsAwarded: 10)]

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
        XCTAssertEqual(state.starsEarned, 0)
        XCTAssertFalse(state.dailyChallengeWasNewBest)
        XCTAssertNil(state.dailyRewardResult)
        XCTAssertTrue(state.campaignMilestoneRewards.isEmpty)
    }

    func testAccelerometerPersistence() {
        let state = GameState()
        state.useAccelerometer = true
        XCTAssertTrue(UserDefaults.standard.bool(forKey: accelKey))

        state.useAccelerometer = false
        XCTAssertFalse(UserDefaults.standard.bool(forKey: accelKey))
    }

    func testGameCenterAttemptTrackingUsesPropertyListSafeKeys() {
        let manager = GameCenterManager()

        manager.recordAttempt(mode: .campaign, levelId: 5)

        let persisted = UserDefaults.standard.dictionary(forKey: gameCenterTrackingKey)
        let attempts = persisted?["attemptsByLevel"] as? [String: Int]
        XCTAssertEqual(attempts?["5"], 1)
    }

    func testGameCenterAttemptTrackingReloadsFromStringKeys() {
        UserDefaults.standard.set([
            "safePlatformCLevels": [2, 4],
            "attemptsByLevel": ["5": 2, "6": 1]
        ], forKey: gameCenterTrackingKey)

        let manager = GameCenterManager()

        XCTAssertEqual(manager.safePlatformCLevels, Set([2, 4]))
        XCTAssertEqual(manager.attemptsByLevel[5], 2)
        XCTAssertEqual(manager.attemptsByLevel[6], 1)
    }
}
