import CoreGraphics
import SpriteKit

// MARK: - Landing Platform Definition
enum LandingPlatform: String, CaseIterable {
    case a = "A"
    case b = "B"
    case c = "C"

    var label: String {
        switch self {
        case .a: return "Training Zone"
        case .b: return "Precision Target"
        case .c: return "Elite Landing"
        }
    }

    var multiplier: Double {
        switch self {
        case .a: return 1.0
        case .b: return 2.0
        case .c: return 5.0
        }
    }

    var width: CGFloat {
        switch self {
        case .a: return 130
        case .b: return 110
        case .c: return 80
        }
    }

    /// X position as a fraction of screen width
    var xFraction: CGFloat {
        switch self {
        case .a: return 0.18
        case .b: return 0.50
        case .c: return 0.82
        }
    }

    var lightColor: SKColor {
        switch self {
        case .a: return .green
        case .b: return .yellow
        case .c: return .red
        }
    }

    var stars: Int {
        switch self {
        case .a: return 1
        case .b: return 2
        case .c: return 3
        }
    }
}
