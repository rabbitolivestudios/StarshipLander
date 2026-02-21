import SwiftUI

struct DailyChallengeBriefingView: View {
    @ObservedObject var gameState: GameState
    @ObservedObject var gameCenterManager: GameCenterManager
    @ObservedObject var blueStarManager: BlueStarManager
    @Binding var showingGame: Bool
    @Binding var showingBriefing: Bool

    @State private var topPlayerName: String?
    @State private var topPlayerScore: Int?

    private var challenge: ChallengeSpec { DailyChallenge.today }

    var body: some View {
        VStack(spacing: 16) {
            // Header
            VStack(spacing: 6) {
                Text("DAILY CHALLENGE")
                    .font(.custom("Orbitron", size: 12).weight(.bold))
                    .foregroundColor(.teal)

                Text(challenge.title)
                    .font(.custom("Orbitron", size: 18).weight(.bold))
                    .foregroundColor(.white)

                // Difficulty stars
                HStack(spacing: 3) {
                    ForEach(0..<5, id: \.self) { i in
                        Image(systemName: i < challenge.difficulty ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundColor(i < challenge.difficulty ? .orange : .gray.opacity(0.4))
                    }
                }
            }

            // Planet info
            HStack(spacing: 8) {
                Image(systemName: "globe.americas.fill")
                    .foregroundColor(.teal)
                Text(challenge.level.name)
                    .font(.custom("Orbitron", size: 14).weight(.bold))
                    .foregroundColor(.white)
                if challenge.level.specialMechanic != .none {
                    Text("(\(challenge.level.specialMechanic.displayName))")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }

            // Briefing text
            Text(challenge.briefing)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Objectives
            VStack(spacing: 0) {
                HStack(spacing: 6) {
                    Image(systemName: "target")
                        .font(.system(size: 8))
                        .foregroundColor(.teal)
                    Text("OBJECTIVES")
                        .font(.custom("Orbitron", size: 9).weight(.bold))
                        .foregroundColor(.teal)
                    Image(systemName: "target")
                        .font(.system(size: 8))
                        .foregroundColor(.teal)
                }
                .padding(.vertical, 8)

                ForEach(Array(challenge.constraints.enumerated()), id: \.offset) { _, constraint in
                    HStack {
                        Image(systemName: constraint.icon)
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .frame(width: 20)
                        Text(constraint.label)
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 12)
                }
            }
            .background(Color.white.opacity(0.05))
            .cornerRadius(8)
            .frame(maxWidth: 260)

            // Today's Best (from Game Center)
            if let name = topPlayerName, let score = topPlayerScore {
                VStack(spacing: 4) {
                    Text("TODAY'S BEST")
                        .font(.custom("Orbitron", size: 9).weight(.bold))
                        .foregroundColor(.gray)
                    HStack(spacing: 6) {
                        Image(systemName: "crown.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                        Text("\(name) — \(score) pts")
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundColor(.yellow)
                    }
                }
            }

            // Local best
            if let best = DailyChallenge.localBestScore {
                Text("Your Best: \(best) pts")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.gray)
            }

            // Streak & blue star info
            VStack(spacing: 4) {
                if blueStarManager.currentStreak > 0 && blueStarManager.isStreakActive {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text("\(blueStarManager.currentStreak)-day streak")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(.orange)
                    }
                }

                if !blueStarManager.todayAlreadyClaimed {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.cyan)
                        Text("Complete for +\(BlueStarManager.dailyChallengeReward) Blue Star")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(.cyan)
                    }
                } else if DailyChallenge.isCompleted {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        Text("Completed today!")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(.green)
                    }
                }
            }

            // Action buttons
            HStack(spacing: 16) {
                Button(action: {
                    showingBriefing = false
                }) {
                    Text("Back")
                        .font(.custom("Orbitron", size: 14).weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(10)
                }

                Button(action: launchChallenge) {
                    HStack(spacing: 6) {
                        Image(systemName: "paperplane.fill")
                        Text("Launch")
                    }
                    .font(.custom("Orbitron", size: 14).weight(.bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(colors: [.teal, Color(red: 0.0, green: 0.5, blue: 0.6)],
                                       startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(10)
                }
            }
        }
        .padding(24)
        .background(Color.black.opacity(0.92))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.teal.opacity(0.4), lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .onAppear {
            gameCenterManager.fetchDailyTopEntry { name, score in
                topPlayerName = name
                topPlayerScore = score
            }
        }
    }

    private func launchChallenge() {
        let spec = DailyChallenge.today
        gameState.currentMode = .dailyChallenge
        gameState.currentLevelId = spec.levelId
        gameState.dailyChallengeTargetPlatform = DailyChallenge.targetPlatform
        gameState.reset()
        showingBriefing = false
        showingGame = true
    }
}
