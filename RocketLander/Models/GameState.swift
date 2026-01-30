import SwiftUI

// MARK: - Game Mode
enum GameMode: String, Codable {
    case classic
    case campaign
}

// MARK: - Game State
class GameState: ObservableObject {
    @Published var score: Int = 0
    @Published var fuel: Double = 100
    @Published var gameOver: Bool = false
    @Published var landed: Bool = false
    @Published var shouldReset: Bool = false

    // Velocity tracking
    @Published var verticalVelocity: CGFloat = 0
    @Published var horizontalVelocity: CGFloat = 0
    @Published var rotation: CGFloat = 0

    // Control states
    @Published var isThrusting: Bool = false
    @Published var isRotatingLeft: Bool = false
    @Published var isRotatingRight: Bool = false

    // Platform & landing info (Phase 1)
    @Published var landedPlatform: LandingPlatform?
    @Published var landingMessage: String = ""
    @Published var crashNudge: String = ""
    @Published var starsEarned: Int = 0

    // Mode & campaign (Phase 2)
    @Published var currentMode: GameMode = .classic
    @Published var currentLevelId: Int = 1

    // Settings
    @Published var useAccelerometer: Bool {
        didSet {
            UserDefaults.standard.set(useAccelerometer, forKey: "useAccelerometer")
        }
    }

    init() {
        self.useAccelerometer = UserDefaults.standard.bool(forKey: "useAccelerometer")
    }

    func reset() {
        score = 0
        fuel = 100
        gameOver = false
        landed = false
        shouldReset = true
        verticalVelocity = 0
        horizontalVelocity = 0
        rotation = 0
        isThrusting = false
        isRotatingLeft = false
        isRotatingRight = false
        landedPlatform = nil
        landingMessage = ""
        crashNudge = ""
        starsEarned = 0
    }
}
