import SwiftUI

// MARK: - Bottom Controls
struct BottomControlsView: View {
    @ObservedObject var gameState: GameState

    var body: some View {
        HStack(spacing: 20) {
            if gameState.useAccelerometer {
                Spacer()

                ThrustButton(
                    isPressed: $gameState.isThrusting,
                    fuel: gameState.fuel
                )
                .frame(maxWidth: 200)

                Spacer()
            } else {
                ControlButton(
                    systemImage: "rotate.left.fill",
                    label: "L",
                    isPressed: $gameState.isRotatingLeft
                )

                ThrustButton(
                    isPressed: $gameState.isThrusting,
                    fuel: gameState.fuel
                )

                ControlButton(
                    systemImage: "rotate.right.fill",
                    label: "R",
                    isPressed: $gameState.isRotatingRight
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}

// MARK: - Control Button
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

// MARK: - Thrust Button
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
