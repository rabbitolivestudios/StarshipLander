import SwiftUI

// MARK: - Rocket Illustration (Menu)
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
