import SwiftUI

// MARK: - Final Stats View
struct FinalStatsView: View {
    let tiltDegrees: Double
    let verticalSpeed: CGFloat
    let horizontalSpeed: CGFloat
    let fuel: Double
    let distanceFromCenter: CGFloat?
    let platform: LandingPlatform?
    let speedBand: SpeedBand

    private var maxSafeRotationDeg: Double {
        LandingThresholds.maxRotation * 180 / .pi
    }

    private var tiltBand: SpeedBand {
        tiltDegrees <= maxSafeRotationDeg ? .safe : .fail
    }

    private var vBand: SpeedBand {
        LandingThresholds.verticalBand(verticalSpeed, platform: platform ?? .c)
    }

    private var hBand: SpeedBand {
        LandingThresholds.horizontalBand(horizontalSpeed, platform: platform ?? .c)
    }

    private var fuelBand: SpeedBand {
        if fuel > 20 { return .safe }
        if fuel > 0 { return .hard }
        return .fail
    }

    private var centerBand: SpeedBand {
        guard let dist = distanceFromCenter else { return .safe }
        if dist < 20 { return .safe }
        if dist < 30 { return .hard }
        return .fail
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 6) {
                Image(systemName: "sparkle")
                    .font(.system(size: 8))
                    .foregroundColor(.gray)
                Text("FLIGHT DATA")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
                Image(systemName: "sparkle")
                    .font(.system(size: 8))
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)

            dividerLine

            statRow(icon: "rotate.right", label: "TILT", value: String(format: "%.1f°", tiltDegrees), band: tiltBand)
            dividerLine
            statRow(icon: "arrow.down", label: "V.SPEED", value: String(format: "%.0f", verticalSpeed), band: vBand)
            dividerLine
            statRow(icon: "arrow.left.arrow.right", label: "H.SPEED", value: String(format: "%.0f", horizontalSpeed), band: hBand)
            dividerLine
            statRow(icon: "fuelpump.fill", label: "FUEL", value: String(format: "%.0f%%", fuel), band: fuelBand)

            if let dist = distanceFromCenter {
                dividerLine
                // CENTER row without badge — center distance is scoring-only, not a pass/fail metric
                HStack {
                    Image(systemName: "scope")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .frame(width: 20)
                    Text("CENTER")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.gray)
                    Spacer()
                    Text(String(format: "%.1fpt", dist))
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
            }

            // Landing outcome badge
            if speedBand == .hard || speedBand == .fail {
                Spacer().frame(height: 8)
                Text(speedBand == .fail ? "RAPID UNSCHEDULED DISASSEMBLY" : "HARD LANDING")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(speedBand == .fail ? .red : .yellow)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background((speedBand == .fail ? Color.red : Color.yellow).opacity(0.15))
                    .cornerRadius(4)
                    .padding(.bottom, 6)
            }
        }
        .background(Color.black.opacity(0.5))
        .cornerRadius(8)
    }

    // MARK: - Helpers

    private var dividerLine: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.25))
            .frame(height: 1)
            .padding(.horizontal, 8)
    }

    private func statRow(icon: String, label: String, value: String, band: SpeedBand) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .frame(width: 20)
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(colorFor(band))
            badgeView(band)
                .frame(width: 42)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
    }

    private func badgeView(_ band: SpeedBand) -> some View {
        Text(band == .safe ? "OK" : band == .hard ? "HARD" : "FAIL")
            .font(.system(size: 9, weight: .bold))
            .foregroundColor(colorFor(band))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(colorFor(band).opacity(0.2))
            .cornerRadius(4)
    }

    private func colorFor(_ band: SpeedBand) -> Color {
        switch band {
        case .safe: return .green
        case .hard: return .yellow
        case .fail: return .red
        }
    }
}

struct GameOverView: View {
    @ObservedObject var gameState: GameState
    @Binding var showingGame: Bool
    @ObservedObject var highScoreManager: HighScoreManager
    @ObservedObject var campaignState: CampaignState

    @State private var playerName = ""
    @State private var scoreSaved = false
    @State private var showingHighScoreSheet = false
    @State private var crashMessage = crashMessages.randomElement()!

    // Pool of crash headlines — randomized each game over
    private static let crashMessages = [
        // SpaceX / rocket culture
        "RAPID UNSCHEDULED DISASSEMBLY",
        "LITHOBRAKING DETECTED",
        "UNPLANNED GROUND CONTACT",
        "ANOMALY RESOLVED... POORLY",
        "FLIGHT TERMINATED",
        "FULL SEND INTO TERRAIN",
        // Space mission references
        "HOUSTON, WE HAVE A PROBLEM",
        "OBVIOUSLY A MAJOR MALFUNCTION",
        "NOMINAL... UNTIL IT WASN'T",
        // Kerbal / gaming vibes
        "RAPID LITHOBRAKING EVENT",
        "GRAVITY: 1 — PILOT: 0",
        "STRUCTURAL INTEGRITY: ZERO",
        "LANDING GEAR SOLD SEPARATELY",
        "THAT'S NOT HOW LANDINGS WORK",
        // Dry humor
        "PRECISION CRATER FORMATION",
        "AGGRESSIVE TERRAIN SAMPLING",
        "BOLD APPROACH, BAD OUTCOME",
        "TASK FAILED SUCCESSFULLY",
        "FULL THROTTLE, WRONG DIRECTION",
        "RETURN TO SENDER",
    ]

