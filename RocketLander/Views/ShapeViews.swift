import SwiftUI

// MARK: - Rocket Illustration (Menu)
struct RocketIllustration: View {
    let bodyGray = Color(red: 0.82, green: 0.83, blue: 0.85)
    let highlightGray = Color(red: 0.88, green: 0.89, blue: 0.91)
    let strokeGray = Color(red: 0.6, green: 0.6, blue: 0.63)
    let flapDark = Color(red: 0.18, green: 0.18, blue: 0.2)
    let metalDark = Color(red: 0.15, green: 0.15, blue: 0.17)
    let legGray = Color(red: 0.45, green: 0.45, blue: 0.48)

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
                .frame(width: 24, height: 50)
                .offset(y: 65)

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
                .fill(flapDark)
                .frame(width: 20, height: 16)
                .offset(x: -21, y: 24)
            // Aft flaps (right)
            Parallelogram(angle: 20)
                .fill(flapDark)
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
                .fill(bodyGray)
                .frame(width: 30, height: 80)

            // Body highlight strip (left reflection)
            Rectangle()
                .fill(highlightGray)
                .frame(width: 4, height: 55)
                .offset(x: -10, y: 2)

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
                .fill(flapDark)
                .frame(width: 18, height: 14)
                .offset(x: -20, y: -22)
            // Forward flaps (right)
            Parallelogram(angle: -25)
                .fill(flapDark)
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
                .fill(metalDark)
                .frame(width: 34, height: 10)
                .offset(y: 42)

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

// MARK: - Triangle Shape
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
