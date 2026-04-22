import SwiftUI
import SwiftData

// MARK: - Screen 1: Welcome
struct WelcomeScreen: View {
    let onContinue: () -> Void
    @State private var appearPhase = 0
    
    let tags: [(text: String, rotation: Double, xOffset: CGFloat, yOffset: CGFloat)] = [
        ("TRACKING", -2.0, -70, -10),
        ("INSIGHTS", 3.0, 60, -28),
        ("GROWTH", -1.0, 90, 5),
        ("PATTERNS", 2.0, -20, 25)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Top-right organic blob — bleeds off corner, ~60% visible
                OrganicBlobShape()
                    .fill(Color.peachDust)
                    .frame(width: 280, height: 280)
                    .position(x: geometry.size.width + 20, y: -20)
                    .zIndex(0)
                    .opacity(appearPhase >= 1 ? 1 : 0)
                
                // Orchid accent blob — sits behind floating tags
                Circle()
                    .fill(Color.orchidTint.opacity(0.6))
                    .frame(width: 110, height: 110)
                    .position(x: geometry.size.width - 60, y: geometry.size.height * 0.18 + 45)
                    .zIndex(0)
                    .opacity(appearPhase >= 1 ? 1 : 0)
                
                VStack(spacing: 0) {
                    Spacer().frame(height: geometry.size.height * 0.18)
                    
                    // Floating topic tags
                    ZStack {
                        ForEach(tags.indices, id: \.self) { i in
                            Text(tags[i].text)
                                .font(AppFont.sans(12, weight: .bold))
                                .foregroundStyle(Color.inkPrimary)
                                .padding(.horizontal, AppSpacing.md)
                                .padding(.vertical, AppSpacing.sm)
                                .background(Color.backgroundCard)
                                .clipShape(Capsule())
                                .rotationEffect(.degrees(tags[i].rotation))
                                .offset(x: tags[i].xOffset, y: tags[i].yOffset)
                        }
                    }
                    .frame(height: 90)
                    .zIndex(2)
                    .opacity(appearPhase >= 2 ? 1 : 0)
                    .offset(y: appearPhase >= 2 ? 0 : 14)
                    
                    Spacer().frame(height: 36)
                    
                    // Headline with decorative star
                    ZStack(alignment: .topTrailing) {
                        Text("Feel confident\nfeeding your baby")
                            .font(AppFont.serif(38))
                            .foregroundStyle(Color.inkPrimary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        StarShape()
                            .fill(Color.orchidTintDark.opacity(0.8))
                            .frame(width: 34, height: 34)
                            .offset(x: 10, y: -18)
                    }
                    .zIndex(2)
                    .opacity(appearPhase >= 3 ? 1 : 0)
                    .offset(y: appearPhase >= 3 ? 0 : 16)
                    
                    Spacer()
                    
                    // CTA — 88% width, centred
                    Button(action: onContinue) {
                        HStack(spacing: 10) {
                            Text("Get started")
                                .font(AppFont.bodyLarge)
                            Image(systemName: "arrow.right")
                                .font(AppFont.bodyLarge)
                        }
                        .foregroundStyle(.white)
                        .frame(width: geometry.size.width * 0.88)
                    }
                    .primaryButton()
                    .padding(.bottom, AppSpacing.xxl)
                    .opacity(appearPhase >= 4 ? 1 : 0)
                    .offset(y: appearPhase >= 4 ? 0 : 16)
                }
                .zIndex(1)
                .padding(.horizontal, AppSpacing.xl)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) { appearPhase = 1 }
            withAnimation(.easeOut(duration: 0.5).delay(0.15)) { appearPhase = 2 }
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) { appearPhase = 3 }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.82).delay(0.45)) { appearPhase = 4 }
        }
    }
}

// MARK: - Decorative Shapes

struct OrganicBlobShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        path.move(to: CGPoint(x: w * 0.5, y: 0))
        path.addCurve(
            to: CGPoint(x: w, y: h * 0.4),
            control1: CGPoint(x: w * 0.85, y: 0),
            control2: CGPoint(x: w, y: h * 0.15)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.55, y: h),
            control1: CGPoint(x: w, y: h * 0.8),
            control2: CGPoint(x: w * 0.75, y: h)
        )
        path.addCurve(
            to: CGPoint(x: 0, y: h * 0.6),
            control1: CGPoint(x: w * 0.25, y: h),
            control2: CGPoint(x: 0, y: h * 0.85)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: 0),
            control1: CGPoint(x: 0, y: h * 0.2),
            control2: CGPoint(x: w * 0.15, y: 0)
        )
        path.closeSubpath()
        return path
    }
}

struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) / 2
        let inner = outer * 0.4
        
        for i in 0..<8 {
            let angle = CGFloat(i) * .pi / 4 - .pi / 2
            let r = i % 2 == 0 ? outer : inner
            let pt = CGPoint(x: c.x + r * cos(angle), y: c.y + r * sin(angle))
            if i == 0 {
                path.move(to: pt)
            } else {
                path.addLine(to: pt)
            }
        }
        path.closeSubpath()
        return path
    }
}

#Preview {
    WelcomeScreen {}
}
