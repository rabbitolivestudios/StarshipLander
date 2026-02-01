import SwiftUI

// MARK: - High Score Entry
struct HighScoreEntry: Codable, Identifiable {
    var id = UUID()
    let name: String
    let score: Int
    var stars: Int = 0

    enum CodingKeys: String, CodingKey {
        case id, name, score, stars
    }

    init(name: String, score: Int, stars: Int = 0) {
        self.id = UUID()
        self.name = name
        self.score = score
        self.stars = stars
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decode(String.self, forKey: .name)
        score = try container.decode(Int.self, forKey: .score)
        stars = try container.decodeIfPresent(Int.self, forKey: .stars) ?? 0
    }
}

// MARK: - High Score Manager
class HighScoreManager: ObservableObject {
    @Published var scores: [HighScoreEntry] = []
    private let maxScores = 3
    private let storageKey = "topScores"

    init() {
        loadScores()
        if scores.isEmpty {
            // Easter egg: Elon Musk as default high score holder
            scores = [HighScoreEntry(name: "Elon", score: 1000)]
            saveScores()
        }
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

    func addScore(name: String, score: Int, stars: Int = 0) {
        let entry = HighScoreEntry(name: name, score: score, stars: stars)
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
