import SwiftUI

// MARK: - Onboarding View
struct OnboardingView: View {
    @Environment(FeedStore.self) private var feedStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentStep = 0
    @State private var ageWeeks = 0
    @State private var weightText = ""
    @State private var feedingType: FeedingType = .formula
    @State private var skipButtonOpacity: Double = 0
    
    var body: some View {
        ZStack {
            CalmBackground()
            
            VStack(spacing: 0) {
                // Skip button - refined with gentle fade
                HStack {
                    Spacer()
                    if currentStep < 2 {
                        Button("Skip") {
                            completeOnboarding()
                        }
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Color.textMuted.opacity(0.55))
                        .padding(.top, 12)
                        .padding(.trailing, 24)
                        .opacity(skipButtonOpacity)
                        .onAppear {
                            withAnimation(MotionCurve.standard.delay(0.5)) {
                                skipButtonOpacity = 1
                            }
                        }
                    }
                }
                
                // Content with screen transitions
                TabView(selection: $currentStep) {
                    WelcomeStep()
                        .tag(0)
                        .screenTransition(isActive: currentStep == 0, offset: 12)
                    
                    BabyDetailsStep(
                        ageWeeks: $ageWeeks,
                        weightText: $weightText,
                        feedingType: $feedingType
                    )
                    .tag(1)
                    .screenTransition(isActive: currentStep == 1, offset: 12)
                    
                    ReadyStep(
                        ageWeeks: ageWeeks,
                        weightKg: Double(weightText)
                    )
                    .tag(2)
                    .screenTransition(isActive: currentStep == 2, offset: 12)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(MotionCurve.standard, value: currentStep)
                
                // Bottom button with gentle press
                VStack(spacing: 0) {
                    Button(action: handlePrimaryAction) {
                        Text(buttonText)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                LinearGradient(
                                    colors: [Color.emeraldSoft, Color.emeraldSoft.opacity(0.95)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .clipShape(Capsule())
                            .shadow(color: Color.emeraldSoft.opacity(0.20), radius: 8, x: 0, y: 3)
                    }
                    .buttonStyle(GentlePressEffect())
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
            withAnimation(MotionCurve.standard) {
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
            // Warm gradient
            LinearGradient(
                colors: [
                    Color(hex: "#FCFBF9"),
                    Color(hex: "#F5F4F1")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Enhanced radial glow
            RadialGradient(
                colors: [
                    Color.emeraldPrimary.opacity(0.14),
                    Color.clear
                ],
                center: .init(x: 0.5, y: 0.34),
                startRadius: 50,
                endRadius: 220
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
            
            // Breathing logo with asymmetric design
            AsymmetricLogoLockup()
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

// MARK: - Asymmetric Logo Lockup with Breathing Motion
struct AsymmetricLogoLockup: View {
    var body: some View {
        VStack(spacing: 6) {
            // Stacked organic shapes with breathing animation
            ZStack(alignment: .bottom) {
                // Bottom layer - Emerald (breathing with offset)
                FluidShape(
                    topCurve: 0.28,
                    bottomCurve: 0.58,
                    leftCurve: 0.18,
                    rightCurve: 0.38
                )
                .fill(Color.emeraldPrimary.opacity(0.50))
                .frame(width: 185, height: 72)
                .offset(x: 8)
                .breathing(intensity: 0.015, verticalOffset: 2, delay: 0)
                
                // Middle layer - Pink (centered, delayed breathing)
                FluidShape(
                    topCurve: 0.42,
                    bottomCurve: 0.32,
                    leftCurve: 0.47,
                    rightCurve: 0.22
                )
                .fill(Color.pinkSoft.opacity(0.36))
                .frame(width: 135, height: 60)
                .offset(y: -38)
                .breathing(intensity: 0.018, verticalOffset: 1.5, delay: 1.2)
                
                // Top layer - Yellow (shifted left, lighter breathing)
                FluidShape(
                    topCurve: 0.58,
                    bottomCurve: 0.28,
                    leftCurve: 0.32,
                    rightCurve: 0.42
                )
                .fill(Color.yellowSoft.opacity(0.58))
                .frame(width: 95, height: 50)
                .offset(x: -6, y: -78)
                .breathing(intensity: 0.012, verticalOffset: 1, delay: 2.4)
            }
            .frame(width: 210, height: 155)
            .rotationEffect(.degrees(1.5))
            
            // B-Fed label
            Text("B-Fed")
                .font(.system(size: 15, weight: .medium, design: .default))
                .foregroundStyle(Color.textMuted.opacity(0.80))
        }
    }
}

// MARK: - Fluid Shape
struct FluidShape: Shape {
    let topCurve: CGFloat
    let bottomCurve: CGFloat
    let leftCurve: CGFloat
    let rightCurve: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let w = rect.width
        let h = rect.height
        
        path.move(to: CGPoint(x: w * 0.08, y: h * 0.15))
        
        path.addCurve(
            to: CGPoint(x: w * 0.92, y: h * 0.12),
            control1: CGPoint(x: w * (0.25 + topCurve * 0.1), y: -h * 0.08),
            control2: CGPoint(x: w * (0.65 + topCurve * 0.15), y: h * 0.18)
        )
        
        path.addCurve(
            to: CGPoint(x: w * 0.88, y: h * 0.88),
            control1: CGPoint(x: w * (1.02 + rightCurve * 0.05), y: h * 0.35),
            control2: CGPoint(x: w * (0.95 - rightCurve * 0.08), y: h * 0.72)
        )
        
        path.addCurve(
            to: CGPoint(x: w * 0.12, y: h * 0.92),
            control1: CGPoint(x: w * (0.70 + bottomCurve * 0.12), y: h * 1.06),
            control2: CGPoint(x: w * (0.30 - bottomCurve * 0.08), y: h * 0.98)
        )
        
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
                // Age picker with staggered appearance
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
                .staggered(index: 0, baseDelay: 0.1)
                
                // Weight input with staggered appearance
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
                .staggered(index: 1, baseDelay: 0.1)
                
                // Feeding type with staggered appearance
                VStack(alignment: .leading, spacing: 8) {
                    Text("Feeding type")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.textMuted)
                    
                    HStack(spacing: 12) {
                        ForEach([FeedingType.formula, .mixed], id: \.self) { type in
                            Button {
                                withAnimation(MotionCurve.interaction) {
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
                .staggered(index: 2, baseDelay: 0.1)
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
            
            AsymmetricLogoLockup()
                .frame(width: 170, height: 130)
            
            Text("You're all set")
                .font(.system(size: 26, weight: .bold, design: .default))
                .foregroundStyle(Color.textPrimary)
            
            // Range preview with staggered appearance
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
            .staggered(index: 0, baseDelay: 0.2)
            
            Spacer()
        }
    }
}

// MARK: - Color Extensions
private extension Color {
    static var emeraldPrimary: Color { Color(hex: "#2D7A5E") }
    static var emeraldSoft: Color { Color(hex: "#5BA88A") }
    static var pinkSoft: Color { Color(hex: "#E6C0CC") }
    static var yellowSoft: Color { Color(hex: "#ECD8A8") }
    
    static var textPrimary: Color { Color(hex: "#1A1A1A") }
    static var textSecondary: Color { Color(hex: "#5A5A5A") }
    static var textMuted: Color { Color(hex: "#7A7A7A") }
    
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
