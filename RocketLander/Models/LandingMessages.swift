import Foundation
import CoreGraphics

// MARK: - Crash Diagnostics
struct CrashDiagnostic {
    let primaryMessage: String
    let secondaryHint: String?
}

enum CrashCause: Int, CaseIterable {
    case tiltTooHigh = 0       // Highest priority
    case verticalTooFast = 1
    case horizontalTooFast = 2
    case approachTooFast = 3
    case terrainCollision = 4
    case outOfBounds = 5
}

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

    /// Returns a crash message with a teaching nudge (legacy, kept for reference)
    static func crashMessage() -> (message: String, nudge: String) {
        let message = crashMessages.randomElement() ?? crashMessages[0]
        let nudge = crashNudges.randomElement() ?? crashNudges[0]
        return (message, nudge)
    }

    // MARK: - Deterministic Crash Diagnostics

    /// Thresholds matching GameScene constants
    private static let maxSafeRotation: CGFloat = 0.05
    private static let maxSafeVerticalSpeed: CGFloat = 40.0
    private static let maxSafeHorizontalSpeed: CGFloat = 25.0
    private static let maxSafeApproachSpeed: CGFloat = 80.0

    /// Returns a deterministic crash message based on actual failure values.
    /// Same inputs always produce the same output.
    static func diagnosticCrashMessage(
        verticalSpeed: CGFloat,
        horizontalSpeed: CGFloat,
        rotation: CGFloat,
        approachSpeed: CGFloat,
        hitTerrain: Bool
    ) -> CrashDiagnostic {
        // Classify all failures
        var causes: [(cause: CrashCause, message: String)] = []

        let tiltDegrees = rotation * 180 / .pi

        if rotation > maxSafeRotation {
            causes.append((.tiltTooHigh,
                "Tilt too high (\(String(format: "%.1f", tiltDegrees))°). Land under 3°."))
        }
        if verticalSpeed > maxSafeVerticalSpeed {
            causes.append((.verticalTooFast,
                "Vertical speed too high (\(String(format: "%.0f", verticalSpeed))). Keep under 40."))
        }
        if horizontalSpeed > maxSafeHorizontalSpeed {
            causes.append((.horizontalTooFast,
                "Horizontal drift too high (\(String(format: "%.0f", horizontalSpeed))). Keep under 25."))
        }
        if approachSpeed > maxSafeApproachSpeed {
            causes.append((.approachTooFast,
                "Approach speed too high (\(String(format: "%.0f", approachSpeed))). Slow down earlier."))
        }

        // If no threshold violations, it was terrain or out-of-bounds
        if causes.isEmpty {
            if hitTerrain {
                return CrashDiagnostic(
                    primaryMessage: "Missed the platform. Aim for the landing pads.",
                    secondaryHint: nil
                )
            } else {
                return CrashDiagnostic(
                    primaryMessage: "Ship lost. Stay over the landing zone.",
                    secondaryHint: nil
                )
            }
        }

        // Sort by priority (lowest rawValue = highest priority)
        causes.sort { $0.cause.rawValue < $1.cause.rawValue }

        let primary = causes[0].message
        let secondary: String? = causes.count > 1 ? causes[1].message : nil

        return CrashDiagnostic(primaryMessage: primary, secondaryHint: secondary)
    }
}
