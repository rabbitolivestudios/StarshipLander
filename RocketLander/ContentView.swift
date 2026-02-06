import SwiftUI
import GameKit

struct ContentView: View {
    @State private var showingGame = false
    @State private var showingLevelSelect = false
    @State private var showingLeaderboard = false
    @StateObject private var highScoreManager = HighScoreManager()
    @StateObject private var campaignState = CampaignState()
    @StateObject private var gameState = GameState()
    @StateObject private var gameCenterManager = GameCenterManager.shared

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color(red: 0.05, green: 0.05, blue: 0.15)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            if showingGame {
                GameContainerView(
                    showingGame: $showingGame,
                    highScoreManager: highScoreManager,
                    campaignState: campaignState,
                    gameCenterManager: gameCenterManager
                )
                .environmentObject(gameState)
            } else if showingLeaderboard {
                LeaderboardView(
                    showingLeaderboard: $showingLeaderboard,
                    highScoreManager: highScoreManager,
                    campaignState: campaignState,
                    gameCenterManager: gameCenterManager
                )
            } else if showingLevelSelect {
                LevelSelectView(
                    showingGame: $showingGame,
                    campaignState: campaignState,
                    gameState: gameState,
                    showingLevelSelect: $showingLevelSelect,
                    gameCenterManager: gameCenterManager
                )
            } else {
                MenuView(
                    showingGame: $showingGame,
                    showingLevelSelect: $showingLevelSelect,
                    showingLeaderboard: $showingLeaderboard,
                    highScoreManager: highScoreManager,
                    campaignState: campaignState,
                    gameState: gameState,
                    gameCenterManager: gameCenterManager
                )
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            gameCenterManager.authenticate()
        }
    }
}

struct MenuView: View {
    @Binding var showingGame: Bool
    @Binding var showingLevelSelect: Bool
    @Binding var showingLeaderboard: Bool
    @ObservedObject var highScoreManager: HighScoreManager
    @ObservedObject var campaignState: CampaignState
    @ObservedObject var gameState: GameState
    @ObservedObject var gameCenterManager: GameCenterManager
    @State private var showingHowToPlay = false

