import SwiftUI

struct BabyBottleView: View {
    let fillLevel: CGFloat
    let isAnimating: Bool
    
    @State private var wavePhase: CGFloat = 0
    @State private var bottleScale: CGFloat = 1.0
    @State private var liquidOffset: CGFloat = 0
    
    private var cappedFillLevel: CGFloat {
        min(fillLevel, 0.9)
    }
    
    var body: some View {
        ZStack {
            // Environment
            ambientGlow
            groundShadow
            
            // Bottle with exact bezier geometry
            ZStack {
                // Back wall
                ExactBottleShape()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.5),
                                Color.white.opacity(0.25),
                                Color.gray.opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Liquid
                LiquidContent(level: cappedFillLevel, phase: wavePhase, offset: liquidOffset)
                
                // Front wall
                ExactBottleShape()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.95),
                                Color.white.opacity(0.7),
                                Color.white.opacity(0.5),
                                Color.white.opacity(0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Left highlight
                ExactBottleShape()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white,
                                Color.white.opacity(0.6),
                                Color.clear,
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                // Right depth
                ExactBottleShape()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.clear,
                                Color.gray.opacity(0.35),
                                Color.gray.opacity(0.5)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                // Collar and teat
                CollarTeatAssembly()
                    .offset(y: 0)
                
                // Top highlight
                Ellipse()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 20, height: 4)
                    .offset(y: -75)
                    .blur(radius: 1)
            }
            .frame(width: 100, height: 180)
            .scaleEffect(bottleScale)
        }
        .onAppear {
            withAnimation(.linear(duration: 3.5).repeatForever(autoreverses: false)) {
                wavePhase = .pi * 2
            }
        }
        .onChange(of: isAnimating) { _, newValue in
            if newValue { animate() }
        }
    }
    
    private var ambientGlow: some View {
        RadialGradient(
            colors: [Color.white.opacity(0.4), Color.clear],
            center: .center,
            startRadius: 30,
            endRadius: 100
        )
        .frame(width: 200, height: 200)
        .blur(radius: 30)
    }
    
    private var groundShadow: some View {
        Ellipse()
            .fill(
                RadialGradient(
                    colors: [Color.black.opacity(0.18), Color.clear],
                    center: .center,
                    startRadius: 5,
                    endRadius: 50
                )
            )
            .frame(width: 80, height: 12)
            .offset(y: 88)
            .blur(radius: 10)
    }
    
    private func animate() {
        withAnimation(.easeOut(duration: 0.1)) {
            bottleScale = 0.96
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                bottleScale = 1.0
                liquidOffset = -3
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation(.easeOut(duration: 0.3)) {
                    liquidOffset = 0
                }
            }
        }
    }
}

