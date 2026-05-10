import SwiftUI

// MARK: - Gentle Guide Screen
/// Onboarding completion screen — calm, informative, no celebration effects.
struct GentleGuideScreen: View {
    let babyProfile: BabyProfile
    let viewModel: FormulaSetupViewModel
    let onContinue: () -> Void

    // MARK: - Animation states
    @State private var drawCircle = false
    @State private var showCheckmark = false
    @State private var showHeadline = false
    @State private var showCard = false
    @State private var showReassurance = false
    @State private var showButton = false

    // MARK: - Age & guidance
    private var ageInMonths: Int {
        FormulaStageService.ageInMonths(from: babyProfile.dateOfBirth)
    }

    private var guidance: AgeGuidance {
        // Weight-based for first 6 months
        if let weightKg = babyProfile.weightInKg, weightKg > 0, ageInMonths < 6 {
            let daily = Int(weightKg * 150)
            let perFeed = daily / 6
            return AgeGuidance(
                dailyMin: max(300, daily - 50),
                dailyMax: daily + 50,
                feedMin: max(60, perFeed - 30),
                feedMax: perFeed + 30,
                feedsPerDayMin: 4,
                feedsPerDayMax: 8
            )
        }
        // Age-based fallback
        switch ageInMonths {
        case 0..<1:
            return AgeGuidance(dailyMin: 450, dailyMax: 600, feedMin: 60, feedMax: 90, feedsPerDayMin: 8, feedsPerDayMax: 12)
        case 1..<2:
            return AgeGuidance(dailyMin: 500, dailyMax: 700, feedMin: 90, feedMax: 120, feedsPerDayMin: 6, feedsPerDayMax: 8)
        case 2..<4:
            return AgeGuidance(dailyMin: 700, dailyMax: 900, feedMin: 120, feedMax: 180, feedsPerDayMin: 5, feedsPerDayMax: 6)
        case 4..<6:
            return AgeGuidance(dailyMin: 800, dailyMax: 1000, feedMin: 150, feedMax: 210, feedsPerDayMin: 4, feedsPerDayMax: 6)
        case 6..<9:
            return AgeGuidance(dailyMin: 600, dailyMax: 900, feedMin: 180, feedMax: 240, feedsPerDayMin: 3, feedsPerDayMax: 5)
        case 9..<12:
            return AgeGuidance(dailyMin: 500, dailyMax: 800, feedMin: 180, feedMax: 240, feedsPerDayMin: 3, feedsPerDayMax: 4)
        case 12..<24:
            return AgeGuidance(dailyMin: 350, dailyMax: 500, feedMin: 150, feedMax: 200, feedsPerDayMin: 2, feedsPerDayMax: 3)
        default:
            return AgeGuidance(dailyMin: 300, dailyMax: 400, feedMin: 120, feedMax: 180, feedsPerDayMin: 2, feedsPerDayMax: 3)
        }
    }

    private var babyName: String {
        babyProfile.babyName
    }

    private var hasFormulaInfo: Bool {
        !viewModel.displayBrandName.isEmpty
    }

    private var stageShortName: String {
        switch viewModel.selectedStage {
        case .newborn: return "Newborn"
        case .stage1: return "Stage 1"
        case .stage2: return "Stage 2"
        case .stage3: return "Stage 3"
        case .toddler: return "Toddler"
        case .none: return ""
        }
    }

