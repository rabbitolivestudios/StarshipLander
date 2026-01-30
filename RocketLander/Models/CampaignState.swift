import Foundation

class CampaignState: ObservableObject {
    @Published var unlockedLevels: Set<Int> = [1]
    @Published var starsByLevel: [Int: Int] = [:]
    @Published var scoresByLevel: [Int: [HighScoreEntry]] = [:]

    private let storageKey = "campaignState"

    var totalStars: Int {
        starsByLevel.values.reduce(0, +)
    }

    init() {
        load()
    }

    // MARK: - Level Management

    func isUnlocked(_ levelId: Int) -> Bool {
        return unlockedLevels.contains(levelId)
    }

    func bestStars(for levelId: Int) -> Int {
        return starsByLevel[levelId] ?? 0
    }

    func bestScore(for levelId: Int) -> Int {
        return scoresByLevel[levelId]?.first?.score ?? 0
    }

    func completedLevel(_ levelId: Int, stars: Int, score: Int, name: String) {
        // Update stars (keep best)
        let currentBest = starsByLevel[levelId] ?? 0
        if stars > currentBest {
            starsByLevel[levelId] = stars
        }

        // Add score entry
        let entry = HighScoreEntry(name: name, score: score)
        var levelScores = scoresByLevel[levelId] ?? []
        levelScores.append(entry)
        levelScores.sort { $0.score > $1.score }
        if levelScores.count > 3 {
            levelScores = Array(levelScores.prefix(3))
        }
        scoresByLevel[levelId] = levelScores

        // Unlock next level
        let nextLevel = levelId + 1
        if nextLevel <= LevelDefinition.levels.count {
            unlockedLevels.insert(nextLevel)
        }

        save()
    }

    // MARK: - Persistence

    private func save() {
        let data = CampaignSaveData(
            unlockedLevels: Array(unlockedLevels),
            starsByLevel: starsByLevel,
            scoresByLevel: scoresByLevel
        )
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(CampaignSaveData.self, from: data) else {
            return
        }
        unlockedLevels = Set(decoded.unlockedLevels)
        starsByLevel = decoded.starsByLevel
        scoresByLevel = decoded.scoresByLevel
    }
}

// MARK: - Codable Save Data
private struct CampaignSaveData: Codable {
    let unlockedLevels: [Int]
    let starsByLevel: [Int: Int]
    let scoresByLevel: [Int: [HighScoreEntry]]
}