// MARK: - Exact Bezier Bottle Shape
struct ExactBottleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Scale to fit frame
        let scaleX = rect.width / 100
        let scaleY = rect.height / 180
        let offsetX = rect.minX
        let offsetY = rect.minY
        
        func tx(_ x: CGFloat) -> CGFloat { offsetX + x * scaleX }
        func ty(_ y: CGFloat) -> CGFloat { offsetY + y * scaleY }
        
        // === LEFT SIDE (as specified) ===
        // 1. Move to (50, 170) - bottom center
        path.move(to: CGPoint(x: tx(50), y: ty(170)))
        
        // 2. Curve to (20, 160) with controls (35, 175), (25, 170)
        path.addCurve(
            to: CGPoint(x: tx(20), y: ty(160)),
            control1: CGPoint(x: tx(35), y: ty(175)),
            control2: CGPoint(x: tx(25), y: ty(170))
        )
        
        // 3. Curve to (15, 120) with controls (18, 150), (14, 135)
        path.addCurve(
            to: CGPoint(x: tx(15), y: ty(120)),
            control1: CGPoint(x: tx(18), y: ty(150)),
            control2: CGPoint(x: tx(14), y: ty(135))
        )
        
        // 4. Curve to (25, 85) with controls (16, 110), (22, 95)
        path.addCurve(
            to: CGPoint(x: tx(25), y: ty(85)),
            control1: CGPoint(x: tx(16), y: ty(110)),
            control2: CGPoint(x: tx(22), y: ty(95))
        )
        
        // 5. Curve to (38, 65) with controls (28, 78), (34, 70)
        path.addCurve(
            to: CGPoint(x: tx(38), y: ty(65)),
            control1: CGPoint(x: tx(28), y: ty(78)),
            control2: CGPoint(x: tx(34), y: ty(70))
        )
        
        // 6. Line to (38, 40)
        path.addLine(to: CGPoint(x: tx(38), y: ty(40)))
        
        // 7. Curve to (32, 35) with controls (38, 38), (34, 36)
        path.addCurve(
            to: CGPoint(x: tx(32), y: ty(35)),
            control1: CGPoint(x: tx(38), y: ty(38)),
            control2: CGPoint(x: tx(34), y: ty(36))
        )
        
        // 8. Curve to (28, 25) with controls (30, 33), (28, 28)
        path.addCurve(
            to: CGPoint(x: tx(28), y: ty(25)),
            control1: CGPoint(x: tx(30), y: ty(33)),
            control2: CGPoint(x: tx(28), y: ty(28))
        )
        
        // 9. Curve to (50, 15) with controls (32, 18), (40, 12)
        path.addCurve(
            to: CGPoint(x: tx(50), y: ty(15)),
            control1: CGPoint(x: tx(32), y: ty(18)),
            control2: CGPoint(x: tx(40), y: ty(12))
        )
        
        // === RIGHT SIDE (mirrored across x=50) ===
        // Mirror of step 9: curve from (50,15) to (72,25) with controls (60,12), (68,18)
        path.addCurve(
            to: CGPoint(x: tx(72), y: ty(25)),
            control1: CGPoint(x: tx(60), y: ty(12)),
            control2: CGPoint(x: tx(68), y: ty(18))
        )
        
        // Mirror of step 8: curve to (68,35) with controls (72,28), (70,33)
        path.addCurve(
            to: CGPoint(x: tx(68), y: ty(35)),
            control1: CGPoint(x: tx(72), y: ty(28)),
            control2: CGPoint(x: tx(70), y: ty(33))
        )
        
        // Mirror of step 7: curve to (62,40) with controls (66,36), (62,38)
        path.addCurve(
            to: CGPoint(x: tx(62), y: ty(40)),
            control1: CGPoint(x: tx(66), y: ty(36)),
            control2: CGPoint(x: tx(62), y: ty(38))
        )
        
        // Mirror of step 6: line to (62,65)
        path.addLine(to: CGPoint(x: tx(62), y: ty(65)))
        
        // Mirror of step 5: curve to (75,85) with controls (66,70), (72,78)
        path.addCurve(
            to: CGPoint(x: tx(75), y: ty(85)),
            control1: CGPoint(x: tx(66), y: ty(70)),
            control2: CGPoint(x: tx(72), y: ty(78))
        )
        
        // Mirror of step 4: curve to (85,120) with controls (78,95), (84,110)
        path.addCurve(
            to: CGPoint(x: tx(85), y: ty(120)),
            control1: CGPoint(x: tx(78), y: ty(95)),
            control2: CGPoint(x: tx(84), y: ty(110))
        )
        
        // Mirror of step 3: curve to (80,160) with controls (86,135), (82,150)
        path.addCurve(
            to: CGPoint(x: tx(80), y: ty(160)),
            control1: CGPoint(x: tx(86), y: ty(135)),
            control2: CGPoint(x: tx(82), y: ty(150))
        )
        
        // Mirror of step 2: curve to (50,170) with controls (75,170), (65,175)
        path.addCurve(
            to: CGPoint(x: tx(50), y: ty(170)),
            control1: CGPoint(x: tx(75), y: ty(170)),
            control2: CGPoint(x: tx(65), y: ty(175))
        )
        
        path.closeSubpath()
        return path
    }
}

// MARK: - Liquid
struct LiquidContent: View {
    let level: CGFloat
    let phase: CGFloat
    let offset: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LiquidBody(level: level)
                    .fill(
                        LinearGradient(
                            colors: [Color.emeraldLight, Color.emerald, Color.emeraldDeep],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .offset(y: offset)
                
                LiquidSurface(level: level, phase: phase)
                    .fill(Color.emeraldSurface)
                    .offset(y: offset)
                
                LiquidSurface(level: level, phase: phase + 0.5)
                    .fill(Color.white.opacity(0.35))
                    .offset(y: offset - 1)
            }
            .clipShape(ExactBottleShape())
        }
    }
}

struct LiquidBody: Shape {
    let level: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let bottomY: CGFloat = 165
        let fillHeight: CGFloat = 110 * level
        let surfaceY = bottomY - fillHeight
        
