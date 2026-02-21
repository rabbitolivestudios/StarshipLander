import SwiftUI

// MARK: - Top HUD
struct TopHUDView: View {
    @ObservedObject var gameState: GameState
    @Binding var showingGame: Bool

    var body: some View {
        VStack(spacing: 10) {
            ZStack(alignment: .top) {
                // Level name centered (campaign + daily challenge)
                if (gameState.currentMode == .campaign || gameState.currentMode == .dailyChallenge),
                   let level = LevelDefinition.level(for: gameState.currentLevelId) {
                    Text(level.name.uppercased())
                        .font(.custom("Orbitron", size: 14).weight(.semibold))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 2)
                        .frame(maxWidth: .infinity)
                }

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
                            Text(String(format: "%.0f%%", displayFuel))
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
                                    .frame(width: geo.size.width * displayFuel / 100)
                            }
                        }
                        .frame(width: 80, height: 6)
                    }
                }
            }

            // Countdown timer for timed daily challenges
            if gameState.currentMode == .dailyChallenge,
               let timeLimit = DailyChallenge.timeLimitSeconds {
                DailyChallengeTimerView(
                    elapsedTime: gameState.elapsedTime,
                    timeLimitSeconds: timeLimit,
                    hasStarted: gameState.elapsedTime > 0
                )
            }

            // Velocity HUD at top
            VelocityHUDView(gameState: gameState)
        }
        .padding()
    }

    private var displayFuel: Double {
        gameState.gameOver ? gameState.finalFuel : gameState.fuel
    }

    var fuelColor: Color {
        if displayFuel > 50 { return .green }
        if displayFuel > 20 { return .yellow }
        return .red
    }
}

// MARK: - Velocity HUD
struct VelocityHUDView: View {
    @ObservedObject var gameState: GameState

    // HUD uses Platform C (strictest) thresholds as universal reference
    private let hudBands = LandingThresholds.platformC

    // Display values: frozen final* on game-over, live during gameplay
    private var displayVertical: CGFloat {
        gameState.gameOver ? gameState.finalVerticalSpeed : gameState.verticalVelocity
    }
    private var displayHorizontal: CGFloat {
        gameState.gameOver ? gameState.finalHorizontalSpeed : gameState.horizontalVelocity
    }
    private var displayTiltAngle: CGFloat {
        gameState.gameOver ? gameState.finalTiltAngle : gameState.tiltAngle
    }

    var body: some View {
        VStack(spacing: 8) {
            // Vertical velocity
            HStack(spacing: 8) {
                Image(systemName: "arrow.down")
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text("VERT")
                        .font(.custom("Orbitron", size: 8).weight(.medium))
                        .foregroundColor(.gray)

                    Text(String(format: "%.0f", displayVertical))
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(verticalColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }

                Spacer()

                Text(displayVertical <= hudBands.safeVertical ? "OK" : "HIGH")
                    .font(.custom("Orbitron", size: 9).weight(.bold))
                    .foregroundColor(verticalColor)
                    .lineLimit(1)
                    .fixedSize()
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
                        .font(.custom("Orbitron", size: 8).weight(.medium))
                        .foregroundColor(.gray)

                    Text(String(format: "%.0f", displayHorizontal))
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(horizontalColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }

                Spacer()

                Text(displayHorizontal <= hudBands.safeHorizontal ? "OK" : "HIGH")
                    .font(.custom("Orbitron", size: 9).weight(.bold))
                    .foregroundColor(horizontalColor)
                    .lineLimit(1)
                    .fixedSize()
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(horizontalColor.opacity(0.2))
                    .cornerRadius(4)
            }

            Divider()
                .background(Color.gray.opacity(0.3))

            // Tilt angle
            HStack(spacing: 8) {
                Image(systemName: "rotate.right")
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text("TILT")
                        .font(.custom("Orbitron", size: 8).weight(.medium))
                        .foregroundColor(.gray)

                    HStack(spacing: 2) {
                        Text(String(format: "%.1f°", tiltDegrees))
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(tiltColor)
                            .fixedSize()

                        if tiltDegrees > safeTiltDegrees {
                            Text(tiltDirection)
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(tiltColor)
                                .fixedSize()
                        }
                    }
                }

                Spacer()

                Text(tiltDegrees <= safeTiltDegrees ? "OK" : "HIGH")
                    .font(.custom("Orbitron", size: 9).weight(.bold))
                    .foregroundColor(tiltColor)
                    .lineLimit(1)
                    .fixedSize()
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(tiltColor.opacity(0.2))
                    .cornerRadius(4)
            }

            Divider()
                .background(Color.gray.opacity(0.3))

            // Safe landing thresholds (Platform C reference)
            HStack {
                Text("SAFE:")
                    .font(.custom("Orbitron", size: 8).weight(.medium))
                    .foregroundColor(.gray)
                Text("V<\(Int(hudBands.safeVertical)) H<\(Int(hudBands.safeHorizontal)) T<3°")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(.green.opacity(0.7))
            }
        }
        .padding(12)
        .frame(width: 170)
        .background(Color.black.opacity(0.7))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }

    private var safeTiltDegrees: CGFloat {
        LandingThresholds.safeTilt * 180 / .pi
    }

    private var hardTiltDegrees: CGFloat {
        LandingThresholds.hardTilt * 180 / .pi
    }

    var verticalColor: Color {
        if displayVertical <= hudBands.safeVertical { return .green }
        if displayVertical <= hudBands.hardVertical { return .yellow }
        return .red
    }

    var horizontalColor: Color {
        if displayHorizontal <= hudBands.safeHorizontal { return .green }
        if displayHorizontal <= hudBands.hardHorizontal { return .yellow }
        return .red
    }

    var tiltDegrees: CGFloat {
        abs(displayTiltAngle) * 180 / .pi
    }

    var tiltDirection: String {
        displayTiltAngle > 0 ? "L" : "R"
    }

    var tiltColor: Color {
        if tiltDegrees <= safeTiltDegrees { return .green }
        if tiltDegrees <= hardTiltDegrees { return .yellow }
        return .red
    }
}

// MARK: - Daily Challenge Countdown Timer
struct DailyChallengeTimerView: View {
    let elapsedTime: TimeInterval
    let timeLimitSeconds: Int
    let hasStarted: Bool

    private var remainingTime: TimeInterval {
        max(0, Double(timeLimitSeconds) - elapsedTime)
    }

    private var timerColor: Color {
        if remainingTime <= 5 { return .red }
        if remainingTime <= 10 { return .yellow }
        return .cyan
    }

    private var progress: CGFloat {
        guard timeLimitSeconds > 0 else { return 1.0 }
        return CGFloat(remainingTime / Double(timeLimitSeconds))
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "timer")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(timerColor)

            if hasStarted {
                Text(String(format: "%.1fs", remainingTime))
                    .font(.custom("Orbitron", size: 18).weight(.bold))
                    .foregroundColor(timerColor)
                    .frame(width: 75, alignment: .leading)
            } else {
                Text("\(timeLimitSeconds)s")
                    .font(.custom("Orbitron", size: 18).weight(.bold))
                    .foregroundColor(.cyan.opacity(0.6))
                    .frame(width: 75, alignment: .leading)
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.3))
                    RoundedRectangle(cornerRadius: 3)
                        .fill(timerColor)
                        .frame(width: geo.size.width * progress)
                }
            }
            .frame(width: 60, height: 6)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.7))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(timerColor.opacity(0.4), lineWidth: 1)
        )
    }
}
