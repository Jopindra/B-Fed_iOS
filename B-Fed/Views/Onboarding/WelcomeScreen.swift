import SwiftUI
import SwiftData

// MARK: - Tag Style
extension Text {
    func tagStyle() -> some View {
        self
            .font(AppFont.sans(10, weight: .bold))
            .textCase(.uppercase)
            .tracking(0.5)
            .foregroundStyle(Color.inkPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
    }
}

// MARK: - Screen 1: Welcome
struct WelcomeScreen: View {
    let onContinue: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(hex: "FAFAF8")
                    .ignoresSafeArea(.all)

                // MARK: Background decorative shapes
                ZStack {
                    // Lemon crescent top-centre
                    ZStack {
                        Circle()
                            .fill(Color.lemonIcing.opacity(0.75))
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
                    }
                    .position(
                        x: geometry.size.width * 0.50,
                        y: geometry.size.width * 0.08
                    )

                    // Peach blob outer — bottom-right
                    Ellipse()
                        .fill(Color.peachDust.opacity(0.80))
                        .frame(
                            width: geometry.size.width * 0.38,
                            height: geometry.size.width * 0.38
                        )
                        .position(
                            x: geometry.size.width,
                            y: geometry.size.height
                        )

                    // Peach blob inner — bottom-right
                    Ellipse()
                        .fill(Color.lemonIcing.opacity(0.85))
                        .frame(
                            width: geometry.size.width * 0.26,
                            height: geometry.size.width * 0.26
                        )
                        .position(
                            x: geometry.size.width,
                            y: geometry.size.height
                        )

                    // Aqua blob — bottom-left
                    Ellipse()
                        .fill(Color.almostAquaLight.opacity(0.75))
                        .frame(
                            width: geometry.size.width * 0.24,
                            height: geometry.size.width * 0.24
                        )
                        .position(
                            x: 0,
                            y: geometry.size.height
                        )

                    // Orchid accent blob
                    Ellipse()
                        .fill(Color.orchidTint.opacity(0.50))
                        .frame(
                            width: geometry.size.width * 0.16,
                            height: geometry.size.width * 0.16
                        )
                        .position(
                            x: geometry.size.width * 0.15,
                            y: geometry.size.height * 0.75
                        )
                }
                .ignoresSafeArea(.all)

                // MARK: Foreground content
                VStack(alignment: .leading, spacing: 0) {
                    // Page indicator dots
                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.inkPrimary)
                            .frame(width: 24, height: 6)
                        ForEach(0..<3) { _ in
                            Circle()
                                .fill(Color.inkPrimary.opacity(0.35))
                                .frame(width: 6, height: 6)
                        }
                    }
                    .padding(.top, geometry.safeAreaInsets.top + 16)
                    .padding(.leading, 20)

                    // Floating topic tags
                    ZStack(alignment: .topLeading) {
                        Color.clear
                            .frame(height: geometry.size.height * 0.38)

                        Text("INSIGHTS")
                            .tagStyle()
                            .offset(
                                x: geometry.size.width * 0.55,
                                y: geometry.size.height * 0.04
                            )
                            .rotationEffect(.degrees(3))

                        Text("TRACKING")
                            .tagStyle()
                            .offset(
                                x: geometry.size.width * 0.08,
                                y: geometry.size.height * 0.10
                            )
                            .rotationEffect(.degrees(-2))

                        Text("GROWTH")
                            .tagStyle()
                            .offset(
                                x: geometry.size.width * 0.52,
                                y: geometry.size.height * 0.17
                            )
                            .rotationEffect(.degrees(2))

                        Text("PATTERNS")
                            .tagStyle()
                            .offset(
                                x: geometry.size.width * 0.10,
                                y: geometry.size.height * 0.22
                            )
                            .rotationEffect(.degrees(-1))
                    }

                    Color.clear
                        .frame(height: geometry.size.height * 0.04)

                    // Headline
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Every feed,")
                        Text("a little")
                        Text("easier.")
                    }
                    .font(AppFont.serif(38))
                    .foregroundColor(Color.inkPrimary)
                    .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Track feeds, spot patterns,")
                        Text("feel supported every step.")
                    }
                    .font(.custom("DMSans-Regular", size: 15))
                    .foregroundColor(Color(hex: "5A5555"))
                    .padding(.top, 16)
                    .padding(.horizontal, 20)

                    Spacer()

                    // Bottom CTA
                    VStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.inkPrimary)
                                .frame(height: 58)
                            HStack {
                                Text("Get started")
                                    .font(AppFont.sans(17, weight: .semibold))
                                    .tracking(0.3)
                                    .foregroundColor(.white)
                                    .padding(.leading, 24)
                                Spacer()
                                Text("→")
                                    .foregroundColor(.white)
                                    .font(.system(size: 20))
                                    .padding(.trailing, 24)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .onTapGesture { onContinue() }

                        Text("Already have an account? Sign in")
                            .font(.custom("DMSans-Regular", size: 11))
                            .foregroundColor(Color(hex: "8A7E96"))
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, max(geometry.safeAreaInsets.bottom, 34) + 16)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
            .ignoresSafeArea(.all)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea(.all)
    }
}

#Preview {
    WelcomeScreen {}
}