        path.move(to: CGPoint(x: 25, y: bottomY - 5))
        path.addQuadCurve(to: CGPoint(x: 75, y: bottomY - 5), control: CGPoint(x: 50, y: bottomY + 3))
        path.addLine(to: CGPoint(x: 78, y: surfaceY + 8))
        path.addQuadCurve(to: CGPoint(x: 22, y: surfaceY + 8), control: CGPoint(x: 50, y: surfaceY + 2))
        path.closeSubpath()
        return path
    }
}

struct LiquidSurface: Shape {
    let level: CGFloat
    let phase: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let bottomY: CGFloat = 165
        let fillHeight: CGFloat = 110 * level
        let baseY = bottomY - fillHeight + 6
        
        path.move(to: CGPoint(x: 22, y: baseY))
        for x in stride(from: 22, through: 78, by: 2) {
            let xFloat = CGFloat(x)
            let normalized = (xFloat - 22) / 56
            let angle = normalized * .pi * 1.5 + phase
            let sineValue = sin(angle)
            let y = baseY + sineValue * 2
            path.addLine(to: CGPoint(x: xFloat, y: y))
        }
        path.addLine(to: CGPoint(x: 78, y: baseY + 5))
        path.addLine(to: CGPoint(x: 22, y: baseY + 5))
        path.closeSubpath()
        return path
    }
}

// MARK: - Collar and Teat
struct CollarTeatAssembly: View {
    var body: some View {
        VStack(spacing: -1) {
            TeatView()
                .frame(width: 44, height: 26)
            
            RoundedRectangle(cornerRadius: 3)
                .fill(
                    LinearGradient(
                        colors: [Color.white, Color.gray.opacity(0.15), Color.white],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 26, height: 18)
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .fill(LinearGradient(colors: [Color.white.opacity(0.9), Color.clear], startPoint: .top, endPoint: .center))
                )
        }
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
        .offset(y: -75)
    }
}

struct TeatView: View {
    var body: some View {
        Canvas { context, size in
            let cx = size.width / 2
            let baseY = size.height - 2
            let tipY: CGFloat = 2
            let baseW: CGFloat = 36
            let tipW: CGFloat = 8
            
            var path = Path()
            path.move(to: CGPoint(x: cx - baseW/2, y: baseY))
            path.addCurve(to: CGPoint(x: cx - tipW/2, y: tipY), control1: CGPoint(x: cx - baseW/2, y: baseY - 12), control2: CGPoint(x: cx - tipW/2 - 6, y: tipY + 14))
            path.addCurve(to: CGPoint(x: cx + tipW/2, y: tipY), control1: CGPoint(x: cx, y: tipY - 4), control2: CGPoint(x: cx, y: tipY - 4))
            path.addCurve(to: CGPoint(x: cx + baseW/2, y: baseY), control1: CGPoint(x: cx + tipW/2 + 6, y: tipY + 14), control2: CGPoint(x: cx + baseW/2, y: baseY - 12))
            path.closeSubpath()
            
            context.fill(path, with: .linearGradient(
                Gradient(colors: [Color.teatLight, Color.teatMid, Color.teatDark]),
                startPoint: CGPoint(x: cx, y: tipY), endPoint: CGPoint(x: cx, y: baseY)
            ))
            
            context.fill(path, with: .linearGradient(
                Gradient(colors: [Color.white.opacity(0.6), Color.clear]),
                startPoint: CGPoint(x: 0, y: size.height/2), endPoint: CGPoint(x: cx, y: size.height/2)
            ))
            
            context.fill(Path(ellipseIn: CGRect(x: cx - 2, y: tipY, width: 4, height: 3)), with: .color(Color.teatDark.opacity(0.5)))
        }
    }
}

// MARK: - Colors
private extension Color {
    static let emeraldLight = Color(red: 0.30, green: 0.55, blue: 0.48)
    static let emerald = Color(red: 0.18, green: 0.44, blue: 0.37)
    static let emeraldDeep = Color(red: 0.10, green: 0.30, blue: 0.25)
    static let emeraldSurface = Color(red: 0.35, green: 0.60, blue: 0.52)
    
    static let teatLight = Color(red: 0.97, green: 0.92, blue: 0.88)
    static let teatMid = Color(red: 0.93, green: 0.86, blue: 0.79)
    static let teatDark = Color(red: 0.85, green: 0.76, blue: 0.68)
}

#Preview {
    ZStack {
        Color.white
        BabyBottleView(fillLevel: 0.6, isAnimating: false)
    }
}
