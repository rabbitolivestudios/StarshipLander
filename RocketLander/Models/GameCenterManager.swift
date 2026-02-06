import GameKit
import UIKit

// MARK: - Game Center Manager
// ObservableObject + singleton for fire-and-forget calls from GameScene
class GameCenterManager: ObservableObject {
    static let shared = GameCenterManager()

    @Published var isAuthenticated = false
    @Published var localPlayerName = ""
    @Published var galaxyRank: Int?
    @Published var galaxyScore: Int = 0

    // Achievement tracking (persisted to UserDefaults)
    var safePlatformCLevels: Set<Int> = []
    var attemptsByLevel: [Int: Int] = [:]

    private let persistenceKey = "gcAchievementTracking"

    // MARK: - Leaderboard IDs

    enum LeaderboardID {
        static let classic = "classic"
        static func campaign(_ levelId: Int) -> String { "campaign_\(levelId)" }
        static let galaxyRank = "galaxy_rank"
    }

    // MARK: - Achievement IDs

    struct AchievementIDs {
        static let eagleHasLanded = "eagle_has_landed"
        static let precisionLanding = "precision_landing"
        static let eliteLanding = "elite_landing"
        static let fuelMaster = "fuel_master"
        static let precisionPilot = "precision_pilot"
        static let tripleElite = "triple_elite"
        static let planetConquered = "planet_conquered"
        static let firstTryPerfection = "first_try_perfection"
        static let solarSystemElite = "solar_system_elite"
        static let masterLander = "master_lander"
    }

    // MARK: - Init

    init() {
        loadPersistentState()
    }

    // MARK: - Authentication

