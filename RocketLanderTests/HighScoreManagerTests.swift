import XCTest
@testable import RocketLander

final class HighScoreManagerTests: XCTestCase {

    private let storageKey = "topScores"

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: storageKey)
        super.tearDown()
    }

    func testDefaultScoreSeeded() {
        let manager = HighScoreManager()
        XCTAssertEqual(manager.scores.count, 1)
        XCTAssertEqual(manager.scores.first?.name, "Elon")
        XCTAssertEqual(manager.scores.first?.score, 1000)
    }

    func testAddScore() {
        let manager = HighScoreManager()
        manager.addScore(name: "Test", score: 2000)
        XCTAssertEqual(manager.scores.count, 2)
    }

    func testTop3Only() {
        let manager = HighScoreManager()
        manager.addScore(name: "A", score: 5000)
        manager.addScore(name: "B", score: 3000)
        manager.addScore(name: "C", score: 2000)
        // Already had Elon at 1000, now 4 entries → should trim to 3
        XCTAssertEqual(manager.scores.count, 3)
        // Elon (1000) should be dropped
        XCTAssertFalse(manager.scores.contains { $0.name == "Elon" })
    }

    func testSortedDescending() {
        let manager = HighScoreManager()
        manager.addScore(name: "Low", score: 500)
        manager.addScore(name: "High", score: 9000)
        for i in 0..<(manager.scores.count - 1) {
            XCTAssertGreaterThanOrEqual(manager.scores[i].score, manager.scores[i + 1].score)
        }
    }

    func testIsHighScoreWhenFewer() {
        let manager = HighScoreManager()
        // Manager has 1 entry (Elon). < 3 entries, so any score > 0 qualifies.
        XCTAssertTrue(manager.isHighScore(500))
        XCTAssertFalse(manager.isHighScore(0))
    }

    func testIsHighScoreWhenFull() {
        let manager = HighScoreManager()
        manager.addScore(name: "A", score: 5000)
        manager.addScore(name: "B", score: 3000)
        // Now 3 entries: 5000, 3000, 1000
        XCTAssertTrue(manager.isHighScore(2000))   // > 1000 (lowest)
        XCTAssertFalse(manager.isHighScore(500))    // < 1000 (lowest)
        XCTAssertFalse(manager.isHighScore(1000))   // not > lowest
    }

    func testStarsPreserved() {
        let manager = HighScoreManager()
        manager.addScore(name: "StarPlayer", score: 8000, stars: 3)
        let entry = manager.scores.first { $0.name == "StarPlayer" }
        XCTAssertEqual(entry?.stars, 3)
    }

    func testBackwardCompatDecoding() {
        // Simulate old JSON without "stars" field
        let oldJSON = """
        [{"id":"00000000-0000-0000-0000-000000000001","name":"OldPlayer","score":1500}]
        """
        UserDefaults.standard.set(oldJSON.data(using: .utf8), forKey: storageKey)

        let manager = HighScoreManager()
        XCTAssertEqual(manager.scores.count, 1)
        XCTAssertEqual(manager.scores.first?.name, "OldPlayer")
        XCTAssertEqual(manager.scores.first?.stars, 0, "Missing stars should default to 0")
    }

    func testPersistence() {
        let manager1 = HighScoreManager()
        manager1.addScore(name: "Persist", score: 7777, stars: 2)

        // New instance should load saved data
        let manager2 = HighScoreManager()
        let entry = manager2.scores.first { $0.name == "Persist" }
        XCTAssertNotNil(entry)
        XCTAssertEqual(entry?.score, 7777)
        XCTAssertEqual(entry?.stars, 2)
    }
}