    var body: some View {
        VStack(spacing: 0) {
        ScrollView {
        VStack(spacing: 16) {
            // Title
            VStack(spacing: 5) {
                Text("STARSHIP")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundColor(.white)

                Text("LANDER")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundColor(.orange)
            }

            // Rocket illustration
            RocketIllustration()
                .frame(width: 60, height: 85)

            // Leaderboard
            if !highScoreManager.scores.isEmpty {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingLeaderboard = true
                    }
                }) {
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "trophy.fill")
                                .foregroundColor(.yellow)
                            Text("TOP PILOTS")
                                .font(.caption.bold())
                                .foregroundColor(.yellow)
                            Image(systemName: "trophy.fill")
                                .foregroundColor(.yellow)
                        }

                        ForEach(Array(highScoreManager.scores.enumerated()), id: \.element.id) { index, entry in
                            HStack {
                                Text("\(index + 1).")
                                    .font(.system(.subheadline, design: .monospaced))
                                    .foregroundColor(index == 0 ? .yellow : .gray)
                                    .frame(width: 25, alignment: .leading)

                                Text(entry.name)
                                    .font(.subheadline.bold())
                                    .foregroundColor(index == 0 ? .yellow : .white)
                                    .lineLimit(1)

                                if entry.stars > 0 {
                                    HStack(spacing: 1) {
                                        ForEach(0..<entry.stars, id: \.self) { _ in
                                            Image(systemName: "star.fill")
                                                .font(.system(size: 8))
                                                .foregroundColor(.yellow)
                                        }
                                    }
                                }

                                Spacer()

                                Text("\(entry.score)")
                                    .font(.system(.subheadline, design: .monospaced).bold())
                                    .foregroundColor(index == 0 ? .yellow : .orange)
                            }
                            .padding(.horizontal, 12)
                        }

                        Text("View All >")
                            .font(.caption2)
                            .foregroundColor(.orange.opacity(0.7))
                    }
                }
                .buttonStyle(.plain)
                .padding(.vertical, 12)
                .padding(.horizontal, 8)
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
                .frame(maxWidth: 250)
            }

            // Campaign stars
            if campaignState.totalStars > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("\(campaignState.totalStars)/30 Stars")
                        .font(.subheadline.bold())
                        .foregroundColor(.yellow)
                }
            }

            // Galaxy Rank badge — visible when player has completed at least 1 campaign level and GC is available
            if campaignState.totalStars > 0 && gameCenterManager.isAuthenticated {
                if let rank = gameCenterManager.galaxyRank {
                    HStack(spacing: 4) {
                        Image(systemName: "globe.americas.fill")
                            .font(.caption2)
                            .foregroundColor(.cyan)
                        Text("Galaxy Rank: #\(rank)")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(.cyan)
                    }
                }
            } else if campaignState.totalStars > 0 && !gameCenterManager.isAuthenticated {
                HStack(spacing: 4) {
                    Image(systemName: "globe.americas.fill")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text("Galaxy Rank: — (Sign in to compete globally)")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
            }

            // Play buttons
            VStack(spacing: 12) {
                // Classic Mode
                Button(action: {
                    gameState.currentMode = .classic
                    gameState.reset()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingGame = true
                    }
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("CLASSIC")
                    }
                    .font(.title2.bold())
                    .foregroundColor(.black)
                    .frame(width: 200, height: 50)
                    .background(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(27.5)
                    .shadow(color: .orange.opacity(0.5), radius: 10, y: 5)
                }

                // Campaign Mode
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingLevelSelect = true
                    }
                }) {
                    HStack {
                        Image(systemName: "globe")
                        Text("CAMPAIGN")
                    }
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
                    .shadow(color: .blue.opacity(0.4), radius: 8, y: 4)
                }
            }

            // Controls Setting
            VStack(spacing: 8) {
                Text("CONTROLS")
                    .font(.caption.bold())
                    .foregroundColor(.orange)

                HStack {
                    Image(systemName: gameState.useAccelerometer ? "iphone.gen3.radiowaves.left.and.right" : "hand.tap.fill")
                        .foregroundColor(.white)
                        .frame(width: 24)

                    Text(gameState.useAccelerometer ? "Tilt to Rotate" : "Buttons")
                        .font(.subheadline)
                        .foregroundColor(.white)

                    Spacer()

                    Toggle("", isOn: $gameState.useAccelerometer)
                        .labelsHidden()
                        .tint(.orange)
                }
                .padding(.horizontal, 8)

                Text(gameState.useAccelerometer ? "Tilt your phone left/right" : "Use L/R buttons on screen")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .padding(10)
            .background(Color.white.opacity(0.05))
            .cornerRadius(10)
            .frame(maxWidth: 250)

            Button(action: { showingHowToPlay = true }) {
                Text("How to Play >")
                    .font(.subheadline)
                    .foregroundColor(.orange.opacity(0.8))
            }

        }
        .padding(.horizontal)
        .padding(.bottom, 60)
        }
        BannerAdContainer()
        }
        .sheet(isPresented: $showingHowToPlay) {
            HowToPlayView(useAccelerometer: gameState.useAccelerometer)
        }
        .overlay(alignment: .topTrailing) {
            Text("v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                .font(.system(size: 10))
                .foregroundColor(.gray.opacity(0.5))
                .padding(.trailing, 16)
                .padding(.top, 8)
        }
        .onAppear {
            gameCenterManager.fetchGalaxyRank()
            if gameCenterManager.isAuthenticated {
                GKAccessPoint.shared.location = .topLeading
                GKAccessPoint.shared.isActive = true
            }
        }
        .onDisappear {
            GKAccessPoint.shared.isActive = false
        }
    }
}

#Preview {
    ContentView()
}
