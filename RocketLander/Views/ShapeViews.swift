import SwiftUI

// MARK: - Rocket Illustration (Menu)
struct RocketIllustration: View {
    let highlightGray = Color(red: 0.88, green: 0.89, blue: 0.91)
    let strokeGray = Color(red: 0.6, green: 0.6, blue: 0.63)
    let flapDark = Color(red: 0.18, green: 0.18, blue: 0.2)
    let flapHighlight = Color(red: 0.34, green: 0.34, blue: 0.38)
    let metalDark = Color(red: 0.15, green: 0.15, blue: 0.17)
    let legGray = Color(red: 0.45, green: 0.45, blue: 0.48)
    let heatShield = Color(red: 0.07, green: 0.075, blue: 0.085)

    var body: some View {
        ZStack {
            // Flame
            ZStack {
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.85), .orange, .red.opacity(0.8), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 24, height: 50)
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [.yellow.opacity(0.9), .orange.opacity(0.4), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 11, height: 36)
                    .offset(y: -2)
            }
            .offset(y: 66)

            // Landing legs
            Rectangle()
                .fill(legGray)
                .frame(width: 4, height: 22)
                .rotationEffect(.degrees(-25))
                .offset(x: -20, y: 50)
            Rectangle()
                .fill(legGray)
                .frame(width: 4, height: 22)
                .rotationEffect(.degrees(25))
                .offset(x: 20, y: 50)

            // Foot pads
            RoundedRectangle(cornerRadius: 1)
                .fill(Color(red: 0.35, green: 0.35, blue: 0.38))
                .frame(width: 8, height: 3)
                .offset(x: -26, y: 58)
            RoundedRectangle(cornerRadius: 1)
                .fill(Color(red: 0.35, green: 0.35, blue: 0.38))
                .frame(width: 8, height: 3)
                .offset(x: 26, y: 58)

            // Aft flaps (left)
            Parallelogram(angle: -20)
                .fill(
                    LinearGradient(
                        colors: [flapHighlight, flapDark],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 20, height: 16)
                .offset(x: -21, y: 24)
            // Aft flaps (right)
            Parallelogram(angle: 20)
                .fill(
                    LinearGradient(
                        colors: [flapHighlight, flapDark],
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    )
                )
                .frame(width: 20, height: 16)
                .offset(x: 21, y: 24)

            // Aft hinge lines
            Rectangle()
                .fill(strokeGray)
                .frame(width: 2, height: 14)
                .offset(x: -14, y: 24)
            Rectangle()
                .fill(strokeGray)
                .frame(width: 2, height: 14)
                .offset(x: 14, y: 24)

            // Main cylindrical body with dome top
            StarshipBody()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.58, green: 0.6, blue: 0.66),
                            Color(red: 0.93, green: 0.94, blue: 0.96),
                            Color(red: 0.73, green: 0.75, blue: 0.8),
                            Color(red: 0.42, green: 0.44, blue: 0.5)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 30, height: 80)

            // Body highlight strip (left reflection)
            Rectangle()
                .fill(highlightGray)
                .frame(width: 4, height: 55)
                .offset(x: -10, y: 2)

            // Heat shield tile strip
            RoundedRectangle(cornerRadius: 1)
                .fill(heatShield.opacity(0.88))
                .frame(width: 8, height: 52)
                .offset(x: 9, y: 2)

            ForEach([-20, -10, 0, 10, 20], id: \.self) { yPos in
                Rectangle()
                    .fill(Color.white.opacity(0.16))
                    .frame(width: 7, height: 0.5)
                    .offset(x: 9, y: CGFloat(yPos))
            }

            Ellipse()
                .fill(Color.white.opacity(0.22))
                .frame(width: 12, height: 6)
                .offset(x: -4, y: -29)

            // Panel seam lines (horizontal)
            ForEach([-16, 0, 16], id: \.self) { yPos in
                Rectangle()
                    .fill(strokeGray.opacity(0.5))
                    .frame(width: 24, height: 0.5)
                    .offset(y: CGFloat(yPos))
            }

            // Vertical panel seam
            Rectangle()
                .fill(strokeGray.opacity(0.3))
                .frame(width: 0.5, height: 48)
                .offset(y: 2)

            // Forward flaps (left)
            Parallelogram(angle: 25)
                .fill(
                    LinearGradient(
                        colors: [flapHighlight, flapDark],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 18, height: 14)
                .offset(x: -20, y: -22)
            // Forward flaps (right)
            Parallelogram(angle: -25)
                .fill(
                    LinearGradient(
                        colors: [flapHighlight, flapDark],
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    )
                )
                .frame(width: 18, height: 14)
                .offset(x: 20, y: -22)

            // Forward hinge lines
            Rectangle()
                .fill(strokeGray)
                .frame(width: 2, height: 12)
                .offset(x: -14, y: -22)
            Rectangle()
                .fill(strokeGray)
                .frame(width: 2, height: 12)
                .offset(x: 14, y: -22)

            // Engine skirt
            Trapezoid()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.38, green: 0.39, blue: 0.42), metalDark],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 34, height: 10)
                .offset(y: 42)

            Capsule()
                .fill(Color(red: 0.58, green: 0.59, blue: 0.62))
                .frame(width: 38, height: 2)
                .offset(y: 38)

            // Engine nozzles (3)
            ForEach([-8, 0, 8], id: \.self) { xPos in
                Trapezoid()
                    .fill(Color(red: 0.1, green: 0.1, blue: 0.12))
                    .frame(width: 7, height: 6)
                    .offset(x: CGFloat(xPos), y: 48)
            }
        }
    }
}

// MARK: - Trapezoid Shape
struct Trapezoid: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let inset: CGFloat = rect.width * 0.08
        path.move(to: CGPoint(x: inset, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX - inset, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Starship Body Shape
struct StarshipBody: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let domeHeight: CGFloat = rect.height * 0.15

        path.move(to: CGPoint(x: 0, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: domeHeight))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: domeHeight),
            control: CGPoint(x: rect.midX, y: -domeHeight * 0.5)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()

        return path
    }
}

// MARK: - Parallelogram Shape
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
