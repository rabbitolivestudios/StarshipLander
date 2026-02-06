import SwiftUI

// MARK: - Share Score Card View
// Rendered as an image for sharing via UIActivityViewController
struct ShareScoreCardView: View {
    let mode: GameMode
    let levelName: String
    let stars: Int
    let score: Int
    let platformLabel: String
    let speedBand: SpeedBand
    let tiltDegrees: Double
    let verticalSpeed: CGFloat
    let horizontalSpeed: CGFloat
    let fuel: Double
    let distanceFromCenter: CGFloat?

    var body: some View {
        VStack(spacing: 12) {
            // Game logo
            Text("STARSHIP LANDER")
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundColor(.orange)

            // Mode + level
            Text(mode == .campaign ? levelName.uppercased() : "CLASSIC MODE")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)

            // Stars
            if stars > 0 {
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { i in
                        Image(systemName: i < stars ? "star.fill" : "star")
                            .font(.system(size: 18))
                            .foregroundColor(i < stars ? .yellow : .gray.opacity(0.4))
                    }
                }
            }

            // Score
            Text("\(score)")
                .font(.system(size: 36, weight: .black, design: .monospaced))
                .foregroundColor(.white)

            // Platform + band badge
            HStack(spacing: 8) {
                Text(platformLabel)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.gray)

                Text(speedBand == .safe ? "SAFE" : "HARD")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(speedBand == .safe ? .green : .yellow)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background((speedBand == .safe ? Color.green : Color.yellow).opacity(0.2))
                    .cornerRadius(4)
            }

            // Divider
            Rectangle()
                .fill(Color.orange.opacity(0.3))
                .frame(height: 1)
                .padding(.horizontal, 20)

            // Flight data
            VStack(spacing: 6) {
                flightDataRow("TILT", value: String(format: "%.1f°", tiltDegrees))
                flightDataRow("V.SPEED", value: String(format: "%.0f", verticalSpeed))
                flightDataRow("H.SPEED", value: String(format: "%.0f", horizontalSpeed))
                flightDataRow("FUEL", value: String(format: "%.0f%%", fuel))
                if let dist = distanceFromCenter {
                    flightDataRow("CENTER", value: String(format: "%.1fpt", dist))
                }
            }
        }
        .padding(20)
        .frame(width: 320)
        .background(
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.05, blue: 0.12), Color(red: 0.08, green: 0.02, blue: 0.08)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(0.5), lineWidth: 2)
        )
        .cornerRadius(16)
    }

    private func flightDataRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Share Helper
enum ShareHelper {

    /// Render a SwiftUI view to a UIImage
    @MainActor
    static func renderScoreCard(_ view: ShareScoreCardView) -> UIImage? {
        if #available(iOS 16.0, *) {
            let renderer = ImageRenderer(content: view)
            renderer.scale = UIScreen.main.scale
            return renderer.uiImage
        } else {
            // iOS 15 fallback: use UIHostingController snapshot
            let hostingController = UIHostingController(rootView: view)
            hostingController.view.backgroundColor = .clear
            let targetSize = hostingController.sizeThatFits(in: CGSize(width: 320, height: CGFloat.greatestFiniteMagnitude))
            hostingController.view.frame = CGRect(origin: .zero, size: targetSize)
            hostingController.view.layoutIfNeeded()

            let renderer = UIGraphicsImageRenderer(size: targetSize)
            return renderer.image { _ in
                hostingController.view.drawHierarchy(in: hostingController.view.bounds, afterScreenUpdates: true)
            }
        }
    }

    /// Present native share sheet with image
    @MainActor
    static func shareImage(_ image: UIImage) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }

        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)

        // Find the topmost presented view controller
        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }
        topVC.present(activityVC, animated: true)
    }
}
