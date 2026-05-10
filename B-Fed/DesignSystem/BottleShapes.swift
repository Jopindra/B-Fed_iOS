import SwiftUI

// MARK: - Bottle Glass Shape (used by LogFeedView)
struct BottleGlassShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let neckWidth = width * 0.35
        let bodyWidth = width * 0.75
        path.move(to: CGPoint(x: (width - bodyWidth) / 2, y: height - 15))
        path.addCurve(
            to: CGPoint(x: (width + bodyWidth) / 2, y: height - 15),
            control1: CGPoint(x: (width - bodyWidth) / 2 + 8, y: height),
            control2: CGPoint(x: (width + bodyWidth) / 2 - 8, y: height)
        )
        path.addLine(to: CGPoint(x: (width + bodyWidth) / 2, y: height * 0.35))
        path.addCurve(
            to: CGPoint(x: (width + neckWidth) / 2, y: height * 0.25),
            control1: CGPoint(x: (width + bodyWidth) / 2 - 4, y: height * 0.35 - 8),
            control2: CGPoint(x: (width + neckWidth) / 2 + 4, y: height * 0.25 + 8)
        )
        path.addLine(to: CGPoint(x: (width + neckWidth) / 2, y: 20))
        path.addCurve(
            to: CGPoint(x: (width - neckWidth) / 2, y: 20),
            control1: CGPoint(x: (width + neckWidth) / 2 - 2, y: 16),
            control2: CGPoint(x: (width - neckWidth) / 2 + 2, y: 16)
        )
        path.addLine(to: CGPoint(x: (width - neckWidth) / 2, y: height * 0.25))
        path.addCurve(
            to: CGPoint(x: (width - bodyWidth) / 2, y: height * 0.35),
            control1: CGPoint(x: (width - neckWidth) / 2 - 4, y: height * 0.25 + 8),
            control2: CGPoint(x: (width - bodyWidth) / 2 + 4, y: height * 0.35 - 8)
        )
        path.closeSubpath()
        return path
    }
}

// MARK: - Liquid with Wave (used by LogFeedView)
struct LiquidWithWave: View {
    let fillLevel: CGFloat
    let phase: CGFloat
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(Color.almostAquaDark)
                    .frame(height: geometry.size.height * fillLevel)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                DashboardWaveShape(fillLevel: fillLevel, phase: phase)
                    .fill(Color.almostAqua.opacity(0.9))
                    .frame(height: geometry.size.height)
            }
        }
    }
}

// MARK: - Wave Shape (used by LogFeedView)
struct DashboardWaveShape: Shape {
    let fillLevel: CGFloat
    let phase: CGFloat
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let waterLevel = rect.height * (1 - fillLevel)
        let width = rect.width
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: waterLevel))
        for x in stride(from: 0, to: width, by: 2) {
            let relativeX = x / width
            let sine = sin(relativeX * .pi * 3 + phase)
            let y = waterLevel + sine * 3
            path.addLine(to: CGPoint(x: x, y: y))
        }
        path.addLine(to: CGPoint(x: width, y: rect.height))
        path.closeSubpath()
        return path
    }
}