    func authenticate() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            DispatchQueue.main.async {
                guard let self = self else { return }

                // When GC needs the player to complete sign-in, it provides a VC
                // that MUST be presented. Dropping it silently breaks per-app auth.
                if let vc = viewController {
                    if let topVC = Self.topViewController() {
                        topVC.present(vc, animated: true)
                    }
                    return
                }

                if let error = error {
                    #if DEBUG
                    print("Game Center auth error: \(error.localizedDescription)")
                    #endif
                    self.isAuthenticated = false
                    return
                }
                if GKLocalPlayer.local.isAuthenticated {
                    self.isAuthenticated = true
                    self.localPlayerName = GKLocalPlayer.local.displayName
                    self.fetchGalaxyRank()
                } else {
                    self.isAuthenticated = false
                }
            }
        }
    }

    /// Walk the presentation chain to find the topmost visible view controller.
    static func topViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return nil }
        var vc = rootVC
        while let presented = vc.presentedViewController {
            vc = presented
        }
        return vc
    }

    // MARK: - Score Submission

    func submitScore(_ score: Int, leaderboardID: String) {
        guard isAuthenticated else { return }
        GKLeaderboard.submitScore(score, context: 0, player: GKLocalPlayer.local, leaderboardIDs: [leaderboardID]) { error in
            #if DEBUG
            if let error = error {
                print("GC score submit error (\(leaderboardID)): \(error.localizedDescription)")
            }
            #endif
        }
    }

    func submitClassicScore(_ score: Int) {
        submitScore(score, leaderboardID: LeaderboardID.classic)
    }

    func submitCampaignScore(_ score: Int, levelId: Int, campaignState: CampaignState) {
        // Submit to level leaderboard
        submitScore(score, leaderboardID: LeaderboardID.campaign(levelId))

        // Calculate galaxy rank = sum of best scores across all 10 levels
        // Use the current score if it's better for this level
        var totalScore = 0
        for id in 1...10 {
            if id == levelId {
                totalScore += max(campaignState.bestScore(for: id), score)
            } else {
                totalScore += campaignState.bestScore(for: id)
            }
        }

        galaxyScore = totalScore
        submitScore(totalScore, leaderboardID: LeaderboardID.galaxyRank)

        // Refresh rank after submission
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.fetchGalaxyRank()
        }
    }

    // MARK: - Galaxy Rank Fetch

    func fetchGalaxyRank() {
        guard isAuthenticated else { return }

        GKLeaderboard.loadLeaderboards(IDs: [LeaderboardID.galaxyRank]) { [weak self] leaderboards, error in
            guard let leaderboard = leaderboards?.first, error == nil else {
                #if DEBUG
                if let error = error {
                    print("GC galaxy rank fetch error: \(error.localizedDescription)")
                }
                #endif
                return
            }

            leaderboard.loadEntries(for: [GKLocalPlayer.local], timeScope: .allTime) { [weak self] localEntry, entries, error in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    if let error = error {
                        #if DEBUG
                        print("GC loadEntries error: \(error.localizedDescription)")
                        #endif
                        return
                    }
                    if let entry = localEntry {
                        self.galaxyRank = entry.rank
                        self.galaxyScore = entry.score
                    }
                }
            }
        }
    }

    // MARK: - Achievement Reporting

    func reportAchievement(_ identifier: String) {
        guard isAuthenticated else { return }
        let achievement = GKAchievement(identifier: identifier)
        achievement.percentComplete = 100.0
        achievement.showsCompletionBanner = true
        GKAchievement.report([achievement]) { error in
            #if DEBUG
            if let error = error {
                print("GC achievement report error (\(identifier)): \(error.localizedDescription)")
            }
            #endif
        }
    }

    // MARK: - Achievement Checking

    /// Called after a successful landing with all landing context.
    /// `compositeBand` is the overall landing result from LandingThresholds.evaluate() (worst of V/H/tilt).
    func checkAchievements(
        compositeBand: SpeedBand,
        platform: LandingPlatform,
        fuel: Double,
        tilt: CGFloat,          // absolute tilt in radians
        mode: GameMode,
        levelId: Int,
        campaignState: CampaignState
    ) {
        // #1 Eagle Has Landed — SAFE landing, any mode
        if compositeBand == .safe {
            reportAchievement(AchievementIDs.eagleHasLanded)
        }

        // #2 Precision Landing — SAFE landing on Platform B, any mode (onboarding)
        if compositeBand == .safe && platform == .b {
            reportAchievement(AchievementIDs.precisionLanding)
        }

        // #3 Elite Landing — SAFE landing on Platform C, any mode (onboarding)
        if compositeBand == .safe && platform == .c {
            reportAchievement(AchievementIDs.eliteLanding)
        }

        // #4 Fuel Master — land with ≥65% fuel, any mode, any band
        if fuel >= 65.0 {
            reportAchievement(AchievementIDs.fuelMaster)
        }

        // Campaign-only achievements
        if mode == .campaign {
            // #5 Precision Pilot — campaign, SAFE + Platform C + tilt ≤2.0°
            // Tilt check uses absolute radians internally: 2.0° = 2.0 * .pi / 180
            let tiltThresholdRadians: CGFloat = 2.0 * .pi / 180.0
            if compositeBand == .safe && platform == .c && tilt <= tiltThresholdRadians {
                reportAchievement(AchievementIDs.precisionPilot)
            }

            // #6 Triple Elite — SAFE + Platform C on 3+ different campaign levels
            if compositeBand == .safe && platform == .c {
                safePlatformCLevels.insert(levelId)
                savePersistentState()
                if safePlatformCLevels.count >= 3 {
                    reportAchievement(AchievementIDs.tripleElite)
                }
            }

            // #7 Planet Conquered — earn 3 stars on any campaign level
            let currentBestStars = campaignState.bestStars(for: levelId)
            if max(currentBestStars, platform.stars) >= 3 {
                reportAchievement(AchievementIDs.planetConquered)
            }

            // #8 First Try Perfection — SAFE + Platform C + first attempt on this level
            if compositeBand == .safe && platform == .c && attemptsByLevel[levelId] == 1 {
                reportAchievement(AchievementIDs.firstTryPerfection)
            }

            // #9 Solar System Elite — total stars (including this landing) ≥ 30
            var totalStars = 0
            for id in 1...10 {
                if id == levelId {
                    totalStars += max(campaignState.bestStars(for: id), platform.stars)
                } else {
                    totalStars += campaignState.bestStars(for: id)
                }
            }
            if totalStars >= 30 {
                reportAchievement(AchievementIDs.solarSystemElite)
            }

            // #10 Master Lander — SAFE + Platform C on all 10 campaign levels
            if compositeBand == .safe && platform == .c {
                // safePlatformCLevels already updated above
                if safePlatformCLevels.count >= 10 {
                    reportAchievement(AchievementIDs.masterLander)
                }
            }
        }
    }

    // MARK: - Attempt Tracking

    func recordAttempt(mode: GameMode, levelId: Int) {
        guard mode == .campaign else { return }
        attemptsByLevel[levelId, default: 0] += 1
        savePersistentState()
    }

    // MARK: - Persistence

    func savePersistentState() {
        let data: [String: Any] = [
            "safePlatformCLevels": Array(safePlatformCLevels),
            "attemptsByLevel": attemptsByLevel
        ]
        UserDefaults.standard.set(data, forKey: persistenceKey)
    }

    func loadPersistentState() {
        guard let data = UserDefaults.standard.dictionary(forKey: persistenceKey) else { return }
        if let levels = data["safePlatformCLevels"] as? [Int] {
            safePlatformCLevels = Set(levels)
        }
        if let attempts = data["attemptsByLevel"] as? [String: Int] {
            // Dictionary keys from UserDefaults come back as String
            attemptsByLevel = [:]
            for (key, value) in attempts {
                if let intKey = Int(key) {
                    attemptsByLevel[intKey] = value
                }
            }
        } else if let attempts = data["attemptsByLevel"] as? [Int: Int] {
            attemptsByLevel = attempts
        }
    }
}
