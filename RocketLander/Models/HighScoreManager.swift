import SwiftUI

// MARK: - High Score Entry
struct HighScoreEntry: Codable, Identifiable {
    var id = UUID()
    let name: String
    let score: Int
}

// MARK: - High Score Manager
class HighScoreManager: ObservableObject {
    @Published var scores: [HighScoreEntry] = []
    private let maxScores = 3
    private let storageKey = "topScores"

    init() {
        loadScores()
    }

    func loadScores() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([HighScoreEntry].self, from: data) {
            scores = decoded
        }
    }

    func saveScores() {
        if let encoded = try? JSONEncoder().encode(scores) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    func isHighScore(_ score: Int) -> Bool {
        if scores.count < maxScores {
            return score > 0
        }
        return score > (scores.last?.score ?? 0)
    }

    func addScore(name: String, score: Int) {
        let entry = HighScoreEntry(name: name, score: score)
        scores.append(entry)
        scores.sort { $0.score > $1.score }
        if scores.count > maxScores {
            scores = Array(scores.prefix(maxScores))
        }
        saveScores()
    }

    func getTopScore() -> Int {
        return scores.first?.score ?? 0
    }
}
