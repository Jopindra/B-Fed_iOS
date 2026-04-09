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
            
            // Vessel logo with liquid layers
            VesselLogo()
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

// MARK: - Vessel Logo (Soft bottle with liquid layers)
struct VesselLogo: View {
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                // Soft vessel outline (implied bottle)
                SoftVesselOutline()
                    .stroke(Color.vesselOutline.opacity(0.22), lineWidth: 1.5)
                    .frame(width: 100, height: 150)
                
                // Liquid layers inside vessel
                VStack(spacing: -6) {
                    // Top - Yellow (airy, clear)
                    LiquidPool(
                        width: 72,
                        height: 38,
                        color: Color.yellowSoft.opacity(0.72),
                        breathing: (intensity: 0.008, vertical: 1, delay: 0)
                    )
                    
                    // Middle - Pink (warm, flowing)
                    LiquidPool(
                        width: 82,
                        height: 42,
                        color: Color.pinkSoft.opacity(0.48),
                        breathing: (intensity: 0.010, vertical: 1.5, delay: 1.2)
                    )
                    
                    // Base - Emerald (rich, defined)
                    LiquidPool(
                        width: 90,
                        height: 46,
                        color: Color.emeraldPrimary.opacity(0.52),
                        breathing: (intensity: 0.012, vertical: 2, delay: 2.4)
                    )
                }
                .padding(.top, 28)
            }
            .frame(width: 100, height: 150)
            
            // B-Fed label
            Text("B-Fed")
                .font(.system(size: 15, weight: .medium, design: .default))
                .foregroundStyle(Color.textMuted.opacity(0.82))
        }
    }
}

// MARK: - Soft Vessel Outline (Gentle bottle shape)
struct SoftVesselOutline: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let w = rect.width
        let h = rect.height
        
        // Soft bottle proportions
        let neckWidth = w * 0.45
        let bodyWidth = w * 0.88
        let neckHeight = h * 0.28
        let shoulderY = h * 0.32
        let bottomCurve = h * 0.92
        
        // Start at top center of neck
        path.move(to: CGPoint(x: w * 0.5, y: h * 0.06))
        
        // Top of neck (soft curve)
        path.addCurve(
            to: CGPoint(x: (w + neckWidth) / 2, y: h * 0.10),
            control1: CGPoint(x: w * 0.5 + neckWidth * 0.15, y: h * 0.06),
            control2: CGPoint(x: (w + neckWidth) / 2, y: h * 0.08)
        )
        
        // Right neck down
        path.addLine(to: CGPoint(x: (w + neckWidth) / 2, y: neckHeight))
        
        // Right shoulder (gentle curve out)
        path.addCurve(
            to: CGPoint(x: (w + bodyWidth) / 2, y: shoulderY),
            control1: CGPoint(x: (w + neckWidth) / 2 + 4, y: neckHeight + 8),
            control2: CGPoint(x: (w + bodyWidth) / 2 - 2, y: shoulderY - 6)
        )
        
        // Right body down
        path.addCurve(
            to: CGPoint(x: (w + bodyWidth) / 2, y: bottomCurve),
            control1: CGPoint(x: (w + bodyWidth) / 2 + 3, y: h * 0.55),
            control2: CGPoint(x: (w + bodyWidth) / 2 + 2, y: h * 0.75)
        )
        
        // Bottom (soft rounded base)
        path.addCurve(
            to: CGPoint(x: (w - bodyWidth) / 2, y: bottomCurve),
            control1: CGPoint(x: w * 0.75, y: h + 2),
            control2: CGPoint(x: w * 0.25, y: h + 2)
        )
        
        // Left body up
        path.addCurve(
            to: CGPoint(x: (w - bodyWidth) / 2, y: shoulderY),
            control1: CGPoint(x: (w - bodyWidth) / 2 - 2, y: h * 0.75),
            control2: CGPoint(x: (w - bodyWidth) / 2 - 3, y: h * 0.55)
        )
        
        // Left shoulder (gentle curve in)
        path.addCurve(
            to: CGPoint(x: (w - neckWidth) / 2, y: neckHeight),
            control1: CGPoint(x: (w - bodyWidth) / 2 + 2, y: shoulderY - 6),
            control2: CGPoint(x: (w - neckWidth) / 2 - 4, y: neckHeight + 8)
        )
        
        // Left neck up
        path.addLine(to: CGPoint(x: (w - neckWidth) / 2, y: h * 0.10))
        
        // Top left curve
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: h * 0.06),
            control1: CGPoint(x: (w - neckWidth) / 2, y: h * 0.08),
            control2: CGPoint(x: w * 0.5 - neckWidth * 0.15, y: h * 0.06)
        )
        
        path.closeSubpath()
        return path
    }
}

// MARK: - Liquid Pool (Fluid organic shape)
struct LiquidPool: View {
    let width: CGFloat
    let height: CGFloat
    let color: Color
    let breathing: (intensity: Double, vertical: Double, delay: Double)
    
    @State private var phase: CGFloat = 0
    
    var body: some View {
        LiquidPoolShape()
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

// MARK: - Liquid Pool Shape (Organic fluid form)
struct LiquidPoolShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let w = rect.width
        let h = rect.height
        
        // Organic liquid pool with soft curves
        path.move(to: CGPoint(x: w * 0.5, y: 0))
        
        // Top right
        path.addCurve(
            to: CGPoint(x: w * 0.92, y: h * 0.35),
            control1: CGPoint(x: w * 0.78, y: h * 0.02),
            control2: CGPoint(x: w * 0.95, y: h * 0.20)
        )
        
        // Right side down
        path.addCurve(
            to: CGPoint(x: w * 0.75, y: h * 0.88),
            control1: CGPoint(x: w * 0.98, y: h * 0.55),
            control2: CGPoint(x: w * 0.88, y: h * 0.78)
        )
        
        // Bottom curve
        path.addCurve(
            to: CGPoint(x: w * 0.25, y: h * 0.88),
            control1: CGPoint(x: w * 0.58, y: h * 1.05),
            control2: CGPoint(x: w * 0.42, y: h * 1.05)
        )
        
        // Left side up
        path.addCurve(
            to: CGPoint(x: w * 0.08, y: h * 0.35),
            control1: CGPoint(x: w * 0.12, y: h * 0.78),
            control2: CGPoint(x: w * 0.02, y: h * 0.55)
        )
        
        // Top left
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: 0),
            control1: CGPoint(x: w * 0.22, y: h * 0.20),
            control2: CGPoint(x: w * 0.35, y: h * 0.02)
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
            
            VesselLogo()
                .frame(width: 100, height: 170)
            
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
    static var emeraldPrimary: Color { Color(hex: "#3A7A5E") }     // Richer green
    static var emeraldSoft: Color { Color(hex: "#6BA892") }
    static var pinkSoft: Color { Color(hex: "#E8B0C0") }           // Warmer pink
    static var yellowSoft: Color { Color(hex: "#ECD69A") }          // Clearer yellow
    static var vesselOutline: Color { Color(hex: "#A8B4AC") }       // Soft vessel outline
    
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
