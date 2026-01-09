import SwiftUI
import SpriteKit

// High score entry
struct HighScoreEntry: Codable, Identifiable {
    var id = UUID()
    let name: String
    let score: Int
}

// High score manager
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

struct ContentView: View {
    @State private var showingGame = false
    @StateObject private var highScoreManager = HighScoreManager()

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
                GameContainerView(showingGame: $showingGame, highScoreManager: highScoreManager)
            } else {
                MenuView(showingGame: $showingGame, highScoreManager: highScoreManager)
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct MenuView: View {
    @Binding var showingGame: Bool
    @ObservedObject var highScoreManager: HighScoreManager

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

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
                .frame(width: 70, height: 100)

            // Leaderboard
            if !highScoreManager.scores.isEmpty {
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

                            Spacer()

                            Text("\(entry.score)")
                                .font(.system(.subheadline, design: .monospaced).bold())
                                .foregroundColor(index == 0 ? .yellow : .orange)
                        }
                        .padding(.horizontal, 12)
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 8)
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
                .frame(maxWidth: 250)
            }

            Spacer()

            // Play button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showingGame = true
                }
            }) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("LAUNCH")
                }
                .font(.title2.bold())
                .foregroundColor(.black)
                .frame(width: 200, height: 55)
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

            Spacer()

            // Instructions
            VStack(spacing: 6) {
                Text("HOW TO PLAY")
                    .font(.caption.bold())
                    .foregroundColor(.orange)

                VStack(alignment: .leading, spacing: 3) {
                    Label("Hold THRUST to fire engine", systemImage: "flame.fill")
                    Label("Use L/R to rotate", systemImage: "arrow.left.arrow.right")
                    Label("Land slowly & upright", systemImage: "arrow.down.to.line")
                }
                .font(.caption2)
                .foregroundColor(.gray)
            }
            .padding(10)
            .background(Color.white.opacity(0.05))
            .cornerRadius(10)

            // Banner Ad
            BannerAdContainer()
                .padding(.top, 10)
        }
        .padding()
    }
}

struct RocketIllustration: View {
    var body: some View {
        ZStack {
            // Flame
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [.orange, .red, .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 22, height: 45)
                .offset(y: 60)

            // Main cylindrical body with dome top
            StarshipBody()
                .fill(Color(red: 0.91, green: 0.91, blue: 0.93))
                .frame(width: 28, height: 75)

            // Forward flaps (left)
            Parallelogram(angle: 25)
                .fill(Color(red: 0.23, green: 0.23, blue: 0.24))
                .frame(width: 16, height: 12)
                .offset(x: -18, y: -22)

            // Forward flaps (right)
            Parallelogram(angle: -25)
                .fill(Color(red: 0.23, green: 0.23, blue: 0.24))
                .frame(width: 16, height: 12)
                .offset(x: 18, y: -22)

            // Aft flaps (left)
            Parallelogram(angle: -20)
                .fill(Color(red: 0.23, green: 0.23, blue: 0.24))
                .frame(width: 18, height: 14)
                .offset(x: -19, y: 22)

            // Aft flaps (right)
            Parallelogram(angle: 20)
                .fill(Color(red: 0.23, green: 0.23, blue: 0.24))
                .frame(width: 18, height: 14)
                .offset(x: 19, y: 22)

            // Engine section
            Rectangle()
                .fill(Color(red: 0.2, green: 0.2, blue: 0.22))
                .frame(width: 30, height: 8)
                .offset(y: 40)

            // Landing legs
            Rectangle()
                .fill(Color(red: 0.4, green: 0.4, blue: 0.42))
                .frame(width: 4, height: 18)
                .rotationEffect(.degrees(-25))
                .offset(x: -18, y: 45)

            Rectangle()
                .fill(Color(red: 0.4, green: 0.4, blue: 0.42))
                .frame(width: 4, height: 18)
                .rotationEffect(.degrees(25))
                .offset(x: 18, y: 45)
        }
    }
}

// Starship body shape with dome top
struct StarshipBody: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let domeHeight: CGFloat = rect.height * 0.15

        // Start bottom left
        path.move(to: CGPoint(x: 0, y: rect.maxY))
        // Left side
        path.addLine(to: CGPoint(x: 0, y: domeHeight))
        // Dome curve
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: domeHeight),
            control: CGPoint(x: rect.midX, y: -domeHeight * 0.5)
        )
        // Right side
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        // Bottom
        path.closeSubpath()

        return path
    }
}

