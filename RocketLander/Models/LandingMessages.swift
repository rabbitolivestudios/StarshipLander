import Foundation
import CoreGraphics

// MARK: - Crash Diagnostics
struct CrashDiagnostic {
    let primaryMessage: String
    let secondaryHint: String?
}

enum CrashCause: Int {
    case tiltTooHigh = 0       // Highest priority
    case verticalTooFast = 1
    case horizontalTooFast = 2
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

    static let hardLandingSuccess: [String] = [
        "Hard landing — but you made it.",
        "Rough touchdown. You survived.",
        "That was close. Successful landing.",
    ]

    static let rareSuccess = "This was exceptional."

    // MARK: - Message Selection

    /// Returns a landing message based on the platform, score, and speed band
    static func successMessage(platform: LandingPlatform, score: Int, speedBand: SpeedBand = .safe) -> String {
        // HARD landing gets its own message pool
        if speedBand == .hard {
            return hardLandingSuccess.randomElement() ?? hardLandingSuccess[0]
        }

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

    // MARK: - Deterministic Crash Diagnostics

    /// Returns a deterministic crash message based on actual failure values.
    /// Uses platform-specific thresholds from LandingThresholds.
    /// Same inputs always produce the same output.
    static func diagnosticCrashMessage(
        verticalSpeed: CGFloat,
        horizontalSpeed: CGFloat,
        rotation: CGFloat,
        approachSpeed: CGFloat,
        platform: LandingPlatform?,
        hitTerrain: Bool
    ) -> CrashDiagnostic {
        // Use platform-specific bands if available, otherwise Platform C (strictest)
        let targetPlatform = platform ?? .c
        let bands = LandingThresholds.bands(for: targetPlatform)

        var causes: [(cause: CrashCause, message: String)] = []

        let tiltDegrees = rotation * 180 / .pi

        if rotation > LandingThresholds.maxRotation {
            causes.append((.tiltTooHigh,
                "Tilt too high (\(String(format: "%.1f", tiltDegrees))°). Land under 3°."))
        }
        if verticalSpeed > bands.hardVertical {
            causes.append((.verticalTooFast,
                "Vertical speed too high (\(String(format: "%.0f", verticalSpeed))). Keep under \(Int(bands.hardVertical)) for \(targetPlatform.label)."))
        }
        if horizontalSpeed > bands.hardHorizontal {
            causes.append((.horizontalTooFast,
                "Horizontal drift too high (\(String(format: "%.0f", horizontalSpeed))). Keep under \(Int(bands.hardHorizontal)) for \(targetPlatform.label)."))
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
