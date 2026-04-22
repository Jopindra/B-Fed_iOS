import SwiftUI
import SwiftData

// MARK: - Screen 1: Welcome
struct WelcomeScreen: View {
    let onContinue: () -> Void
    @State private var appearPhase = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // MARK: Lemon crescent (top-centre)
                ZStack {
                    Circle()
                        .fill(Color.lemonIcing.opacity(0.75))
                        .frame(width: 220, height: 220)
                    Circle()
                        .fill(Color.backgroundBase)
                        .frame(width: 180, height: 180)
                        .offset(x: 22, y: -18)
                }
                .position(x: geometry.size.width / 2, y: -36)
                .opacity(appearPhase >= 1 ? 1 : 0)

                // MARK: Peach accent (bottom-right)
                ZStack {
                    Ellipse()
                        .fill(Color.peachDust.opacity(0.35))
                        .frame(width: 240, height: 240)
                    Ellipse()
                        .fill(Color.orchidTint.opacity(0.40))
                        .frame(width: 160, height: 160)
                }
                .position(x: geometry.size.width, y: geometry.size.height)
                .opacity(appearPhase >= 1 ? 1 : 0)

                // MARK: Page indicator dots
                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 2.5, style: .continuous)
                        .fill(Color.inkPrimary)
                        .frame(width: 28, height: 5)
                    Circle()
                        .fill(Color.inkPrimary.opacity(0.22))
                        .frame(width: 5, height: 5)
                    Circle()
                        .fill(Color.inkPrimary.opacity(0.22))
                        .frame(width: 5, height: 5)
                    Circle()
                        .fill(Color.inkPrimary.opacity(0.22))
                        .frame(width: 5, height: 5)
                }
                .position(x: 51.5, y: 28.5)
                .opacity(appearPhase >= 2 ? 1 : 0)
                .offset(y: appearPhase >= 2 ? 0 : 8)

                // MARK: Floating topic tags
                ZStack(alignment: .topLeading) {
                    TagPill(text: "TRACKING")
                        .rotationEffect(.degrees(-2))
                        .offset(x: 18, y: 72)

                    TagPill(text: "INSIGHTS")
                        .rotationEffect(.degrees(3))
                        .offset(x: 188, y: 44)

                    TagPill(text: "PATTERNS")
                        .rotationEffect(.degrees(-1))
                        .offset(x: 28, y: 118)

                    TagPill(text: "GROWTH")
                        .rotationEffect(.degrees(2))
                        .offset(x: 192, y: 100)
                }
                .opacity(appearPhase >= 3 ? 1 : 0)
                .offset(y: appearPhase >= 3 ? 0 : 12)

                // MARK: Bottom content
                VStack(alignment: .leading, spacing: 0) {
                    // Headline
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Every feed,")
                            .frame(height: 38, alignment: .top)
                        Text("a little")
                            .frame(height: 38, alignment: .top)
                        Text("easier.")
                            .frame(height: 38, alignment: .top)
                    }
                    .font(AppFont.serif(32))
                    .foregroundStyle(Color.inkPrimary)
                    .padding(.bottom, 14)
                    .opacity(appearPhase >= 4 ? 1 : 0)
                    .offset(y: appearPhase >= 4 ? 0 : 14)

                    // Subtext
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Track feeds, spot patterns,")
                        Text("feel supported every step.")
                    }
                    .font(AppFont.sans(12))
                    .foregroundStyle(Color.inkSecondary)
                    .padding(.bottom, 24)
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
                                Text("→")
                                    .font(AppFont.sans(18, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .padding(.trailing, 18)
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
                .padding(.top, geometry.size.height * 0.52)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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
            .font(AppFont.sans(8, weight: .bold))
            .textCase(.uppercase)
            .tracking(0.5)
            .foregroundStyle(Color.inkPrimary)
            .frame(height: 22)
            .padding(.horizontal, 10)
            .background(Color.backgroundCard)
            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
    }
}

#Preview {
    WelcomeScreen {}
}
