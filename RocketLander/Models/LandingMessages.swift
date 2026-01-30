import Foundation

struct LandingMessages {
    // MARK: - Success Messages
    static let standardSuccess: [String] = [
        "Landing confirmed.",
        "Precision achieved.",
        "Controlled descent.",
        "Touchdown successful.",
        "Stable landing.",
        "Descent nominal.",
        "Contact confirmed.",
        "Vehicle secured.",
    ]

    static let eliteSuccess: [String] = [
        "Elite landing.",
        "Near-perfect execution.",
        "Outstanding precision.",
        "Textbook landing.",
    ]

    static let rareSuccess = "This was exceptional."

    // MARK: - Crash Messages
    static let crashMessages: [String] = [
        "Descent unstable.",
        "Rapid unscheduled disassembly.",
        "Contact lost.",
        "Vehicle integrity compromised.",
        "Landing aborted.",
        "Structural failure.",
    ]

    static let crashNudges: [String] = [
        "Try a slower approach.",
        "Reduce horizontal drift before landing.",
        "Keep the rocket upright on final approach.",
        "Use short thrust bursts to slow down.",
        "Watch your vertical speed indicator.",
        "Aim for the larger platforms first.",
    ]

    // MARK: - Message Selection

    /// Returns a landing message based on the platform and score
    static func successMessage(platform: LandingPlatform, score: Int) -> String {
        // Rare message: 1 in 50 chance, score > 4500
        if score > 4500 && Int.random(in: 1...50) == 1 {
            return rareSuccess
        }

        // Elite (3-star) landings
        if platform == .c {
            return eliteSuccess.randomElement() ?? standardSuccess[0]
        }

        return standardSuccess.randomElement() ?? standardSuccess[0]
    }

    /// Returns a crash message with a teaching nudge
    static func crashMessage() -> (message: String, nudge: String) {
        let message = crashMessages.randomElement() ?? crashMessages[0]
        let nudge = crashNudges.randomElement() ?? crashNudges[0]
        return (message, nudge)
    }
}
