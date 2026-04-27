import SwiftUI

// MARK: - Product / Stage Selection Screen
struct ProductStageSelectionScreen: View {
    @Bindable var viewModel: FormulaSetupViewModel
    var stepNumber: Int = 8
    var totalSteps: Int = 10
    let onBack: () -> Void
    let onContinue: () -> Void
    
    var body: some View {
        OnboardingStepView(
            stepNumber: stepNumber,
            totalSteps: totalSteps,
            question: "Which stage is on the tin?",
            onBack: onBack,
            content: {
                VStack(spacing: 0) {
                    if let brand = viewModel.selectedBrand {
                        Text(brand.name)
                            .font(AppFont.sans(13, weight: .semibold))
                            .foregroundColor(.inkSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, AppSpacing.lg)
                            .padding(.top, AppSpacing.sm)
                    }
                    
                    VStack(spacing: AppSpacing.lg) {
                        // Products for this brand
                        if !viewModel.availableProducts.isEmpty {
                            VStack(alignment: .leading, spacing: AppSpacing.md) {
                                Text("Products")
                                    .font(AppFont.sans(12, weight: .semibold))
                                    .foregroundStyle(Color.inkSecondary)
                                    .padding(.horizontal, AppSpacing.sm)
                                
                                ForEach(viewModel.availableProducts) { product in
                                    ProductCard(
                                        product: product,
                                        isSelected: viewModel.selectedProductId == product.id,
                                        action: { viewModel.selectProduct(product) }
                                    )
                                }
                            }
                        }
                        
                        // Stage selection (always show, for manual override or when no products)
                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            Text("Stage")
                                .font(AppFont.sans(12, weight: .semibold))
                                .foregroundStyle(Color.inkSecondary)
                                .padding(.horizontal, AppSpacing.sm)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: AppSpacing.sm) {
                                    ForEach(FormulaStage.allCases, id: \.self) { stage in
                                        FormulaStagePill(
                                            stage: stage,
                                            isSelected: viewModel.selectedStage == stage,
                                            action: { viewModel.selectStage(stage) }
                                        )
                                    }
                                }
                                .padding(.horizontal, AppSpacing.lg)
                            }
                        }
                        
                        // Specialist warning
                        if let product = viewModel.selectedProduct, product.isSpecialist {
                            SpecialistWarningView()
                                .padding(.horizontal, AppSpacing.lg)
                                .padding(.top, AppSpacing.sm)
                        }
                        
                        // Disclaimer
                        FormulaDisclaimerView()
                            .padding(.horizontal, AppSpacing.lg)
                            .padding(.top, AppSpacing.sm)
                    }
                    .padding(.top, AppSpacing.lg)
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
}

// MARK: - Product Card
private struct ProductCard: View {
    let product: FormulaProduct
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(product.productName)
                        .font(AppFont.sans(15, weight: .semibold))
                        .foregroundColor(.inkPrimary)
                    
                    Spacer()
                    
                    if product.isSpecialist {
                        Text("Specialist")
                            .font(AppFont.caption)
                            .foregroundStyle(Color.peachDustDark)
                            .padding(.horizontal, AppSpacing.sm)
                            .padding(.vertical, 4)
                            .background(Color.peachDustLight)
                            .clipShape(Capsule())
                    }
                    
                    SelectionIndicator(isSelected: isSelected)
                }
                
                HStack(spacing: AppSpacing.sm) {
                    Text(product.formulaType.displayName)
                        .font(AppFont.caption)
                        .foregroundStyle(Color.inkSecondary)
                    
                    if let milkBase = product.milkBase {
                        Text("·")
                            .font(AppFont.caption)
                            .foregroundStyle(Color.inkSecondary.opacity(0.5))
                        Text(milkBase)
                            .font(AppFont.caption)
                            .foregroundStyle(Color.inkSecondary)
                    }
                    
                    Text("·")
                        .font(AppFont.caption)
                        .foregroundStyle(Color.inkSecondary.opacity(0.5))
                    Text(ageRangeText)
                        .font(AppFont.caption)
                        .foregroundStyle(Color.inkSecondary)
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
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

// MARK: - Formula Stage Pill
private struct FormulaStagePill: View {
    let stage: FormulaStage
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(stage.displayName)
                .font(AppFont.sans(13, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .white : Color.inkPrimary)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(isSelected ? Color.almostAquaDark : Color.white)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color.black.opacity(AppMetrics.borderOpacity), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
