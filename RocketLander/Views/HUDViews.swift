import SwiftUI

// MARK: - Top HUD
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

                // Level name (campaign mode only)
                if gameState.currentMode == .campaign,
                   let level = LevelDefinition.level(for: gameState.currentLevelId) {
                    Text(level.name.uppercased())
                        .font(.headline)
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 2)
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

// MARK: - Velocity HUD
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
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }

                Spacer()

                Text(gameState.verticalVelocity <= maxSafeVertical ? "OK" : "HIGH")
                    .font(.system(size: 10, weight: .bold))
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
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.gray)

                    Text(String(format: "%.0f", gameState.horizontalVelocity))
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(horizontalColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }

                Spacer()

                Text(gameState.horizontalVelocity <= maxSafeHorizontal ? "OK" : "HIGH")
                    .font(.system(size: 10, weight: .bold))
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
        .frame(width: 150)
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
