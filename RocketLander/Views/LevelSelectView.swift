import SwiftUI

struct LevelSelectView: View {
    @Binding var showingGame: Bool
    @ObservedObject var campaignState: CampaignState
    @ObservedObject var gameState: GameState
    @Binding var showingLevelSelect: Bool

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Button(action: { showingLevelSelect = false }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.white)
                }

                Spacer()

                Text("CAMPAIGN")
                    .font(.title2.bold())
                    .foregroundColor(.white)

                Spacer()

                // Total stars
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("\(campaignState.totalStars)/30")
                        .font(.headline)
                        .foregroundColor(.yellow)
                }
            }
            .padding(.horizontal)

            // Level Grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(LevelDefinition.levels, id: \.id) { level in
                        LevelCardView(
                            level: level,
                            isUnlocked: campaignState.isUnlocked(level.id),
                            stars: campaignState.bestStars(for: level.id),
                            bestScore: campaignState.bestScore(for: level.id)
                        ) {
                            gameState.currentMode = .campaign
                            gameState.currentLevelId = level.id
                            gameState.reset()
                            showingGame = true
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top)
    }
}

// MARK: - Level Card
struct LevelCardView: View {
    let level: LevelDefinition
    let isUnlocked: Bool
    let stars: Int
    let bestScore: Int
    let onSelect: () -> Void

    var body: some View {
        Button(action: {
            if isUnlocked { onSelect() }
        }) {
            VStack(spacing: 8) {
                // Level number and name
                HStack {
                    Text("\(level.id)")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(isUnlocked ? .white : .gray)

                    Spacer()

                    if !isUnlocked {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                    }
                }

                Text(level.name.uppercased())
                    .font(.caption.bold())
                    .foregroundColor(isUnlocked ? .orange : .gray)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Stars
                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { i in
                        Image(systemName: i < stars ? "star.fill" : "star")
                            .font(.caption2)
                            .foregroundColor(i < stars ? .yellow : .gray.opacity(0.3))
                    }
                    Spacer()
                    if bestScore > 0 {
                        Text("\(bestScore)")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                }

                // Description
                Text(level.description)
                    .font(.system(size: 9))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(2)
            }
            .padding(12)
            .background(isUnlocked ? Color.white.opacity(0.08) : Color.white.opacity(0.03))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isUnlocked ? Color.orange.opacity(0.3) : Color.gray.opacity(0.1), lineWidth: 1)
            )
        }
        .disabled(!isUnlocked)
    }
}