    var isNewHighScore: Bool {
        guard gameState.landed && !scoreSaved else { return false }
        if gameState.currentMode == .campaign {
            return campaignState.isHighScore(for: gameState.currentLevelId, score: gameState.score)
        } else {
            return highScoreManager.isHighScore(gameState.score)
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            // Result icon
            Image(systemName: gameState.landed ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(gameState.landed ? .green : .red)

            if gameState.landed {
                // Landing message
                Text(gameState.landingMessage.isEmpty ? "LANDING CONFIRMED" : gameState.landingMessage.uppercased())
                    .font(.title2.bold())
                    .foregroundColor(.green)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

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

                // Final stats panel (landing)
                FinalStatsView(
                    tiltDegrees: abs(Double(gameState.finalTiltAngle)) * 180 / .pi,
                    verticalSpeed: gameState.finalVerticalSpeed,
                    horizontalSpeed: gameState.finalHorizontalSpeed,
                    fuel: gameState.finalFuel,
                    distanceFromCenter: gameState.finalDistanceFromCenter,
                    platform: gameState.landedPlatform,
                    speedBand: gameState.landingSpeedBand
                )

                if scoreSaved {
                    Text("Score saved!")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
            } else {
                // Crash display with diagnostics
                Text(crashMessage)
                    .font(.system(size: crashMessage.count > 20 ? 16 : 22, weight: .bold, design: .monospaced))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                if !gameState.crashDiagnosticPrimary.isEmpty {
                    Text(gameState.crashDiagnosticPrimary)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal)
                }

                if !gameState.crashDiagnosticSecondary.isEmpty {
                    Text(gameState.crashDiagnosticSecondary)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal)
                }

                // Final stats panel (crash)
                FinalStatsView(
                    tiltDegrees: abs(Double(gameState.finalTiltAngle)) * 180 / .pi,
                    verticalSpeed: gameState.finalVerticalSpeed,
                    horizontalSpeed: gameState.finalHorizontalSpeed,
                    fuel: gameState.finalFuel,
                    distanceFromCenter: nil,
                    platform: nil,
                    speedBand: .fail
                )
            }

            // Action buttons — always visible
            actionButtons
        }
        .padding(24)
        .background(Color.black.opacity(0.85))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(gameState.landed ? Color.green.opacity(0.5) : Color.red.opacity(0.5), lineWidth: 2)
        )
        .padding(.horizontal, 16)
        .onAppear {
            crashMessage = Self.crashMessages.randomElement()!
            if isNewHighScore {
                showingHighScoreSheet = true
            }
        }
        .onChange(of: gameState.score) { _ in
            if isNewHighScore && !showingHighScoreSheet {
                showingHighScoreSheet = true
            }
        }
        .onChange(of: gameState.landed) { _ in
            if isNewHighScore && !showingHighScoreSheet {
                showingHighScoreSheet = true
            }
        }
        .sheet(isPresented: $showingHighScoreSheet) {
            HighScoreInputSheet(
                score: gameState.score,
                playerName: $playerName,
                onSave: saveScore
            )
        }
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        HStack(spacing: 10) {
            Button(action: {
                showingGame = false
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "house.fill")
                    Text("Menu")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(Color.gray.opacity(0.5))
                .cornerRadius(10)
                .fixedSize(horizontal: true, vertical: false)
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
            highScoreManager.addScore(name: name, score: gameState.score, stars: gameState.starsEarned)
        }

        scoreSaved = true
        showingHighScoreSheet = false
    }
}

// MARK: - High Score Input Sheet
struct HighScoreInputSheet: View {
    let score: Int
    @Binding var playerName: String
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            HStack {
                Image(systemName: "star.fill")
                Text("NEW HIGH SCORE!")
                Image(systemName: "star.fill")
            }
            .font(.title2.bold())
            .foregroundColor(.yellow)

            Text("\(score) points")
                .font(.title.bold())
                .foregroundColor(.white)

            VStack(spacing: 12) {
                Text("Enter your name:")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                TextField("Pilot name", text: $playerName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: 250)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled(true)
                    .onChange(of: playerName) { newValue in
                        if newValue.count > 20 {
                            playerName = String(newValue.prefix(20))
                        }
                    }
            }

            Button(action: onSave) {
                HStack {
                    Image(systemName: "trophy.fill")
                    Text("Save Score")
                }
                .font(.headline)
                .foregroundColor(.black)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.yellow)
                .cornerRadius(10)
            }
            .disabled(playerName.trimmingCharacters(in: .whitespaces).isEmpty)

            Button("Skip") {
                dismiss()
            }
            .font(.subheadline)
            .foregroundColor(.gray)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.05, green: 0.05, blue: 0.12).ignoresSafeArea())
        .modifier(MediumDetentModifier())
    }
}

// MARK: - iOS 16+ Presentation Detent
private struct MediumDetentModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.presentationDetents([.medium])
        } else {
            content
        }
    }
}
