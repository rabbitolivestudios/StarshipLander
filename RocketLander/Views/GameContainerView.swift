import SwiftUI
import SpriteKit

// MARK: - Game Container
struct GameContainerView: View {
    @Binding var showingGame: Bool
    @ObservedObject var highScoreManager: HighScoreManager
    @ObservedObject var campaignState: CampaignState
    @EnvironmentObject var gameState: GameState

    var body: some View {
        ZStack {
            // Game scene
            GameSceneView(gameState: gameState)
                .ignoresSafeArea()
                .allowsHitTesting(!gameState.gameOver)

            // HUD and controls overlay
            VStack(spacing: 0) {
                if !gameState.gameOver {
                    TopHUDView(gameState: gameState, showingGame: $showingGame)
                }

                Spacer()

                if !gameState.gameOver {
                    BottomControlsView(gameState: gameState)
                }

                BannerAdContainer()
                    .padding(.bottom, 5)
            }

            // Full-screen game-over overlay
            if gameState.gameOver {
                GameOverView(
                    gameState: gameState,
                    showingGame: $showingGame,
                    highScoreManager: highScoreManager,
                    campaignState: campaignState
                )
                .transition(.scale.combined(with: .opacity))
                .padding(.bottom, 60) // clear the banner ad
            }
        }
        .environmentObject(gameState)
    }
}

// MARK: - SpriteKit Bridge
struct GameSceneView: UIViewRepresentable {
    let gameState: GameState

    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.ignoresSiblingOrder = true
        view.allowsTransparency = true

        let scene = GameScene(gameState: gameState)
        scene.scaleMode = .resizeFill
        view.presentScene(scene)

        return view
    }

    func updateUIView(_ uiView: SKView, context: Context) {
        uiView.isUserInteractionEnabled = !gameState.gameOver
    }
}
