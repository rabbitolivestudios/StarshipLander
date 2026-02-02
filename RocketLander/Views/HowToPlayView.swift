import SwiftUI

struct HowToPlayView: View {
    let useAccelerometer: Bool
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.12)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header bar
                HStack {
                    Text("How to Play")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                .padding()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        controlsSection
                        platformsSection
                        speedBandsSection
                        scoringSection
                        campaignSection
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Controls

    private var controlsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Controls")

            controlRow(icon: "flame.fill", color: .orange,
                       title: "Thrust",
                       detail: "Hold the THRUST button to fire the engine and slow your descent.")

            if useAccelerometer {
                controlRow(icon: "iphone.gen3.radiowaves.left.and.right", color: .blue,
                           title: "Rotate",
                           detail: "Tilt your phone left or right to rotate the rocket.")
            } else {
                controlRow(icon: "arrow.left.arrow.right", color: .blue,
                           title: "Rotate",
                           detail: "Use the L/R buttons on screen to rotate the rocket.")
            }

            controlRow(icon: "arrow.down.to.line", color: .green,
                       title: "Land",
                       detail: "Touch down on a platform slowly, level, and centered for the best score.")
        }
    }

    private func controlRow(icon: String, color: Color, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                Text(detail)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }

    // MARK: - Platforms

    private var platformsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Landing Platforms")

            Text("Three platforms with different difficulty and rewards:")
                .font(.caption)
                .foregroundColor(.gray)

            VStack(spacing: 0) {
                // Header row
                HStack {
                    Text("Pad").frame(width: 30, alignment: .leading)
                    Text("Name").frame(maxWidth: .infinity, alignment: .leading)
                    Text("Width").frame(width: 45, alignment: .trailing)
                    Text("Mult").frame(width: 35, alignment: .trailing)
                    Text("Stars").frame(width: 40, alignment: .trailing)
                }
                .font(.system(.caption2, design: .monospaced).bold())
                .foregroundColor(.orange)
                .padding(.vertical, 6)
                .padding(.horizontal, 8)

                platformRow("A", "Training Zone", "130", "1x", 1, color: .green)
                platformRow("B", "Precision Target", "110", "2x", 2, color: .yellow)
                platformRow("C", "Elite Landing", "80", "5x", 3, color: .red)
            }
            .background(Color.white.opacity(0.05))
            .cornerRadius(8)
        }
    }

    private func platformRow(_ pad: String, _ name: String, _ width: String, _ mult: String, _ stars: Int, color: Color) -> some View {
        HStack {
            Text(pad)
                .foregroundColor(color)
                .frame(width: 30, alignment: .leading)
            Text(name).frame(maxWidth: .infinity, alignment: .leading)
            Text(width).frame(width: 45, alignment: .trailing)
            Text(mult).frame(width: 35, alignment: .trailing)
            HStack(spacing: 1) {
                ForEach(0..<stars, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.yellow)
                }
            }
            .frame(width: 40, alignment: .trailing)
        }
        .font(.system(.caption, design: .monospaced))
        .foregroundColor(.white)
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
    }

    // MARK: - Speed Bands

    private var speedBandsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Speed Bands")

            VStack(alignment: .leading, spacing: 6) {
                bandExplanation(band: "SAFE", color: .green,
                                detail: "Below safe threshold — full points for speed components.")
                bandExplanation(band: "HARD", color: .yellow,
                                detail: "Between safe and hard thresholds — you survive but lose speed points.")
                bandExplanation(band: "FAIL", color: .red,
                                detail: "Above hard threshold — crash! No landing.")
            }

            Text("Thresholds per platform (vertical / horizontal):")
                .font(.caption2)
                .foregroundColor(.gray)

            VStack(spacing: 0) {
                HStack {
                    Text("Pad").frame(width: 30, alignment: .leading)
                    Text("Safe V").frame(width: 50, alignment: .trailing)
                    Text("Hard V").frame(width: 50, alignment: .trailing)
                    Text("Safe H").frame(width: 50, alignment: .trailing)
                    Text("Hard H").frame(width: 50, alignment: .trailing)
                }
                .font(.system(.caption2, design: .monospaced).bold())
                .foregroundColor(.orange)
                .padding(.vertical, 6)
                .padding(.horizontal, 8)

                thresholdRow("A", "80", "120", "60", "100", color: .green)
                thresholdRow("B", "55", "85", "45", "75", color: .yellow)
                thresholdRow("C", "35", "55", "30", "50", color: .red)
            }
            .background(Color.white.opacity(0.05))
            .cornerRadius(8)

            Text("Rotation must be < 2.9° on all platforms or you crash.")
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }

    private func bandExplanation(band: String, color: Color, detail: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(band)
                .font(.system(.caption, design: .monospaced).bold())
                .foregroundColor(color)
                .frame(width: 40, alignment: .leading)
            Text(detail)
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }

    private func thresholdRow(_ pad: String, _ sv: String, _ hv: String, _ sh: String, _ hh: String, color: Color) -> some View {
        HStack {
            Text(pad)
                .foregroundColor(color)
                .frame(width: 30, alignment: .leading)
            Text(sv).frame(width: 50, alignment: .trailing)
            Text(hv).frame(width: 50, alignment: .trailing)
            Text(sh).frame(width: 50, alignment: .trailing)
            Text(hh).frame(width: 50, alignment: .trailing)
        }
        .font(.system(.caption, design: .monospaced))
        .foregroundColor(.white)
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
    }

    // MARK: - Scoring

    private var scoringSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Scoring")

            Text("Your score is calculated from 6 components, then multiplied:")
                .font(.caption)
                .foregroundColor(.gray)

            VStack(alignment: .leading, spacing: 4) {
                scoreComponent("Base", "100 pts", "Awarded for any successful landing")
                scoreComponent("Soft Landing", "0-500 pts", "Lower vertical speed = more points")
                scoreComponent("Horizontal Precision", "0-400 pts", "Lower sideways speed = more points")
                scoreComponent("Platform Center", "0-600 pts", "Closer to center = more points")
                scoreComponent("Rotation Precision", "0-250 pts", "More level = more points")
                scoreComponent("Approach Control", "0-150 pts", "Smooth final approach = more points")
            }

            Text("Subtotal max: 2,000 pts")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.orange)

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top) {
                    Text("Fuel Multiplier:")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                    Text("1.0x (empty) to 2.0x (full tank)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                HStack(alignment: .top) {
                    Text("Platform Multiplier:")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                    Text("A = 1x, B = 2x, C = 5x")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Text("Final = Subtotal x Fuel x Platform")
                .font(.system(.caption, design: .monospaced).bold())
                .foregroundColor(.orange)

            Text("Max possible: 2,000 x 2.0 x 5.0 = 20,000 pts")
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }

    private func scoreComponent(_ name: String, _ points: String, _ detail: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(points)
                .font(.system(.caption2, design: .monospaced))
                .foregroundColor(.orange)
                .frame(width: 70, alignment: .trailing)
            VStack(alignment: .leading, spacing: 1) {
                Text(name)
                    .font(.caption.bold())
                    .foregroundColor(.white)
                Text(detail)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
    }

    // MARK: - Campaign

    private var campaignSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Campaign")

            Text("Land on 10 worlds across the solar system. Each planet has unique gravity, thrust, and a special mechanic. Complete a level to unlock the next.")
                .font(.caption)
                .foregroundColor(.gray)

            Text("Stars are earned by landing on harder platforms: A = 1 star, B = 2 stars, C = 3 stars. Collect all 30 stars to master the campaign.")
                .font(.caption)
                .foregroundColor(.gray)

            VStack(spacing: 0) {
                ForEach(LevelDefinition.levels, id: \.id) { level in
                    campaignLevelRow(level)
                }
            }
            .background(Color.white.opacity(0.05))
            .cornerRadius(8)
        }
    }

    private func campaignLevelRow(_ level: LevelDefinition) -> some View {
        HStack(spacing: 8) {
            Text("\(level.id)")
                .font(.system(.caption, design: .monospaced).bold())
                .foregroundColor(.orange)
                .frame(width: 20, alignment: .trailing)

            VStack(alignment: .leading, spacing: 1) {
                Text(level.name)
                    .font(.caption.bold())
                    .foregroundColor(.white)
                Text(level.description)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 1) {
                Text("g: \(String(format: "%.1f", abs(level.gravity)))")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(.gray)
                if level.specialMechanic != .none {
                    Text(level.specialMechanic.displayName)
                        .font(.system(size: 9))
                        .foregroundColor(.orange.opacity(0.7))
                }
            }
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 8)
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption.bold())
            .foregroundColor(.orange)
            .tracking(1)
    }
}
