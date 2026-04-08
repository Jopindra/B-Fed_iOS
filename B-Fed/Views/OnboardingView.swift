import SwiftUI

// MARK: - Onboarding View
struct OnboardingView: View {
    @Environment(FeedStore.self) private var feedStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentStep = 0
    @State private var ageWeeks = 0
    @State private var weightText = ""
    @State private var feedingType: FeedingType = .formula
    
    var body: some View {
        ZStack {
            CalmBackground()
            
            VStack(spacing: 0) {
                // Skip button - refined positioning
                HStack {
                    Spacer()
                    if currentStep < 2 {
                        Button("Skip") {
                            completeOnboarding()
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.textMuted.opacity(0.75))
                        .padding(.top, 12)
                        .padding(.trailing, 24)
                    }
                }
                
                // Content
                TabView(selection: $currentStep) {
                    WelcomeStep()
                        .tag(0)
                    
                    BabyDetailsStep(
                        ageWeeks: $ageWeeks,
                        weightText: $weightText,
                        feedingType: $feedingType
                    )
                    .tag(1)
                    
                    ReadyStep(
                        ageWeeks: ageWeeks,
                        weightKg: Double(weightText)
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.4), value: currentStep)
                
                // Bottom button
                VStack(spacing: 0) {
                    Button(action: handlePrimaryAction) {
                        Text(buttonText)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.emeraldSoft)
                            .clipShape(Capsule())
                            .shadow(color: Color.emeraldSoft.opacity(0.14), radius: 6, x: 0, y: 2)
                    }
                    .buttonStyle(CalmPressButtonStyle())
                    .padding(.horizontal, 24)
                    .padding(.bottom, 34)
                }
            }
        }
    }
    
    private var buttonText: String {
        switch currentStep {
        case 0: return "Get started"
        case 1: return "Continue"
        default: return "Start tracking"
        }
    }
    
    private func handlePrimaryAction() {
        if currentStep < 2 {
            withAnimation(.easeInOut(duration: 0.4)) {
                currentStep += 1
            }
        } else {
            completeOnboarding()
        }
    }
    
    private func completeOnboarding() {
        let profile = BabyProfile(
            babyName: "Baby",
            dateOfBirth: Calendar.current.date(byAdding: .weekOfYear, value: -ageWeeks, to: Date()) ?? Date(),
            birthWeight: Double(weightText).map { $0 * 1000 },
            feedingType: feedingType
        )
        
        feedStore.saveBabyProfile(profile)
        dismiss()
    }
}

// MARK: - Calm Background
struct CalmBackground: View {
    var body: some View {
        ZStack {
            // Warm gradient with depth
            LinearGradient(
                colors: [
                    Color(hex: "#FCFBF9"),
                    Color(hex: "#F5F4F1")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Soft radial glow behind logo
            RadialGradient(
                colors: [
                    Color.emeraldPrimary.opacity(0.08),
                    Color.clear
                ],
                center: .init(x: 0.5, y: 0.34),
                startRadius: 30,
                endRadius: 180
            )
            .ignoresSafeArea()
        }
    }
}

// MARK: - Screen 1: Welcome
struct WelcomeStep: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: UIScreen.main.bounds.height * 0.08)
            
            // Logo lockup: shapes + B-Fed as single unit
            LogoLockup()
                .padding(.bottom, 52)
            
            // Headline
            VStack(spacing: 2) {
                Text("Track feeds.")
                    .font(.system(size: 26, weight: .semibold, design: .default))
                    .foregroundStyle(Color.textPrimary)
                
                Text("Stay in flow.")
                    .font(.system(size: 26, weight: .semibold, design: .default))
                    .foregroundStyle(Color.textPrimary)
            }
            .multilineTextAlignment(.center)
            
            Text("Simple tracking, without the stress.")
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 14)
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Logo Lockup (Shapes + B-Fed as unified brand mark)
struct LogoLockup: View {
    @State private var phase: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 16) {
            // Stacked organic shapes
            ZStack(alignment: .bottom) {
                // Bottom layer - Emerald (strong anchor)
                FluidShape(
                    topCurve: 0.25,
                    bottomCurve: 0.55,
                    leftCurve: 0.15,
                    rightCurve: 0.35
                )
                .fill(Color.emeraldPrimary.opacity(0.45))
                .frame(width: 170, height: 68)
                .offset(x: -2, y: sin(phase) * 1.5 - 2)
                .scaleEffect(1.0 + sin(phase * 0.6) * 0.012)
                
                // Middle layer - Pink (medium)
                FluidShape(
                    topCurve: 0.40,
                    bottomCurve: 0.30,
                    leftCurve: 0.45,
                    rightCurve: 0.20
                )
                .fill(Color.pinkSoft.opacity(0.38))
                .frame(width: 130, height: 58)
                .offset(x: 8, y: -42 + sin(phase + 1.2) * 1.5)
                .scaleEffect(1.0 + sin(phase * 0.7 + 0.8) * 0.015)
                .rotationEffect(.degrees(-2.5))
                
                // Top layer - Yellow (lightest)
                FluidShape(
                    topCurve: 0.55,
                    bottomCurve: 0.25,
                    leftCurve: 0.30,
                    rightCurve: 0.40
                )
                .fill(Color.yellowSoft.opacity(0.50))
                .frame(width: 90, height: 48)
                .offset(x: -3, y: -88 + sin(phase + 2.4) * 1.2)
                .scaleEffect(1.0 + sin(phase * 0.8 + 1.5) * 0.018)
                .rotationEffect(.degrees(3))
            }
            .frame(width: 200, height: 160)
            
            // B-Fed text - tightly connected to shapes
            Text("B-Fed")
                .font(.system(size: 17, weight: .medium, design: .default))
                .foregroundStyle(Color.textMuted.opacity(0.95))
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3.8).repeatForever(autoreverses: true)) {
                phase = .pi * 2
            }
        }
    }
}

