import SwiftUI

// MARK: - Product / Stage Selection Screen
struct ProductStageSelectionScreen: View {
    @Bindable var viewModel: FormulaSetupViewModel
    var babyDOB: Date?
    var babyName: String = "your baby"
    var stepNumber: Int = 8
    var totalSteps: Int = 10
    let onBack: () -> Void
    let onContinue: () -> Void

    private var recommendedStage: FormulaStage? {
        guard let dob = babyDOB else { return nil }
        return FormulaStageService.recommendedStage(for: dob)
    }

    private var hasRecommendation: Bool {
        recommendedStage != nil
    }

    private var sortedProducts: [FormulaProduct] {
        guard let recommended = recommendedStage else {
            return viewModel.availableProducts
        }
        return viewModel.availableProducts.sorted {
            let aMatches = $0.stage == recommended
            let bMatches = $1.stage == recommended
            if aMatches == bMatches {
                return $0.productName < $1.productName
            }
            return aMatches && !bMatches
        }
    }

    private var recommendedProducts: [FormulaProduct] {
        guard let recommended = recommendedStage else { return [] }
        return sortedProducts.filter { $0.stage == recommended }
    }

    private var otherProducts: [FormulaProduct] {
        guard let recommended = recommendedStage else { return [] }
        return sortedProducts.filter { $0.stage != recommended }
    }

    private var hasMatchingRecommendedProduct: Bool {
        guard let stage = recommendedStage else { return false }
        return viewModel.availableProducts.contains { $0.stage == stage }
    }

    var body: some View {
        OnboardingStepView(
            stepNumber: stepNumber,
            totalSteps: totalSteps,
            question: "Which formula do you use?",
            onBack: onBack,
            content: {
                VStack(spacing: 0) {
                    Text("Select your formula")
                        .font(AppFont.sans(13))
                        .foregroundColor(.inkSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.top, AppSpacing.sm)

                    VStack(spacing: 8) {
                        // Recommendation banner
                        if hasRecommendation, let dob = babyDOB {
                            recommendationBanner(dob: dob)

                            Text("You can select a different stage below")
                                .font(AppFont.sans(10))
                                .foregroundColor(.inkSecondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 8)
                        }

                        // Recommended products
                        if !recommendedProducts.isEmpty {
                            ForEach(recommendedProducts) { product in
                                ProductCard(
                                    product: product,
                                    isSelected: viewModel.selectedProductId == product.id,
                                    isRecommended: true,
                                    action: { viewModel.selectProduct(product) }
                                )
                            }
                        }

                        // Toddler guidance card (when no products match recommended stage)
                        if hasRecommendation, !hasMatchingRecommendedProduct {
                            HStack(spacing: 12) {
                                Image(systemName: "info.circle")
                                    .font(AppFont.sans(18, weight: .medium))
                                    .foregroundColor(.almostAquaDark)

                                Text("At this age, many babies transition away from formula. Select the product you currently use or speak to your doctor or child health nurse.")
                                    .font(AppFont.sans(12))
                                    .foregroundColor(.inkSecondary)
                                    .fixedSize(horizontal: false, vertical: true)

                                Spacer()
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.almostAquaLight)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.almostAquaDark, lineWidth: AppMetrics.borderWidth)
                            )
                            .padding(.horizontal, AppSpacing.lg)
                        }

                        // Other stages divider
                        if !otherProducts.isEmpty, hasMatchingRecommendedProduct {
                            Text("Other stages")
                                .font(AppFont.sans(10, weight: .semibold))
                                .foregroundColor(.inkSecondary)
                                .tracking(0.3)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, AppSpacing.lg)
                                .padding(.top, AppSpacing.sm)
                        }

                        // Other products
                        ForEach(otherProducts) { product in
                            ProductCard(
                                product: product,
                                isSelected: viewModel.selectedProductId == product.id,
                                isRecommended: false,
                                action: { viewModel.selectProduct(product) }
                            )
                        }

                        // If no recommendation, show all products flat
                        if !hasRecommendation {
                            ForEach(sortedProducts) { product in
                                ProductCard(
                                    product: product,
                                    isSelected: viewModel.selectedProductId == product.id,
                                    isRecommended: false,
                                    action: { viewModel.selectProduct(product) }
                                )
                            }
                        }

                        Text("Always follow the instructions on your tin. This is a guide only.")
                            .font(AppFont.sans(10))
                            .foregroundColor(.inkSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, AppSpacing.lg)
                            .padding(.top, AppSpacing.sm)
                    }
                    .padding(.top, AppSpacing.xl)
                    .padding(.bottom, AppSpacing.xxl)

                    Spacer()
                }
            },
            onContinue: onContinue,
            continueEnabled: viewModel.canProceedFromProduct,
            showSkip: viewModel.hasntChosenYet,
            skipAction: onContinue,
            background: { OnboardingBackground.feedingType() }
        )
    }

    // MARK: - Recommendation banner
    private func recommendationBanner(dob: Date) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(AppFont.sans(18, weight: .medium))
                .foregroundColor(.almostAquaDark)

            VStack(alignment: .leading, spacing: 2) {
                Text("We suggest \(FormulaStageService.stageLabel(for: dob))")
                    .font(AppFont.sans(13, weight: .semibold))
                    .foregroundColor(.inkPrimary)

                Text(FormulaStageService.stageExplanation(for: dob, babyName: babyName))
                    .font(AppFont.sans(11))
                    .foregroundColor(.inkSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.almostAquaLight)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.almostAquaDark, lineWidth: AppMetrics.borderWidth)
        )
        .padding(.horizontal, AppSpacing.lg)
    }
}

// MARK: - Product Card
private struct ProductCard: View {
    let product: FormulaProduct
    let isSelected: Bool
    let isRecommended: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(product.productName)
                        .font(AppFont.sans(14, weight: .semibold))
                        .foregroundColor(.inkPrimary)

                    Text(ageRangeText)
                        .font(AppFont.sans(11))
                        .foregroundColor(.inkSecondary)
                }

                Spacer()

                if isRecommended {
                    Text("Recommended")
                        .font(AppFont.sans(9, weight: .semibold))
                        .foregroundColor(.almostAquaDark)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 3)
                        .background(Color.almostAquaLight)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        .padding(.trailing, 8)
                }

                ProductSelectionIndicator(isSelected: isSelected)
            }
            .padding(.horizontal, 16)
            .frame(height: 56)
            .frame(maxWidth: .infinity)
            .background(Color.backgroundCard)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? Color.inkPrimary : Color.black.opacity(AppMetrics.borderOpacity), lineWidth: isSelected ? 1.5 : AppMetrics.borderWidth)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, AppSpacing.lg)
    }

    private var ageRangeText: String {
        if let max = product.maxAgeMonths {
            return "\(product.minAgeMonths)–\(max) months"
        }
        return "\(product.minAgeMonths)+ months"
    }
}

// MARK: - Product Selection Indicator
private struct ProductSelectionIndicator: View {
    let isSelected: Bool

    var body: some View {
        if isSelected {
            Image(systemName: "checkmark.circle.fill")
                .font(AppFont.sans(20, weight: .medium))
                .foregroundColor(.inkPrimary)
        } else {
            Circle()
                .stroke(Color.black.opacity(0.15), lineWidth: 1.5)
                .frame(width: 20, height: 20)
        }
    }
}
