import SwiftUI

struct BottlePrepGuideView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let steps: [PrepStep] = [
        PrepStep(
            number: 1,
            title: "Wash your hands",
            detail: "Clean hands keep everything safe. A quick 20-second wash with soap is all it takes.",
            icon: "hands.sparkles",
            tint: Color.almostAquaDark
        ),
        PrepStep(
            number: 2,
            title: "Boil fresh water",
            detail: "Bring water to a rolling boil and let it cool for about 30 minutes. It should feel warm, not hot — around 70°C if you want to be precise.",
            icon: "flame.fill",
            tint: Color.peachDustDark
        ),
        PrepStep(
            number: 3,
            title: "Pour into the bottle",
            detail: "Add the exact amount of water first. Check the level at eye level so you're spot on.",
            icon: "drop.fill",
            tint: Color.almostAquaDark
        ),
        PrepStep(
            number: 4,
            title: "Add the powder",
            detail: "Use the scoop that came with your formula. Level it off with a clean knife — don't pack it down. Follow the ratio on the tin exactly.",
            icon: "plus.circle.fill",
            tint: Color.orchidTintDark
        ),
        PrepStep(
            number: 5,
            title: "Mix well",
            detail: "Cap the bottle and swirl gently, or roll between your palms. Shakeing can trap air bubbles that upset tiny tummies.",
            icon: "arrow.2.circlepath",
            tint: Color.almostAquaDark
        ),
        PrepStep(
            number: 6,
            title: "Cool to body temperature",
            detail: "Test on the inside of your wrist — it should feel barely warm, not hot. If it's too warm, hold the bottle under cold running water.",
            icon: "thermometer",
            tint: Color.peachDustDark
        ),
        PrepStep(
            number: 7,
            title: "Feed right away",
            detail: "Use the bottle within 2 hours, or store it in the back of the fridge for up to 24 hours. Never reheat more than once.",
            icon: "checkmark.circle.fill",
            tint: Color.almostAquaDark
        )
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.xl) {
                    // Intro
                    VStack(spacing: AppSpacing.md) {
                        ZStack {
                            Circle()
                                .fill(Color.almostAquaDark.opacity(0.08))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "drop.fill")
                                .font(AppFont.sans(40, weight: .light))
                                .foregroundStyle(Color.almostAquaDark)
                        }
                        
                        Text("Bottle Prep Guide")
                            .font(AppFont.serif(28))
                            .foregroundStyle(Color.inkPrimary)
                        
                        Text("A calm, safe routine you can rely on")
                            .font(AppFont.bodyLarge)
                            .foregroundStyle(Color.inkSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, AppSpacing.xxl)
                    
                    // Steps
                    VStack(spacing: AppSpacing.lg) {
                        ForEach(steps) { step in
                            PrepStepCard(step: step)
                        }
                    }
                    
                    // Safety note
                    SafetyNoteCard()
                        .padding(.top, AppSpacing.md)
                    
                    Spacer(minLength: AppSpacing.xxl)
                }
                .padding(.horizontal, AppSpacing.lg)
            }
            .background(Color.backgroundBase)
            .navigationTitle("Preparation")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Prep Step
struct PrepStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let detail: String
    let icon: String
    let tint: Color
}

// MARK: - Prep Step Card
struct PrepStepCard: View {
    let step: PrepStep
    
    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            // Number + icon
            ZStack {
                Circle()
                    .fill(step.tint.opacity(0.12))
                    .frame(width: 44, height: 44)
                
                Text("\(step.number)")
                    .font(AppFont.sans(16, weight: .semibold))
                    .foregroundStyle(step.tint)
            }
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(step.title)
                    .font(AppFont.sans(15, weight: .semibold))
                    .foregroundStyle(Color.inkPrimary)
                
                Text(step.detail)
                    .font(AppFont.body)
                    .foregroundStyle(Color.inkSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)
            }
            
            Spacer()
        }
        .padding(AppSpacing.md)
        .background(Color.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .stroke(Color.black.opacity(AppMetrics.borderOpacity), lineWidth: AppMetrics.borderWidth)
        )
    }
}

// MARK: - Safety Note Card
struct SafetyNoteCard: View {
    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            Image(systemName: "shield.fill")
                .font(AppFont.sans(14, weight: .medium))
                .foregroundStyle(Color.peachDustDark)
                .frame(width: 32, height: 32)
                .background(Color.peachDustDark.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Safety reminder")
                    .font(AppFont.sans(13, weight: .semibold))
                    .foregroundStyle(Color.inkPrimary)
                
                Text("Never microwave a bottle — hot spots can burn. And if you're ever unsure, start fresh. You've got this.")
                    .font(AppFont.caption)
                    .foregroundStyle(Color.inkSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(AppSpacing.md)
        .background(Color.peachDustLight.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
    }
}

#Preview {
    BottlePrepGuideView()
}