// Parallelogram shape for flaps
struct Parallelogram: Shape {
    var angle: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let offset = tan(angle * .pi / 180) * rect.height

        path.move(to: CGPoint(x: offset > 0 ? offset : 0, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX + (offset > 0 ? 0 : offset), y: 0))
        path.addLine(to: CGPoint(x: rect.maxX - (offset > 0 ? offset : 0), y: rect.maxY))
        path.addLine(to: CGPoint(x: offset > 0 ? 0 : -offset, y: rect.maxY))
        path.closeSubpath()

        return path
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct GameContainerView: View {
    @Binding var showingGame: Bool
    @ObservedObject var highScoreManager: HighScoreManager
    @StateObject private var gameState = GameState()

    var body: some View {
        ZStack {
            // Game scene
            GameSceneView(gameState: gameState)
                .ignoresSafeArea()

            // HUD and controls overlay
            VStack(spacing: 0) {
                // Top HUD
                TopHUDView(gameState: gameState, showingGame: $showingGame)

                Spacer()

                // Game over overlay
                if gameState.gameOver {
                    GameOverView(gameState: gameState, showingGame: $showingGame, highScoreManager: highScoreManager)
                        .transition(.scale.combined(with: .opacity))
                }

                Spacer()

                // Bottom controls and velocity display
                BottomControlsView(gameState: gameState)

                // Banner Ad at bottom of game screen
                BannerAdContainer()
                    .padding(.bottom, 5)
            }
        }
        .environmentObject(gameState)
    }
}

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

    func updateUIView(_ uiView: SKView, context: Context) {}
}

struct TopHUDView: View {
    @ObservedObject var gameState: GameState
    @Binding var showingGame: Bool

    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top) {
                // Back button
                Button(action: {
                    withAnimation {
                        showingGame = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                // Fuel gauge
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "fuelpump.fill")
                            .font(.caption)
                        Text("\(Int(gameState.fuel))%")
                            .font(.system(.headline, design: .monospaced))
                    }
                    .foregroundColor(fuelColor)

                    // Fuel bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.gray.opacity(0.3))

                            RoundedRectangle(cornerRadius: 3)
                                .fill(fuelColor)
                                .frame(width: geo.size.width * gameState.fuel / 100)
                        }
                    }
                    .frame(width: 80, height: 6)
                }
            }

            // Velocity HUD at top
            VelocityHUDView(gameState: gameState)
        }
        .padding()
    }

    var fuelColor: Color {
        if gameState.fuel > 50 { return .green }
        if gameState.fuel > 20 { return .yellow }
        return .red
    }
}

struct VelocityHUDView: View {
    @ObservedObject var gameState: GameState

    private let maxSafeVertical: CGFloat = 50.0
    private let maxSafeHorizontal: CGFloat = 30.0

    var body: some View {
        VStack(spacing: 8) {
            // Vertical velocity
            HStack(spacing: 8) {
                Image(systemName: "arrow.down")
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text("VERT")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.gray)

                    Text(String(format: "%.0f", gameState.verticalVelocity))
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(verticalColor)
                }

                Spacer()

                // Safe indicator
                Text(gameState.verticalVelocity <= maxSafeVertical ? "OK" : "HIGH")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(verticalColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(verticalColor.opacity(0.2))
                    .cornerRadius(4)
            }

            Divider()
                .background(Color.gray.opacity(0.3))

            // Horizontal velocity
            HStack(spacing: 8) {
                Image(systemName: "arrow.left.arrow.right")
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text("HORIZ")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.gray)

                    Text(String(format: "%.0f", gameState.horizontalVelocity))
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(horizontalColor)
                }

                Spacer()

                Text(gameState.horizontalVelocity <= maxSafeHorizontal ? "OK" : "HIGH")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(horizontalColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(horizontalColor.opacity(0.2))
                    .cornerRadius(4)
            }

            Divider()
                .background(Color.gray.opacity(0.3))

