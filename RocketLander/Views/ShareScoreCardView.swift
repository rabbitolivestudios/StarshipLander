import SwiftUI

// MARK: - Share Score Card View
// Rendered as an image for sharing via UIActivityViewController.
// Supports both landing (score hero + compact stats) and crash (headline hero + cause) variants.
struct ShareScoreCardView: View {
    let isLanded: Bool
    let mode: GameMode
    let levelName: String

    // Landing data
    let stars: Int
    let score: Int
    let platformLabel: String
    let speedBand: SpeedBand

    // Compact stats (landing only)
    let verticalSpeed: CGFloat
    let horizontalSpeed: CGFloat
    let fuel: Double
    let platform: LandingPlatform?

    // Crash data
    let crashHeadline: String
    let crashCauseLine: String

    var body: some View {
        VStack(spacing: 12) {
            // 1. Header — always
            Text("STARSHIP LANDER")
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundColor(.orange)
                .padding(.top, 4)

            // 2. Hero — conditional
            if isLanded {
                Text("\(score)")
                    .font(.system(size: 42, weight: .black, design: .monospaced))
                    .foregroundColor(.white)

                if stars > 0 {
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { i in
                            Image(systemName: i < stars ? "star.fill" : "star")
                                .font(.system(size: 18))
                                .foregroundColor(i < stars ? .yellow : .gray.opacity(0.4))
                        }
                    }
                }
            } else {
                Text(crashHeadline)
                    .font(.system(size: crashHeadline.count > 25 ? 16 : 20, weight: .black, design: .monospaced))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 8)
            }

            // 3. Mode + level — always
            Text(mode == .campaign ? "Campaign — \(levelName)" : "Classic Mode")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white.opacity(0.8))

            // 4. Badge — conditional
            if isLanded {
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
            } else {
                Text("CRASH")
                    .font(.system(size: 12, weight: .black, design: .monospaced))
                    .foregroundColor(.red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(4)
            }

            // 5. Divider — always
            Rectangle()
                .fill(Color.orange.opacity(0.3))
                .frame(height: 1)
                .padding(.horizontal, 20)

            // 6. Data row — conditional
            if isLanded {
                // Compact single row: V, H, Fuel — with band colors
                HStack(spacing: 16) {
                    compactStat("V", value: String(format: "%.0f", verticalSpeed), color: vColor)
                    compactStat("H", value: String(format: "%.0f", horizontalSpeed), color: hColor)
                    compactStat("FUEL", value: String(format: "%.0f%%", fuel), color: fuelColor)
                }
            } else {
                Text("Cause: \(crashCauseLine)")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
            }

            // 7. Footer — always
            Text("Starship Lander on the App Store")
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.gray.opacity(0.7))
                .padding(.top, 4)
                .padding(.bottom, 4)
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
                .stroke(isLanded ? Color.orange.opacity(0.5) : Color.red.opacity(0.5), lineWidth: 2)
        )
        .cornerRadius(16)
    }

    // MARK: - Band Colors

    private var vColor: Color {
        let band = LandingThresholds.verticalBand(verticalSpeed, platform: platform ?? .c)
        return colorFor(band)
    }

    private var hColor: Color {
        let band = LandingThresholds.horizontalBand(horizontalSpeed, platform: platform ?? .c)
        return colorFor(band)
    }

    private var fuelColor: Color {
        if fuel > 20 { return .green }
        if fuel > 0 { return .yellow }
        return .red
    }

    private func colorFor(_ band: SpeedBand) -> Color {
        switch band {
        case .safe: return .green
        case .hard: return .yellow
        case .fail: return .red
        }
    }

    private func compactStat(_ label: String, value: String, color: Color = .white) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(color)
        }
    }
}

// MARK: - Share Helper
enum ShareHelper {

    static let appStoreURL = "https://apps.apple.com/us/app/starship-lander/id6757563869"

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

    /// Present native share sheet with image and optional text
    @MainActor
    static func shareImage(_ image: UIImage, text: String? = nil) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }

        var items: [Any] = [image]
        if let text = text {
            items.append(text)
        }

        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)

        // Find the topmost presented view controller
        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }
        topVC.present(activityVC, animated: true)
    }
}
