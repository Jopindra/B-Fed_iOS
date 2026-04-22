import SwiftUI
import SwiftData

// MARK: - Screen 1: Welcome
struct WelcomeScreen: View {
    let onContinue: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // MARK: Lemon crescent (top-centre)
                ZStack {
                    Circle()
                        .fill(Color.lemonIcing.opacity(0.75))
                        .frame(width: 200, height: 200)
                    Circle()
                        .fill(Color.backgroundBase)
                        .frame(width: 180, height: 180)
                        .offset(x: 22, y: -18)
                }
                .position(x: geometry.size.width / 2, y: 80)

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

                // MARK: Floating topic tags
                ZStack(alignment: .topLeading) {
                    TagPill(text: "INSIGHTS")
                        .rotationEffect(.degrees(3))
                        .offset(x: 200, y: 60)

                    TagPill(text: "TRACKING")
                        .rotationEffect(.degrees(-2))
                        .offset(x: 24, y: 108)

                    TagPill(text: "GROWTH")
                        .rotationEffect(.degrees(2))
                        .offset(x: 190, y: 130)

                    TagPill(text: "PATTERNS")
                        .rotationEffect(.degrees(-1))
                        .offset(x: 36, y: 152)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

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
                    .padding(.bottom, 16)

                    // Subtext
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Track feeds, spot patterns,")
                        Text("feel supported every step.")
                    }
                    .font(AppFont.sans(12))
                    .foregroundStyle(Color.inkSecondary)
                    .padding(.bottom, 24)

                    // Get started button
                    Button(action: onContinue) {
                        HStack(spacing: 0) {
                            Text("Get started")
                                .font(AppFont.sans(14, weight: .semibold))
                                .foregroundStyle(.white)
                            Spacer()
                            Text("→")
                                .font(AppFont.sans(18, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(.trailing, 18)
                        }
                        .frame(width: geometry.size.width - 36, height: 52)
                        .background(Color.inkPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.borderless)
                    .padding(.bottom, 16)

                    // Sign in link
                    Text("Already have an account? Sign in")
                        .font(AppFont.sans(11))
                        .foregroundStyle(Color.orchidTintDark)
                        .frame(width: geometry.size.width - 36, alignment: .center)
                }
                .padding(.leading, 20)
                .padding(.top, geometry.size.height * 0.44)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
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