            // Safe landing thresholds
            HStack {
                Text("SAFE:")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.gray)
                Text("V<50  H<30")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(.green.opacity(0.7))
            }
        }
        .padding(12)
        .frame(width: 130)
        .background(Color.black.opacity(0.7))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }

    var verticalColor: Color {
        if gameState.verticalVelocity <= maxSafeVertical * 0.6 { return .green }
        if gameState.verticalVelocity <= maxSafeVertical { return .yellow }
        return .red
    }

    var horizontalColor: Color {
        if gameState.horizontalVelocity <= maxSafeHorizontal * 0.6 { return .green }
        if gameState.horizontalVelocity <= maxSafeHorizontal { return .yellow }
        return .red
    }
}

struct BottomControlsView: View {
    @ObservedObject var gameState: GameState

    var body: some View {
        HStack(spacing: 20) {
            // Left rotation button
            ControlButton(
                systemImage: "rotate.left.fill",
                label: "L",
                isPressed: $gameState.isRotatingLeft
            )

            // Thrust button in center
            ThrustButton(
                isPressed: $gameState.isThrusting,
                fuel: gameState.fuel
            )

            // Right rotation button
            ControlButton(
                systemImage: "rotate.right.fill",
                label: "R",
                isPressed: $gameState.isRotatingRight
            )
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}

struct ControlButton: View {
    let systemImage: String
    let label: String
    @Binding var isPressed: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(isPressed ? Color.blue : Color.gray.opacity(0.3))
                .frame(width: 70, height: 70)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                )
                .shadow(color: isPressed ? .blue.opacity(0.5) : .clear, radius: 10)

            VStack(spacing: 2) {
                Image(systemName: systemImage)
                    .font(.title2)
                Text(label)
                    .font(.caption.bold())
            }
            .foregroundColor(.white)
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}

struct ThrustButton: View {
    @Binding var isPressed: Bool
    let fuel: Double

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(
                    isPressed && fuel > 0
                        ? LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom)
                        : LinearGradient(colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.3)], startPoint: .top, endPoint: .bottom)
                )
                .frame(height: 70)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                )
                .shadow(color: isPressed && fuel > 0 ? .orange.opacity(0.5) : .clear, radius: 15)

            VStack(spacing: 2) {
                Image(systemName: "flame.fill")
                    .font(.title2)
                Text("THRUST")
                    .font(.caption.bold())
            }
            .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .opacity(fuel > 0 ? 1.0 : 0.5)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed && fuel > 0 {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}

struct GameOverView: View {
    @ObservedObject var gameState: GameState
    @Binding var showingGame: Bool
    @ObservedObject var highScoreManager: HighScoreManager

    @State private var playerName = ""
    @State private var scoreSaved = false

    var isNewHighScore: Bool {
        gameState.landed && highScoreManager.isHighScore(gameState.score) && !scoreSaved
    }

    var body: some View {
        VStack(spacing: 20) {
            // Result icon
            Image(systemName: gameState.landed ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(gameState.landed ? .green : .red)

            Text(gameState.landed ? "PERFECT LANDING!" : "CRASH!")
                .font(.title.bold())
                .foregroundColor(gameState.landed ? .green : .red)

            if gameState.landed {
                Text("Score: \(gameState.score)")
                    .font(.title2)
                    .foregroundColor(.white)

                // Show high score input directly if qualified
                if isNewHighScore {
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
                            .autocapitalization(.words)
                            .disableAutocorrection(true)

                        Button(action: {
                            let name = playerName.trimmingCharacters(in: .whitespaces)
                            if !name.isEmpty {
                                highScoreManager.addScore(name: name, score: gameState.score)
                                scoreSaved = true
                            }
                        }) {
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

                if scoreSaved {
                    Text("Score saved!")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
            }

            // Action buttons (always show after landing or crash)
            if !isNewHighScore || scoreSaved || !gameState.landed {
                HStack(spacing: 15) {
                    Button(action: {
                        showingGame = false
                    }) {
                        HStack {
                            Image(systemName: "house.fill")
                            Text("Menu")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(10)
                    }

                    Button(action: {
                        withAnimation {
                            scoreSaved = false
                            playerName = ""
                            gameState.reset()
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Retry")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(10)
                    }
                }
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
}

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
    }
}

#Preview {
    ContentView()
}
