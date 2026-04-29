import SwiftUI

struct BabyBottleView: View {
    let fillLevel: Double
    
    var body: some View {
        Canvas { context, size in
            let w = size.width   // 60
            let h = size.height  // 130
            
            // --- TEAT ---
            let teatRect = CGRect(
                x: (w - 14) / 2,
                y: 0,
                width: 14,
                height: 10
            )
            context.fill(
                Path(ellipseIn: teatRect),
                with: .color(Color(hex: "E8C4B0").opacity(0.65))
            )
            
            // --- COLLAR ---
            let collarRect = CGRect(x: 16, y: 9, width: 28, height: 6)
            var collarPath = Path()
            collarPath.addRoundedRect(in: collarRect, cornerSize: CGSize(width: 2, height: 2))
            context.stroke(collarPath, with: .color(Color(hex: "E8C4B0")), lineWidth: 1.5)
            
            // --- NECK ---
            let neckRect = CGRect(x: 20, y: 14, width: 20, height: 10)
            var neckPath = Path()
            neckPath.addRect(neckRect)
            context.stroke(neckPath, with: .color(Color(hex: "E8C4B0")), lineWidth: 1.5)
            
            // --- SHOULDER ---
            var shoulderPath = Path()
            shoulderPath.move(to: CGPoint(x: 20, y: 24))
            shoulderPath.addCurve(
                to: CGPoint(x: 8, y: 40),
                control1: CGPoint(x: 20, y: 34),
                control2: CGPoint(x: 12, y: 40)
            )
            shoulderPath.addLine(to: CGPoint(x: 52, y: 40))
            shoulderPath.addCurve(
                to: CGPoint(x: 40, y: 24),
                control1: CGPoint(x: 48, y: 40),
                control2: CGPoint(x: 40, y: 34)
            )
            shoulderPath.closeSubpath()
            context.stroke(shoulderPath, with: .color(Color(hex: "E8C4B0")), lineWidth: 1.5)
            
            // --- BODY OUTLINE ---
            let bodyW: CGFloat = 44
            let bodyH: CGFloat = 80
            let bodyX: CGFloat = 8
            let bodyY: CGFloat = 40
            let bottomR: CGFloat = 14
            let topR: CGFloat = 2
            
            var bodyPath = Path()
            // Top left
            bodyPath.move(to: CGPoint(x: bodyX + topR, y: bodyY))
            bodyPath.addLine(to: CGPoint(x: bodyX + bodyW - topR, y: bodyY))
            // Top right corner
            bodyPath.addQuadCurve(
                to: CGPoint(x: bodyX + bodyW, y: bodyY + topR),
                control: CGPoint(x: bodyX + bodyW, y: bodyY)
            )
            // Right side
            bodyPath.addLine(to: CGPoint(x: bodyX + bodyW, y: bodyY + bodyH - bottomR))
            // Bottom right
            bodyPath.addArc(
                center: CGPoint(x: bodyX + bodyW - bottomR, y: bodyY + bodyH - bottomR),
                radius: bottomR,
                startAngle: .degrees(0),
                endAngle: .degrees(90),
                clockwise: false
            )
            // Bottom
            bodyPath.addLine(to: CGPoint(x: bodyX + bottomR, y: bodyY + bodyH))
            // Bottom left
            bodyPath.addArc(
                center: CGPoint(x: bodyX + bottomR, y: bodyY + bodyH - bottomR),
                radius: bottomR,
                startAngle: .degrees(90),
                endAngle: .degrees(180),
                clockwise: false
            )
            // Left side
            bodyPath.addLine(to: CGPoint(x: bodyX, y: bodyY + topR))
            // Top left corner
            bodyPath.addQuadCurve(
                to: CGPoint(x: bodyX + topR, y: bodyY),
                control: CGPoint(x: bodyX, y: bodyY)
            )
            bodyPath.closeSubpath()
            
            // Draw body outline
            context.stroke(bodyPath, with: .color(Color(hex: "E8C4B0")), lineWidth: 1.5)
            
            // --- LIQUID FILL (inside body) ---
            if fillLevel > 0 {
                let fillH = bodyH * CGFloat(min(fillLevel, 1.0))
                let fillY = bodyY + bodyH - fillH
                
                var fillPath = Path()
                fillPath.move(to: CGPoint(x: bodyX, y: fillY))
                fillPath.addLine(to: CGPoint(x: bodyX + bodyW, y: fillY))
                fillPath.addLine(to: CGPoint(x: bodyX + bodyW, y: bodyY + bodyH - bottomR))
                fillPath.addArc(
                    center: CGPoint(x: bodyX + bodyW - bottomR, y: bodyY + bodyH - bottomR),
                    radius: bottomR,
                    startAngle: .degrees(0),
                    endAngle: .degrees(90),
                    clockwise: false
                )
                fillPath.addLine(to: CGPoint(x: bodyX + bottomR, y: bodyY + bodyH))
                fillPath.addArc(
                    center: CGPoint(x: bodyX + bottomR, y: bodyY + bodyH - bottomR),
                    radius: bottomR,
                    startAngle: .degrees(90),
                    endAngle: .degrees(180),
                    clockwise: false
                )
                fillPath.addLine(to: CGPoint(x: bodyX, y: fillY))
                fillPath.closeSubpath()
                
                context.fill(fillPath, with: .color(Color(hex: "E8C4B0").opacity(0.45)))
            }
            
            // --- MEASUREMENT LINES ---
            let measureYValues: [CGFloat] = [100, 87, 73]
            for y in measureYValues {
                var linePath = Path()
                linePath.move(to: CGPoint(x: 16, y: y))
                linePath.addLine(to: CGPoint(x: 44, y: y))
                context.stroke(linePath, with: .color(Color(hex: "E8C4B0").opacity(0.4)), lineWidth: 0.5)
            }
        }
        .frame(width: 60, height: 130)
    }
}

#Preview {
    HStack(spacing: 40) {
        BabyBottleView(fillLevel: 0)
        BabyBottleView(fillLevel: 0.3)
        BabyBottleView(fillLevel: 0.7)
        BabyBottleView(fillLevel: 1.0)
    }
}
