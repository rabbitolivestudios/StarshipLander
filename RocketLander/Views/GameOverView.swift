import SwiftUI

struct GameOverView: View {
    @ObservedObject var gameState: GameState
    @Binding var showingGame: Bool
    @ObservedObject var highScoreManager: HighScoreManager
    @ObservedObject var campaignState: CampaignState

    @State private var playerName = ""
    @State private var scoreSaved = false

    var isNewHighScore: Bool {
        guard gameState.landed && !scoreSaved else { return false }
        if gameState.currentMode == .campaign {
            return campaignState.isHighScore(for: gameState.currentLevelId, score: gameState.score)
        } else {
            return highScoreManager.isHighScore(gameState.score)
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Result icon
            Image(systemName: gameState.landed ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(gameState.landed ? .green : .red)

            if gameState.landed {
                // Landing message
                Text(gameState.landingMessage.isEmpty ? "LANDING CONFIRMED" : gameState.landingMessage.uppercased())
                    .font(.title2.bold())
                    .foregroundColor(.green)

                // Star display
                if gameState.starsEarned > 0 {
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { i in
                            Image(systemName: i < gameState.starsEarned ? "star.fill" : "star")
                                .font(.title2)
                                .foregroundColor(i < gameState.starsEarned ? .yellow : .gray.opacity(0.4))
                        }
                    }
                }

                // Platform info
                if let platform = gameState.landedPlatform {
                    Text("\(platform.label) (\(platform.multiplier, specifier: "%.0f")x)")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }

                Text("Score: \(gameState.score)")
                    .font(.title2)
                    .foregroundColor(.white)

                // High score input
                if isNewHighScore {
                    highScoreInputView
                }

                if scoreSaved {
                    Text("Score saved!")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
            } else {
                // Crash display
                Text(gameState.landingMessage.isEmpty ? "CRASH!" : gameState.landingMessage.uppercased())
                    .font(.title.bold())
                    .foregroundColor(.red)

                if !gameState.crashNudge.isEmpty {
                    Text(gameState.crashNudge)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }

            // Action buttons
            if !isNewHighScore || scoreSaved || !gameState.landed {
                actionButtons
            }
        }
        .padding(30)
        .background(Color.black.opacity(0.85))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(gameState.landed ? Color.green.opacity(0.5) : Color.red.opacity(0.5), lineWidth: 2)
        )
    }

    // MARK: - High Score Input
    private var highScoreInputView: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "star.fill")
                Text("NEW HIGH SCORE!")
                Image(systemName: "star.fill")
            }
            .font(.headline)
            .foregroundColor(.yellow)

            Text("Enter your name:")
                .font(.subheadline)
                .foregroundColor(.gray)

            TextField("Pilot name", text: $playerName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: 200)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled(true)

            Button(action: saveScore) {
                HStack {
                    Image(systemName: "trophy.fill")
                    Text("Save Score")
                }
                .font(.headline)
                .foregroundColor(.black)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.yellow)
                .cornerRadius(8)
            }
            .disabled(playerName.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        HStack(spacing: 10) {
            Button(action: {
                showingGame = false
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "house.fill")
                    Text("Menu")
                        .lineLimit(1)
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.gray.opacity(0.5))
                .cornerRadius(10)
            }

            if gameState.currentMode == .campaign {
                // Next Level button (only if landed and there's a next level)
                if gameState.landed && gameState.currentLevelId < LevelDefinition.levels.count {
                    Button(action: {
                        withAnimation {
                            scoreSaved = false
                            playerName = ""
                            gameState.currentLevelId += 1
                            gameState.reset()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.right")
                            Text("Next")
                                .lineLimit(1)
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(10)
                    }
                }
            }

            Button(action: {
                withAnimation {
                    scoreSaved = false
                    playerName = ""
                    gameState.reset()
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Retry")
                        .lineLimit(1)
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(10)
            }
        }
    }

    // MARK: - Actions
    private func saveScore() {
        let name = playerName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }

        if gameState.currentMode == .campaign {
            campaignState.completedLevel(
                gameState.currentLevelId,
                stars: gameState.starsEarned,
                score: gameState.score,
                name: name
            )
        } else {
            highScoreManager.addScore(name: name, score: gameState.score)
        }

        scoreSaved = true
    }
}