    private var stageAgeRange: String {
        switch viewModel.selectedStage {
        case .newborn: return "0–1 month"
        case .stage1: return "0–6 months"
        case .stage2: return "6–12 months"
        case .stage3: return "1–2 years"
        case .toddler: return "2+ years"
        case .none: return ""
        }
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            Color(hex: "F7F9F7").ignoresSafeArea()

            blobs

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                animatedIcon
                    .padding(.bottom, 20)

                headline
                    .padding(.bottom, 28)

                if hasFormulaInfo {
                    formulaPill
                        .offset(y: showCard ? 0 : 16)
                        .opacity(showCard ? 1 : 0)
                        .padding(.bottom, 24)
                }

                cardSection

                Spacer(minLength: 0)

                button
                    .offset(y: showButton ? 0 : 16)
                    .opacity(showButton ? 1 : 0)
                    .padding(.bottom, 16)
            }
            .padding(.horizontal, 24)
        }
        .onAppear(perform: startAnimations)
    }

    // MARK: - Blobs
    private var blobs: some View {
        ZStack {
            // Blob 1 — Lavender, top right
            Circle()
                .fill(Color(hex: "C8C0D4").opacity(0.45))
                .frame(width: 180, height: 180)
                .position(x: UIScreen.main.bounds.width + 30, y: 30)

            // Blob 2 — Cream, top left
            Circle()
                .fill(Color(hex: "DDD8C0").opacity(0.35))
                .frame(width: 150, height: 150)
                .position(x: -25, y: 25)

            // Blob 3 — Terracotta, mid left
            Circle()
                .fill(Color(hex: "D4A898").opacity(0.32))
                .frame(width: 140, height: 140)
                .position(x: -10, y: 350)

            // Blob 4 — Sage, mid right
            Circle()
                .fill(Color(hex: "B0C4B0").opacity(0.32))
                .frame(width: 120, height: 120)
                .position(x: UIScreen.main.bounds.width + 10, y: 400)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    // MARK: - Animated Icon
    private var animatedIcon: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "DCE9DC"))
                .frame(width: 80, height: 80)

            Circle()
                .trim(from: 0, to: drawCircle ? 1 : 0)
                .stroke(Color(hex: "5A8A5A"), lineWidth: 1.5)
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(-90))

            Text("✓")
                .font(AppFont.sans(22, weight: .medium))
                .foregroundColor(Color(hex: "5A8A5A"))
                .opacity(showCheckmark ? 1 : 0)
        }
    }

    // MARK: - Headline
    private var headline: some View {
        VStack(spacing: 6) {
            Text("\(babyName) is in good hands.")
                .font(AppFont.sans(28, weight: .semibold))
                .foregroundColor(Color(hex: "1C2421"))
                .multilineTextAlignment(.center)

            Text("Here's a gentle guide to get started")
                .font(AppFont.sans(14, weight: .regular))
                .foregroundColor(Color(hex: "888780"))
                .multilineTextAlignment(.center)
        }
        .offset(y: showHeadline ? 0 : 16)
        .opacity(showHeadline ? 1 : 0)
    }

    // MARK: - Formula Pill
    private var formulaPill: some View {
        VStack(spacing: 8) {
            Text("\(viewModel.displayBrandName) · \(stageShortName)")
                .font(AppFont.sans(13, weight: .medium))
                .foregroundColor(Color(hex: "3D6B3D"))
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(Color(hex: "EEF4EE"))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color(hex: "5A8A5A").opacity(0.2), lineWidth: 0.5)
                )
            
            Text("You can change this in Settings")
                .font(AppFont.sans(12, weight: .regular))
                .foregroundColor(Color(hex: "888780"))
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: - Card Section (warm container + card + reassurance)
    private var cardSection: some View {
        VStack(spacing: 14) {
            summaryCard
                .offset(y: showCard ? 0 : 16)
                .opacity(showCard ? 1 : 0)

            reassuranceLine
                .offset(y: showReassurance ? 0 : 16)
                .opacity(showReassurance ? 1 : 0)
        }
        .padding(16)
        .background(Color(hex: "F5F0EA"))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    // MARK: - Summary Card
    private var summaryCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                // Daily guide
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily guide")
                        .font(AppFont.sans(11, weight: .medium))
                        .foregroundColor(Color(hex: "5A8A5A"))
                        .tracking(0.05 * 11)
                        .textCase(.uppercase)

                    Text("\(guidance.dailyMin)–\(guidance.dailyMax) ml")
                        .font(AppFont.sans(18, weight: .semibold))
                        .foregroundColor(Color(hex: "1C2421"))

                    Text("\(guidance.feedsPerDayMin)–\(guidance.feedsPerDayMax) feeds")
                        .font(AppFont.sans(12))
                        .foregroundColor(Color(hex: "888780"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Per feed
                VStack(alignment: .leading, spacing: 4) {
                    Text("Per feed")
                        .font(AppFont.sans(11, weight: .medium))
                        .foregroundColor(Color(hex: "5A8A5A"))
                        .tracking(0.05 * 11)
                        .textCase(.uppercase)

                    Text("\(guidance.feedMin)–\(guidance.feedMax) ml")
                        .font(AppFont.sans(18, weight: .semibold))
                        .foregroundColor(Color(hex: "1C2421"))

                    Text("typical")
                        .font(AppFont.sans(12))
                        .foregroundColor(Color(hex: "888780"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(20)
        .background(Color(hex: "FDFAF7"))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(hex: "5A8A5A").opacity(0.15), lineWidth: 0.5)
        )
    }

    // MARK: - Reassurance Line
    private var reassuranceLine: some View {
        Text("These are starting points — every baby is different")
            .font(AppFont.sans(12).italic())
            .foregroundColor(Color(hex: "B4B2A9"))
            .multilineTextAlignment(.center)
            .lineSpacing(1.6 * 12 - 12)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: - Button
    private var button: some View {
        Button(action: onContinue) {
            Text("Begin")
                .font(AppFont.sans(16, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(hex: "1C2421"))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Animation Sequence
    private func startAnimations() {
        if UIAccessibility.isReduceMotionEnabled {
            drawCircle = true
            showCheckmark = true
            showHeadline = true
            showCard = true
            showReassurance = true
            showButton = true
            return
        }
        withAnimation(.easeOut(duration: 1.0).delay(0.1)) {
            drawCircle = true
        }
        withAnimation(.easeOut(duration: 0.3).delay(0.9)) {
            showCheckmark = true
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.6)) {
            showHeadline = true
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.9)) {
            showCard = true
        }
        withAnimation(.easeOut(duration: 0.5).delay(1.2)) {
            showReassurance = true
        }
        withAnimation(.easeOut(duration: 0.5).delay(1.5)) {
            showButton = true
        }
    }
}

// MARK: - Age Guidance
private struct AgeGuidance {
    let dailyMin: Int
    let dailyMax: Int
    let feedMin: Int
    let feedMax: Int
    let feedsPerDayMin: Int
    let feedsPerDayMax: Int
}
