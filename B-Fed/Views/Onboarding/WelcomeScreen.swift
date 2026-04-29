import SwiftUI
import SwiftData

// MARK: - Tag Style
extension Text {
    func tagStyle() -> some View {
        self
            .font(AppFont.sans(11, weight: .bold))
            .textCase(.uppercase)
            .tracking(0.6)
            .foregroundStyle(Color.inkPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.backgroundCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.inkPrimary.opacity(AppMetrics.borderOpacity), lineWidth: AppMetrics.borderWidth)
                    )
            )
    }
}

// MARK: - Screen 1: Welcome
struct WelcomeScreen: View {
    let onContinue: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.backgroundBase
                    .ignoresSafeArea()

                // MARK: Background decorative shapes
                ZStack {
                    // Bottom-left — Peach
                    Ellipse()
                        .fill(Color.peachDust.opacity(0.85))
                        .accessibilityHidden(true)
                        .frame(
                            width: geometry.size.width * 0.74 * 2,
                            height: geometry.size.width * 0.74 * 2
                        )
                        .position(x: 0, y: geometry.size.height)

                    Ellipse()
                        .fill(Color.peachLemonBridge.opacity(0.90))
                        .accessibilityHidden(true)
                        .frame(
                            width: geometry.size.width * 0.46 * 2,
                            height: geometry.size.width * 0.46 * 2
                        )
                        .position(x: 0, y: geometry.size.height)

                    // Bottom-right — Aqua
                    Ellipse()
                        .fill(Color.almostAqua.opacity(0.70))
                        .accessibilityHidden(true)
                        .frame(
                            width: geometry.size.width * 0.54 * 2,
                            height: geometry.size.width * 0.54 * 2
                        )
                        .position(x: geometry.size.width, y: geometry.size.height)

                    Ellipse()
                        .fill(Color.almostAquaLight.opacity(0.85))
                        .accessibilityHidden(true)
                        .frame(
                            width: geometry.size.width * 0.31 * 2,
                            height: geometry.size.width * 0.31 * 2
                        )
                        .position(x: geometry.size.width, y: geometry.size.height)

                    // Top-right — Orchid
                    Ellipse()
                        .fill(Color.orchidTint.opacity(0.75))
                        .accessibilityHidden(true)
                        .frame(
                            width: geometry.size.width * 0.57 * 2,
                            height: geometry.size.width * 0.57 * 2
                        )
                        .position(x: geometry.size.width, y: 0)

                    Ellipse()
                        .fill(Color.orchidTintLight.opacity(0.90))
                        .accessibilityHidden(true)
                        .frame(
                            width: geometry.size.width * 0.35 * 2,
                            height: geometry.size.width * 0.35 * 2
                        )
                        .position(x: geometry.size.width, y: 0)

                    // Centre fade
                    Ellipse()
                        .fill(Color.backgroundBase.opacity(0.65))
                        .accessibilityHidden(true)
                        .frame(
                            width: geometry.size.width * 0.46 * 2,
                            height: geometry.size.height * 0.29 * 2
                        )
                        .position(
                            x: geometry.size.width * 0.50,
                            y: geometry.size.height * 0.52
                        )

                    // Lemon crescent top-centre (existing, unchanged)
                    ZStack {
                        Circle()
                            .fill(Color.lemonIcing.opacity(0.75))
                            .accessibilityHidden(true)
                            .frame(
                                width: geometry.size.width * 0.55,
                                height: geometry.size.width * 0.55
                            )
                        Circle()
                            .fill(Color.backgroundBase)
                            .frame(
                                width: geometry.size.width * 0.43,
                                height: geometry.size.width * 0.43
                            )
                            .offset(
                                x: geometry.size.width * 0.11,
                                y: -geometry.size.width * 0.07
                            )
                            .accessibilityHidden(true)
                    }
                    .position(
                        x: geometry.size.width * 0.50,
                        y: geometry.size.width * 0.08
                    )
                    .accessibilityHidden(true)
                }
                .ignoresSafeArea()
                .allowsHitTesting(false)

                // MARK: Foreground content
                VStack(alignment: .leading, spacing: 0) {
                    // Floating topic tags
                    ZStack(alignment: .topLeading) {
                        Color.clear
                            .frame(height: geometry.size.height * 0.38)

                        Text("INSIGHTS")
                            .tagStyle()
                            .offset(
                                x: geometry.size.width * 0.54,
                                y: geometry.size.height * 0.14
                            )
                            .rotationEffect(.degrees(3))
                            .accessibilityHidden(true)

                        Text("TRACKING")
                            .tagStyle()
                            .offset(
                                x: geometry.size.width * 0.06,
                                y: geometry.size.height * 0.20
                            )
                            .rotationEffect(.degrees(-2))
                            .accessibilityHidden(true)

                        Text("GROWTH")
                            .tagStyle()
                            .offset(
                                x: geometry.size.width * 0.50,
                                y: geometry.size.height * 0.26
                            )
                            .rotationEffect(.degrees(2))
                            .accessibilityHidden(true)

                        Text("PATTERNS")
                            .tagStyle()
                            .offset(
                                x: geometry.size.width * 0.08,
                                y: geometry.size.height * 0.30
                            )
                            .rotationEffect(.degrees(-1))
                            .accessibilityHidden(true)
                    }

                    Color.clear
                        .frame(height: geometry.size.height * 0.04)

                    // Headline
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Every feed,")
                        Text("a little")
                        Text("easier.")
                    }
                    .font(AppFont.display)
                    .foregroundColor(Color.inkPrimary)
                    .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Track feeds, spot patterns,")
                        Text("feel supported every step.")
                    }
                    .font(AppFont.bodyLarge)
                    .foregroundColor(.inkSecondary)
                    .padding(.top, 16)
                    .padding(.horizontal, 20)

                    Spacer()

                    // Bottom CTA
                    VStack(spacing: 14) {
                        Button(action: onContinue) {
                            HStack {
                                Text("Get started")
                                    .font(AppFont.input)
                                    .tracking(0.3)
                                    .foregroundColor(Color.backgroundCard)
                                    .padding(.leading, 24)
                                Spacer()
                                Text("→")
                                    .foregroundColor(Color.backgroundCard)
                                    .font(AppFont.sans(20, weight: .medium))
                                    .padding(.trailing, 24)
                            }
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.inkPrimary)
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint("Begins the onboarding setup")
                        .accessibilityIdentifier("onboarding-getStarted-button")

                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, max(geometry.safeAreaInsets.bottom, 32) + AppSpacing.xl)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    WelcomeScreen {}
}
