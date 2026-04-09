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
                // Skip button
                HStack {
                    Spacer()
                    if currentStep < 2 {
                        Button("Skip") {
                            completeOnboarding()
                        }
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Color.textMuted.opacity(0.55))
                        .padding(.top, 14)
                        .padding(.trailing, 24)
                        .opacity(skipButtonOpacity)
                        .onAppear {
                            withAnimation(MotionCurve.standard.delay(0.5)) {
                                skipButtonOpacity = 1
                            }
                        }
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
                .animation(MotionCurve.standard, value: currentStep)
                
                // Bottom button
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
            // Warm cream gradient
            LinearGradient(
                colors: [
                    Color(hex: "#FDFCFA"),
                    Color(hex: "#F8F6F3")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Soft radial glow
            RadialGradient(
                colors: [
                    Color.emeraldPrimary.opacity(0.10),
                    Color.clear
                ],
                center: .init(x: 0.5, y: 0.34),
                startRadius: 50,
                endRadius: 200
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
            
            // Logo with subtle container concept
            ContainedLogoLockup()
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

// MARK: - Contained Logo Lockup (Liquid in vessel concept)
struct ContainedLogoLockup: View {
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                // Subtle container outline (implied vessel)
                SoftContainerShape()
                    .stroke(Color.containerOutline.opacity(0.25), lineWidth: 1.5)
                    .frame(width: 140, height: 160)
                
                // Liquid layers inside container
                VStack(spacing: -8) {
                    // Top layer - Yellow (airy, visible)
                    LiquidDroplet(
                        width: 85,
                        height: 42,
                        color: Color.yellowSoft.opacity(0.70),
                        curveIntensity: 0.4,
                        breathing: (intensity: 0.008, vertical: 1, delay: 0)
                    )
                    
                    // Middle layer - Pink (warm, flowing)
                    LiquidDroplet(
                        width: 105,
                        height: 48,
                        color: Color.pinkSoft.opacity(0.45),
                        curveIntensity: 0.35,
                        breathing: (intensity: 0.012, vertical: 1.5, delay: 1.2)
                    )
                    
                    // Base layer - Emerald (rich anchor)
                    LiquidDroplet(
                        width: 120,
                        height: 52,
                        color: Color.emeraldPrimary.opacity(0.50),
                        curveIntensity: 0.3,
                        breathing: (intensity: 0.010, vertical: 2, delay: 2.4)
                    )
                }
                .padding(.top, 20)
            }
            .frame(width: 140, height: 160)
            
            // B-Fed label
            Text("B-Fed")
                .font(.system(size: 15, weight: .medium, design: .default))
                .foregroundStyle(Color.textMuted.opacity(0.82))
        }
    }
}

// MARK: - Soft Container Shape (Implied vessel)
struct SoftContainerShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let w = rect.width
        let h = rect.height
        let cornerRadius: CGFloat = 28
        
        // Soft rounded rectangle with gentle curves
        path.move(to: CGPoint(x: w * 0.5, y: 0))
        
        // Top edge
        path.addCurve(
            to: CGPoint(x: w, y: cornerRadius),
            control1: CGPoint(x: w - cornerRadius * 0.3, y: 0),
            control2: CGPoint(x: w, y: cornerRadius * 0.3)
        )
        
        // Right edge
        path.addCurve(
            to: CGPoint(x: w, y: h - cornerRadius),
            control1: CGPoint(x: w + 2, y: h * 0.3),
            control2: CGPoint(x: w + 2, y: h * 0.7)
        )
        
        // Bottom curve (slightly wider for stability)
        path.addCurve(
            to: CGPoint(x: 0, y: h - cornerRadius),
            control1: CGPoint(x: w * 0.75, y: h + 4),
            control2: CGPoint(x: w * 0.25, y: h + 4)
        )
        
        // Left edge
        path.addCurve(
            to: CGPoint(x: 0, y: cornerRadius),
            control1: CGPoint(x: -2, y: h * 0.7),
            control2: CGPoint(x: -2, y: h * 0.3)
        )
        
        // Top left curve
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: 0),
            control1: CGPoint(x: 0, y: cornerRadius * 0.3),
            control2: CGPoint(x: cornerRadius * 0.3, y: 0)
        )
        
        path.closeSubpath()
        return path
    }
}

// MARK: - Liquid Droplet (Organic flowing shape)
struct LiquidDroplet: View {
    let width: CGFloat
    let height: CGFloat
    let color: Color
    let curveIntensity: CGFloat
    let breathing: (intensity: Double, vertical: Double, delay: Double)
    
    @State private var phase: CGFloat = 0
    
    var body: some View {
        LiquidDropletShape(curveIntensity: curveIntensity)
            .fill(color)
            .frame(width: width, height: height)
            .offset(y: sin(phase + breathing.delay) * breathing.vertical)
            .scaleEffect(1.0 + sin(phase + breathing.delay) * breathing.intensity)
            .onAppear {
                withAnimation(MotionCurve.breathing.repeatForever(autoreverses: true)) {
                    phase = .pi * 2
                }
            }
    }
}

// MARK: - Liquid Droplet Shape
struct LiquidDropletShape: Shape {
    let curveIntensity: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let w = rect.width
        let h = rect.height
        let ci = curveIntensity
        
        // Start at top center
        path.move(to: CGPoint(x: w * 0.5, y: 0))
        
        // Top right curve (soft)
        path.addCurve(
            to: CGPoint(x: w, y: h * 0.4),
            control1: CGPoint(x: w * (0.75 + ci * 0.2), y: 0),
            control2: CGPoint(x: w, y: h * 0.2)
        )
        
        // Right side down
        path.addCurve(
            to: CGPoint(x: w * 0.85, y: h * 0.85),
            control1: CGPoint(x: w + ci * 4, y: h * 0.6),
            control2: CGPoint(x: w * 0.9, y: h * 0.75)
        )
        
        // Bottom curve (gentle arc)
        path.addCurve(
            to: CGPoint(x: w * 0.15, y: h * 0.85),
            control1: CGPoint(x: w * 0.65, y: h + ci * 6),
            control2: CGPoint(x: w * 0.35, y: h + ci * 6)
        )
        
        // Left side up
        path.addCurve(
            to: CGPoint(x: 0, y: h * 0.4),
            control1: CGPoint(x: w * 0.1, y: h * 0.75),
            control2: CGPoint(x: -ci * 4, y: h * 0.6)
        )
        
        // Top left curve (soft)
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: 0),
            control1: CGPoint(x: 0, y: h * 0.2),
            control2: CGPoint(x: w * (0.25 - ci * 0.2), y: 0)
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
            
            ContainedLogoLockup()
                .frame(width: 140, height: 180)
            
            Text("You're all set")
                .font(.system(size: 26, weight: .bold, design: .default))
                .foregroundStyle(Color.textPrimary)
            
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
    // Refined brand colors
    static var emeraldPrimary: Color { Color(hex: "#3A7A5E") }    // Richer green anchor
    static var emeraldSoft: Color { Color(hex: "#6BA892") }
    static var pinkSoft: Color { Color(hex: "#E8B0C0") }          // Warmer pink, less grey
    static var yellowSoft: Color { Color(hex: "#ECD298") }         // Clearer yellow
    static var containerOutline: Color { Color(hex: "#9AA89E") }   // Subtle container outline
    
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
