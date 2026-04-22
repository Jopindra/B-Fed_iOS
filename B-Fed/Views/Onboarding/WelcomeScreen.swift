import SwiftUI
import SwiftData

// MARK: - Screen 1: Welcome
struct WelcomeScreen: View {
    let onContinue: () -> Void
    @State private var appearPhase = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // MARK: Sunrise arc layers
                ZStack {
                    Ellipse()
                        .fill(Color.peachDust)
                        .frame(width: 460, height: 460)
                    Ellipse()
                        .fill(Color.peachLemonBridge)
                        .frame(width: 384, height: 384)
                    Ellipse()
                        .fill(Color.lemonIcing)
                        .frame(width: 312, height: 312)
                    Ellipse()
                        .fill(Color.almostAquaLight)
                        .frame(width: 240, height: 240)
                    Ellipse()
                        .fill(Color.orchidTintLight)
                        .frame(width: 168, height: 168)
                    Ellipse()
                        .fill(Color(hex: "F0EDF2"))
                        .frame(width: 96, height: 96)
                }
                .position(x: geometry.size.width, y: 0)
                .opacity(appearPhase >= 1 ? 1 : 0)

                // MARK: Wash overlay
                Color.backgroundBase
                    .opacity(0.38)
                    .ignoresSafeArea()
                    .opacity(appearPhase >= 1 ? 1 : 0)

                // MARK: Crescent moon
                ZStack {
                    Ellipse()
                        .fill(Color.lemonIcing.opacity(0.92))
                        .frame(width: 124, height: 124)
                    Ellipse()
                        .fill(Color.backgroundBase)
                        .frame(width: 88, height: 88)
                        .offset(x: 18, y: -18)
                }
                .position(x: geometry.size.width - 90, y: 95)
                .opacity(appearPhase >= 2 ? 1 : 0)
                .offset(y: appearPhase >= 2 ? 0 : 10)

                // MARK: Page indicator dots
                HStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 3.5, style: .continuous)
                        .fill(Color.inkPrimary)
                        .frame(width: 38, height: 7)
                    Circle()
                        .fill(Color.inkPrimary.opacity(0.22))
                        .frame(width: 7, height: 7)
                    Circle()
                        .fill(Color.inkPrimary.opacity(0.22))
                        .frame(width: 7, height: 7)
                    Circle()
                        .fill(Color.inkPrimary.opacity(0.22))
                        .frame(width: 7, height: 7)
                }
                .position(x: 62.5, y: 29.5)
                .opacity(appearPhase >= 2 ? 1 : 0)
                .offset(y: appearPhase >= 2 ? 0 : 8)

                // MARK: Floating topic tags
                ZStack {
                    TagPill(text: "TRACKING")
                        .rotationEffect(.degrees(-2))
                        .position(x: 70, y: 90)

                    TagPill(text: "INSIGHTS")
                        .rotationEffect(.degrees(3))
                        .position(x: geometry.size.width - 70, y: 60)

                    TagPill(text: "PATTERNS")
                        .rotationEffect(.degrees(-1))
                        .position(x: 110, y: 150)

                    TagPill(text: "GROWTH")
                        .rotationEffect(.degrees(2))
                        .position(x: geometry.size.width - 100, y: 120)
                }
                .opacity(appearPhase >= 3 ? 1 : 0)
                .offset(y: appearPhase >= 3 ? 0 : 12)

                // MARK: Bottom content
                VStack(alignment: .leading, spacing: 0) {
                    // Headline
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Feel confident")
                        Text("feeding your")
                        Text("baby")
                    }
                    .font(AppFont.serif(32))
                    .foregroundStyle(Color.inkPrimary)
                    .padding(.bottom, 16)
                    .opacity(appearPhase >= 4 ? 1 : 0)
                    .offset(y: appearPhase >= 4 ? 0 : 14)

                    // Subtext
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Track feeds, spot patterns,")
                        Text("feel supported every step.")
                    }
                    .font(AppFont.sans(12))
                    .foregroundStyle(Color.inkSecondary)
                    .padding(.bottom, 28)
                    .opacity(appearPhase >= 4 ? 1 : 0)
                    .offset(y: appearPhase >= 4 ? 0 : 10)

                    // Get started button
                    Button(action: onContinue) {
                        ZStack {
                            Text("Get started")
                                .font(AppFont.sans(14, weight: .semibold))
                                .foregroundStyle(.white)

                            HStack {
                                Spacer()
                                Image(systemName: "arrow.right")
                                    .font(AppFont.sans(14, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .padding(.trailing, 16)
                            }
                        }
                        .frame(width: geometry.size.width - 36, height: 52)
                        .background(Color.inkPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 16)
                    .opacity(appearPhase >= 5 ? 1 : 0)
                    .offset(y: appearPhase >= 5 ? 0 : 14)

                    // Sign in link
                    Text("Already have an account? Sign in")
                        .font(AppFont.sans(11))
                        .foregroundStyle(Color.orchidTintDark)
                        .frame(width: geometry.size.width - 36, alignment: .center)
                        .opacity(appearPhase >= 5 ? 1 : 0)
                        .offset(y: appearPhase >= 5 ? 0 : 10)
                }
                .padding(.leading, 20)
                .padding(.bottom, 50)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) { appearPhase = 1 }
            withAnimation(.easeOut(duration: 0.5).delay(0.15)) { appearPhase = 2 }
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) { appearPhase = 3 }
            withAnimation(.easeOut(duration: 0.5).delay(0.45)) { appearPhase = 4 }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.82).delay(0.6)) { appearPhase = 5 }
        }
    }
}

// MARK: - Tag Pill
struct TagPill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(AppFont.sans(10, weight: .bold))
            .textCase(.uppercase)
            .tracking(0.7)
            .foregroundStyle(Color.inkPrimary)
            .frame(height: 28)
            .padding(.horizontal, 14)
            .background(Color.backgroundCard)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// MARK: - Decorative Shapes (retained for module compatibility)

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
