import XCTest
@testable import RocketLander

final class LandingMessagesTests: XCTestCase {

    func testEliteMessageForPlatformC() {
        // Platform C should return either elite or rare message
        let allElite = Set(LandingMessages.eliteSuccess)
        let allStandard = Set(LandingMessages.standardSuccess)

        // Run multiple times to get a sample
        var gotEliteOrRare = false
        for _ in 0..<100 {
            let msg = LandingMessages.successMessage(platform: .c, score: 1000)
            if allElite.contains(msg) || msg == LandingMessages.rareSuccess {
                gotEliteOrRare = true
                break
            }
            // Even if randomness hits standard, it should be from known pools
            XCTAssertTrue(allElite.contains(msg) || allStandard.contains(msg) || msg == LandingMessages.rareSuccess,
                "Unexpected message: \(msg)")
        }
        XCTAssertTrue(gotEliteOrRare, "Platform C should produce elite messages")
    }

    func testStandardMessageForPlatformA() {
        let allStandard = Set(LandingMessages.standardSuccess)

        for _ in 0..<50 {
            let msg = LandingMessages.successMessage(platform: .a, score: 1000)
            // Score 1000 < 4500, so rare is impossible. Platform A → standard pool.
            XCTAssertTrue(allStandard.contains(msg), "Platform A should produce standard messages, got: \(msg)")
        }
    }

    func testRareMessageRequiresHighScore() {
        // With score <= 4500, rare message should never appear
        for _ in 0..<200 {
            let msg = LandingMessages.successMessage(platform: .c, score: 4500)
            XCTAssertNotEqual(msg, LandingMessages.rareSuccess,
                "Rare message should not appear with score <= 4500")
        }
    }

    func testAllMessageArraysNonEmpty() {
        XCTAssertFalse(LandingMessages.standardSuccess.isEmpty)
        XCTAssertFalse(LandingMessages.eliteSuccess.isEmpty)
        XCTAssertFalse(LandingMessages.hardLandingSuccess.isEmpty)
        XCTAssertFalse(LandingMessages.rareSuccess.isEmpty)
    }

    func testHardLandingMessage() {
        let allHard = Set(LandingMessages.hardLandingSuccess)
        for _ in 0..<50 {
            let msg = LandingMessages.successMessage(platform: .a, score: 1000, speedBand: .hard)
            XCTAssertTrue(allHard.contains(msg), "HARD band should produce hard landing message, got: \(msg)")
        }
    }
}
