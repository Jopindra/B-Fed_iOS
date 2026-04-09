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
                    Color.emeraldPrimary.opacity(0.08),
                    Color.clear
                ],
                center: .init(x: 0.5, y: 0.34),
                startRadius: 40,
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
            
            // Abstract flowing logo
            FlowingLogo()
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

// MARK: - Flowing Logo (Abstract, organic layers)
struct FlowingLogo: View {
    var body: some View {
        VStack(spacing: 8) {
            // Three organic flowing shapes
            ZStack(alignment: .bottom) {
                // Base layer - Rich emerald (flowing foundation)
                FlowingShape(
                    width: 155,
                    height: 62,
                    color: Color.emeraldPrimary.opacity(0.50),
                    curveIntensity: 0.4,
                    breathing: (intensity: 0.012, vertical: 2, delay: 0)
                )
                .offset(x: 0, y: 0)
                
                // Middle layer - Warm pink (softly overlapping)
                FlowingShape(
                    width: 125,
                    height: 56,
                    color: Color.pinkSoft.opacity(0.45),
                    curveIntensity: 0.5,
                    breathing: (intensity: 0.015, vertical: 1.5, delay: 1.2)
                )
                .offset(x: 0, y: -32)
                
                // Top layer - Clear yellow (airy, visible)
                FlowingShape(
                    width: 95,
                    height: 48,
                    color: Color.yellowSoft.opacity(0.68),
                    curveIntensity: 0.6,
                    breathing: (intensity: 0.010, vertical: 1, delay: 2.4)
                )
                .offset(x: 0, y: -62)
            }
            .frame(width: 155, height: 130)
            
            // B-Fed label
            Text("B-Fed")
                .font(.system(size: 15, weight: .medium, design: .default))
                .foregroundStyle(Color.textMuted.opacity(0.82))
        }
    }
}

// MARK: - Flowing Shape (Organic, abstract form)
struct FlowingShape: View {
    let width: CGFloat
    let height: CGFloat
    let color: Color
    let curveIntensity: CGFloat
    let breathing: (intensity: Double, vertical: Double, delay: Double)
    
    @State private var phase: CGFloat = 0
    
    var body: some View {
        OrganicFormShape(curveIntensity: curveIntensity)
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

// MARK: - Organic Form Shape (Abstract, flowing edges)
struct OrganicFormShape: Shape {
    let curveIntensity: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let w = rect.width
        let h = rect.height
        let ci = curveIntensity
        
        // Start at left with organic curve
        path.move(to: CGPoint(x: w * 0.12, y: h * 0.35))
        
        // Top edge - flowing wave with irregularity
        path.addCurve(
            to: CGPoint(x: w * 0.88, y: h * 0.28),
            control1: CGPoint(x: w * (0.30 + ci * 0.25), y: -h * 0.15),
            control2: CGPoint(x: w * (0.70 - ci * 0.15), y: h * 0.22)
        )
        
        // Right edge - soft flowing descent
        path.addCurve(
            to: CGPoint(x: w * 0.82, y: h * 0.75),
            control1: CGPoint(x: w * (1.04 + ci * 0.08), y: h * 0.45),
            control2: CGPoint(x: w * (0.90 - ci * 0.10), y: h * 0.65)
        )
        
        // Bottom edge - gentle organic curve
        path.addCurve(
            to: CGPoint(x: w * 0.18, y: h * 0.82),
            control1: CGPoint(x: w * (0.65 - ci * 0.12), y: h * 1.08),
            control2: CGPoint(x: w * (0.35 + ci * 0.20), y: h * 0.95)
        )
        
        // Left edge - flowing return
        path.addCurve(
            to: CGPoint(x: w * 0.12, y: h * 0.35),
            control1: CGPoint(x: w * (-0.04 - ci * 0.10), y: h * 0.70),
            control2: CGPoint(x: w * (0.08 + ci * 0.15), y: h * 0.48)
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
            
            FlowingLogo()
                .frame(width: 140, height: 150)
            
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
    static var yellowSoft: Color { Color(hex: "#EDD8A0") }          // Clearer yellow
    
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
