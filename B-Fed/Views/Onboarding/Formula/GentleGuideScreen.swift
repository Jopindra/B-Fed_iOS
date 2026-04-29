import SwiftUI

// MARK: - Gentle Guide Screen
/// Warm welcome moment — feels like the first screen inside the app, not an onboarding step.
struct GentleGuideScreen: View {
    let babyProfile: BabyProfile
    let viewModel: FormulaSetupViewModel
    let onContinue: () -> Void

    // MARK: - Age & guidance
    private var ageInMonths: Int {
        FormulaStageService.ageInMonths(from: babyProfile.dateOfBirth)
    }

    private var guidance: AgeGuidance {
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

    private var parentName: String {
        babyProfile.parentName.isEmpty ? "there" : babyProfile.parentName
    }

    private var babyName: String {
        babyProfile.babyName
    }

    private var formulaContextText: String {
        let brand = viewModel.displayBrandName
        let stage = viewModel.selectedStage?.displayName ?? ""
        if brand.isEmpty && stage.isEmpty { return "" }
        if stage.isEmpty { return brand }
        if brand.isEmpty { return stage }
        return "\(brand) · \(stage)"
    }

    private var hasDOB: Bool {
        babyProfile.dateOfBirth != Date.distantPast && babyProfile.dateOfBirth != Date()
    }

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.backgroundBase.ignoresSafeArea()

                blobBackground(in: geometry)

                VStack(alignment: .leading, spacing: 0) {
                    // Title block
                    VStack(alignment: .leading, spacing: 4) {
                        Text("You're all set,")
                            .font(AppFont.serif(30))
                            .foregroundColor(.inkPrimary)

                        Text(parentName)
                            .font(AppFont.serif(30))
                            .foregroundColor(.inkPrimary)
                    }
                    .padding(.top, geometry.safeAreaInsets.top + 16)

                    Spacer().frame(height: 8)

                    Text("Here's a starting point for \(babyName)")
                        .font(AppFont.sans(13))
                        .foregroundColor(.inkSecondary)

                    Spacer().frame(height: 4)

                    if !formulaContextText.isEmpty {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.almostAquaDark)
                                .frame(width: 6, height: 6)

                            Text(formulaContextText)
                                .font(AppFont.sans(12))
                                .foregroundColor(.inkSecondary)
                        }
                        .padding(.top, 4)

                        if hasDOB {
                            Text("Based on \(babyName)'s age")
                                .font(AppFont.sans(10))
                                .foregroundColor(.almostAquaDark)
                                .padding(.top, 4)
                        } else {
                            Text("Add \(babyName)'s birthday for personalised guidance")
                                .font(AppFont.sans(10))
                                .foregroundColor(.orchidTintDark)
                                .padding(.top, 4)
                        }
                    }

                    Spacer().frame(height: 24)

                    dailyIntakeCard

                    Spacer().frame(height: 12)

                    HStack(spacing: 10) {
                        perFeedCard
                        feedsPerDayCard
                    }

                    Spacer().frame(height: 14)

                    Text("Always follow the instructions on your tin. Amounts vary between babies.")
                        .font(AppFont.sans(10))
                        .foregroundColor(.inkSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Spacer()

                    Button(action: onContinue) {
                        Text("Take me to my dashboard")
                            .font(AppFont.sans(16, weight: .semibold))
                            .foregroundColor(.backgroundCard)
                            .frame(maxWidth: .infinity, minHeight: 54)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.inkPrimary)
                            )
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 24)
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Background blobs
    private func blobBackground(in geometry: GeometryProxy) -> some View {
        ZStack {
            Ellipse()
                .fill(Color.almostAqua.opacity(0.45))
                .frame(
                    width: geometry.size.width * 0.76,
                    height: geometry.size.width * 0.76
                )
                .position(x: geometry.size.width, y: 0)

            Ellipse()
                .fill(Color.almostAquaLight.opacity(0.5))
                .frame(
                    width: geometry.size.width * 0.44,
                    height: geometry.size.width * 0.44
                )
                .position(x: geometry.size.width, y: 0)

            Ellipse()
                .fill(Color.peachDust.opacity(0.45))
                .frame(
                    width: geometry.size.width * 0.84,
                    height: geometry.size.width * 0.84
                )
                .position(x: 0, y: geometry.size.height)

            Ellipse()
                .fill(Color.lemonIcing.opacity(0.38))
                .frame(
                    width: geometry.size.width * 0.60,
                    height: geometry.size.width * 0.60
                )
                .position(x: geometry.size.width, y: geometry.size.height)
        }
        .allowsHitTesting(false)
    }

    // MARK: - Daily intake card
    private var dailyIntakeCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("ESTIMATED DAILY INTAKE")
                .font(AppFont.sans(9, weight: .semibold))
                .foregroundColor(.peachDustDark)
                .tracking(0.4)

            Text("\(guidance.dailyMin)–\(guidance.dailyMax) ml")
                .font(AppFont.serif(36))
                .foregroundColor(.inkPrimary)
                .padding(.top, 10)

            Text("Based on \(babyName)'s age")
                .font(AppFont.sans(11))
                .foregroundColor(.inkSecondary)
                .padding(.top, 8)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.peachDustLight)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Per feed card
    private var perFeedCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("PER FEED")
                .font(AppFont.sans(9, weight: .semibold))
                .foregroundColor(.inkSecondary)
                .tracking(0.4)

            Text("\(guidance.feedMin)–\(guidance.feedMax) ml")
                .font(AppFont.serif(22))
                .foregroundColor(.inkPrimary)

            Text("Typical amount")
                .font(AppFont.sans(10))
                .foregroundColor(.inkSecondary)
        }
        .padding(16)
        .frame(height: 90)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.backgroundCard)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.black.opacity(0.07), lineWidth: 0.5)
        )
    }

    // MARK: - Feeds per day card
    private var feedsPerDayCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("FEEDS PER DAY")
                .font(AppFont.sans(9, weight: .semibold))
                .foregroundColor(.inkSecondary)
                .tracking(0.4)

            Text("\(guidance.feedsPerDayMin)–\(guidance.feedsPerDayMax)")
                .font(AppFont.serif(22))
                .foregroundColor(.inkPrimary)

            Text("At this age")
                .font(AppFont.sans(10))
                .foregroundColor(.inkSecondary)
        }
        .padding(16)
        .frame(height: 90)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.backgroundCard)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.black.opacity(0.07), lineWidth: 0.5)
        )
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