// MARK: - Fluid Shape (Asymmetric organic form)
struct FluidShape: Shape {
    let topCurve: CGFloat
    let bottomCurve: CGFloat
    let leftCurve: CGFloat
    let rightCurve: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let w = rect.width
        let h = rect.height
        
        // Start at top-left with asymmetry
        path.move(to: CGPoint(x: w * 0.08, y: h * 0.15))
        
        // Top edge - organic wave
        path.addCurve(
            to: CGPoint(x: w * 0.92, y: h * 0.12),
            control1: CGPoint(x: w * (0.25 + topCurve * 0.1), y: -h * 0.08),
            control2: CGPoint(x: w * (0.65 + topCurve * 0.15), y: h * 0.18)
        )
        
        // Right edge - soft irregular curve
        path.addCurve(
            to: CGPoint(x: w * 0.88, y: h * 0.88),
            control1: CGPoint(x: w * (1.02 + rightCurve * 0.05), y: h * 0.35),
            control2: CGPoint(x: w * (0.95 - rightCurve * 0.08), y: h * 0.72)
        )
        
        // Bottom edge - gentle accumulation
        path.addCurve(
            to: CGPoint(x: w * 0.12, y: h * 0.92),
            control1: CGPoint(x: w * (0.70 + bottomCurve * 0.12), y: h * 1.06),
            control2: CGPoint(x: w * (0.30 - bottomCurve * 0.08), y: h * 0.98)
        )
        
        // Left edge - return to start
        path.addCurve(
            to: CGPoint(x: w * 0.08, y: h * 0.15),
            control1: CGPoint(x: w * (-0.02 - leftCurve * 0.05), y: h * 0.68),
            control2: CGPoint(x: w * (0.08 + leftCurve * 0.10), y: h * 0.38)
        )
        
        path.closeSubpath()
        return path
    }
}

// MARK: - Screen 2: Baby Details
struct BabyDetailsStep: View {
    @Binding var ageWeeks: Int
    @Binding var weightText: String
    @Binding var feedingType: FeedingType
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 60)
            
            Text("Tell us about\nyour baby")
                .font(.system(size: 26, weight: .bold, design: .default))
                .foregroundStyle(Color.textPrimary)
                .multilineTextAlignment(.center)
            
            Spacer().frame(height: 44)
            
            VStack(spacing: 20) {
                // Age picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Age")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.textMuted)
                    
                    Picker("Age", selection: $ageWeeks) {
                        ForEach(0...52, id: \.self) { week in
                            Text(week == 0 ? "Newborn" : "\(week) week\(week == 1 ? "" : "s")")
                                .tag(week)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 90)
                    .background(Color.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                
                // Weight input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Weight (optional)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.textMuted)
                    
                    HStack {
                        TextField("Optional", text: $weightText)
                            .font(.body)
                            .keyboardType(.decimalPad)
                        
                        Text("kg")
                            .font(.body)
                            .foregroundStyle(Color.textMuted)
                    }
                    .padding()
                    .background(Color.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                
                // Feeding type
                VStack(alignment: .leading, spacing: 8) {
                    Text("Feeding type")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.textMuted)
                    
                    HStack(spacing: 12) {
                        ForEach([FeedingType.formula, .mixed], id: \.self) { type in
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    feedingType = type
                                }
                            } label: {
                                Text(type.displayName)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(feedingType == type ? .white : Color.textPrimary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(feedingType == type ? Color.emeraldSoft : Color.cardBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Screen 3: Ready
struct ReadyStep: View {
    let ageWeeks: Int
    let weightKg: Double?
    
    private var typicalRange: String {
        let daily: Int
        
        if let weight = weightKg {
            daily = Int(weight * 150)
        } else {
            switch ageWeeks {
            case 0...2: daily = 400
            case 3...4: daily = 550
            case 5...8: daily = 700
            case 9...16: daily = 800
            case 17...24: daily = 900
            default: daily = 750
            }
        }
        
        let minFeed = daily / 8
        let maxFeed = daily / 6
        
        return "\(minFeed)–\(maxFeed) ml"
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Smaller logo lockup
            LogoLockup()
                .frame(width: 160, height: 140)
            
            Text("You're all set")
                .font(.system(size: 26, weight: .bold, design: .default))
                .foregroundStyle(Color.textPrimary)
            
            // Range preview
            VStack(spacing: 12) {
                Text("Typical feeding range:")
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                
                Text(typicalRange)
                    .font(.system(size: 24, weight: .semibold, design: .default))
                    .foregroundStyle(Color.emeraldSoft)
                
                Text("You're right on track")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.emeraldSoft.opacity(0.8))
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(Color.emeraldSoft.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
}

// MARK: - Button Press Style
struct CalmPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Color Extensions
private extension Color {
    // Brand colors
    static var emeraldPrimary: Color { Color(hex: "#4A9B7A") }
    static var emeraldSoft: Color { Color(hex: "#7AB89A") }
    static var pinkSoft: Color { Color(hex: "#E8C4D0") }
    static var yellowSoft: Color { Color(hex: "#F0E0B8") }
    
    // Text colors
    static var textPrimary: Color { Color(hex: "#1A1A1A") }
    static var textSecondary: Color { Color(hex: "#6B6B6B") }
    static var textMuted: Color { Color(hex: "#6B6B6B") }  // Slightly darker for brand text
    
    // UI colors
    static var cardBackground: Color { Color(hex: "#F5F5F3") }
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    OnboardingView()
        .environment(FeedStore())
}
