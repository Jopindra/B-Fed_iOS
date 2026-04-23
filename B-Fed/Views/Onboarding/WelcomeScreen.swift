import SwiftUI
import SwiftData

// MARK: - Screen 1: Welcome
struct WelcomeScreen: View {
    let onContinue: () -> Void

    var body: some View {
        GeometryReader { geometry in
            let safeTop = geometry.safeAreaInsets.top
            let safeBottom = geometry.safeAreaInsets.bottom
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack(alignment: .bottom) {
                // MARK: Background — fills entire screen edge-to-edge
                Color.backgroundBase

                // MARK: Crescent (top-centre, proportional)
                ZStack {
                    Circle()
                        .fill(Color.lemonIcing.opacity(0.75))
                        .frame(width: width * 0.55, height: width * 0.55)
                    Circle()
                        .fill(Color.backgroundBase)
                        .frame(width: 180, height: 180)
                        .offset(x: width * 0.12, y: -height * 0.06)
                }
                .position(x: width * 0.5, y: height * 0.18)

                // MARK: Peach accent (bottom-right)
                ZStack {
                    Ellipse()
                        .fill(Color.peachDust.opacity(0.35))
                        .frame(width: 240, height: 240)
                    Ellipse()
                        .fill(Color.orchidTint.opacity(0.40))
                        .frame(width: 160, height: 160)
                }
                .position(x: width, y: height)

                // MARK: Floating topic tags (upper zone, above headline)
                ZStack(alignment: .topLeading) {
                    TagPill(text: "INSIGHTS")
                        .rotationEffect(.degrees(3))
                        .offset(x: 200, y: height * 0.16)

                    TagPill(text: "TRACKING")
                        .rotationEffect(.degrees(-2))
                        .offset(x: 24, y: height * 0.24)

                    TagPill(text: "GROWTH")
                        .rotationEffect(.degrees(2))
                        .offset(x: 190, y: height * 0.34)

                    TagPill(text: "PATTERNS")
                        .rotationEffect(.degrees(-1))
                        .offset(x: 40, y: height * 0.42)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                // MARK: Main content (dots, headline, subtext)
                VStack(alignment: .leading, spacing: 0) {
                    // Page indicator dots — 20 pt below status bar
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
                    .padding(.bottom, 16)

                    // Spacer pushes headline down to ~52 % of screen height
                    Spacer()
                        .frame(height: max(0, height * 0.52 - (safeTop + 20 + 5 + 16)))

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
                    .padding(.bottom, 16)

                    // Subtext
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Track feeds, spot patterns,")
                        Text("feel supported every step.")
                    }
                    .font(AppFont.sans(12))
                    .foregroundStyle(Color.inkSecondary)

                    // Fill remaining space so content stays anchored to top
                    Spacer()
                }
                .padding(.top, safeTop + 20)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                // MARK: Bottom CTA — pinned above bottom safe area
                VStack(spacing: 16) {
                    Button(action: onContinue) {
                        HStack(spacing: 0) {
                            Text("Get started")
                                .font(AppFont.sans(14, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(.leading, 24)
                            Spacer()
                            Text("→")
                                .font(AppFont.sans(18, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(.trailing, 24)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.inkPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.borderless)

                    Text("Already have an account? Sign in")
                        .font(AppFont.sans(11))
                        .foregroundStyle(Color.orchidTintDark)
                }
                .padding(.horizontal, 18)
                .padding(.bottom, safeBottom + 20)
                .background(Color.backgroundBase)
            }
        }
        .ignoresSafeArea(.all)
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
