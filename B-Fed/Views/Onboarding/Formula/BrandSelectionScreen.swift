import SwiftUI

// MARK: - Brand Selection Screen
struct BrandSelectionScreen: View {
    @Bindable var viewModel: FormulaSetupViewModel
    var stepNumber: Int = 7
    var totalSteps: Int = 10
    let onBack: () -> Void
    let onContinue: () -> Void
    
    var body: some View {
        OnboardingStepView(
            stepNumber: stepNumber,
            totalSteps: totalSteps,
            question: "Which formula brand are you using?",
            onBack: onBack,
            content: {
                VStack(spacing: 0) {
                    Text("Common in \(countryDisplayName)")
                        .font(AppFont.sans(13))
                        .foregroundColor(.inkSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.top, AppSpacing.sm)
                    
                    // Search
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.inkSecondary)
                        TextField("Search brands", text: $viewModel.searchQuery)
                            .font(AppFont.sans(15))
                            .foregroundColor(.inkPrimary)
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .frame(height: AppMetrics.inputHeight)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                            .stroke(Color.black.opacity(AppMetrics.borderOpacity), lineWidth: AppMetrics.borderWidth)
                    )
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, AppSpacing.lg)
                    
                    // Brand grid
                    VStack(spacing: AppSpacing.md) {
                        ForEach(viewModel.filteredBrands) { brand in
                            BrandCard(
                                brand: brand,
                                isSelected: viewModel.selectedBrandId == brand.id,
                                action: { viewModel.selectBrand(brand) }
                            )
                        }
                        
                        // Alt options
                        altOptionCard(
                            title: "I don't see my brand",
                            subtitle: "Enter it manually",
                            icon: "pencil",
                            isSelected: viewModel.showingCustomEntry,
                            action: { viewModel.selectCustomBrand() }
                        )
                        
                        altOptionCard(
                            title: "I haven't chosen yet",
                            subtitle: "Skip this step for now",
                            icon: "ellipsis",
                            isSelected: viewModel.hasntChosenYet,
                            action: { viewModel.selectHaventChosen() }
                        )
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.xl)
                    
                    // Custom entry
                    if viewModel.showingCustomEntry {
                        VStack(spacing: AppSpacing.md) {
                            OnboardingInputField(
                                label: "Brand name",
                                placeholder: "e.g. Bellamy's Organic",
                                text: $viewModel.customBrandName
                            )
                            OnboardingInputField(
                                label: "Product name (optional)",
                                placeholder: "e.g. Organic Stage 1",
                                text: $viewModel.customProductName
                            )
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.top, AppSpacing.md)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    
                    Spacer()
                }
            },
            onContinue: onContinue,
            continueEnabled: viewModel.canProceedFromBrand,
            showSkip: false,
            background: { OnboardingBackground.feedingType() }
        )
    }
    
    private var countryDisplayName: String {
        FormulaSeedData.countries.first { $0.countryCode == viewModel.countryCode }?.name ?? "your country"
    }
    
    private func altOptionCard(title: String, subtitle: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.backgroundBase)
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(Color.inkSecondary)
                }
                .padding(.leading, AppSpacing.lg)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppFont.sans(15, weight: .semibold))
                        .foregroundColor(.inkPrimary)
                    Text(subtitle)
                        .font(AppFont.sans(12))
                        .foregroundColor(.inkSecondary)
                }
                .padding(.leading, AppSpacing.md)
                
                Spacer()
                
                SelectionIndicator(isSelected: isSelected)
                    .padding(.trailing, AppSpacing.lg)
            }
            .frame(height: 72)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .stroke(isSelected ? Color.inkPrimary : Color.black.opacity(AppMetrics.borderOpacity), lineWidth: isSelected ? 1.5 : AppMetrics.borderWidth)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Brand Card
private struct BrandCard: View {
    let brand: FormulaBrand
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(brand.name)
                        .font(AppFont.sans(15, weight: .semibold))
                        .foregroundColor(.inkPrimary)
                    Text(brand.manufacturer)
                        .font(AppFont.sans(12))
                        .foregroundColor(.inkSecondary)
                }
                .padding(.leading, AppSpacing.lg)
                
                Spacer()
                
                SelectionIndicator(isSelected: isSelected)
                    .padding(.trailing, AppSpacing.lg)
            }
            .frame(height: 64)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .stroke(isSelected ? Color.inkPrimary : Color.black.opacity(AppMetrics.borderOpacity), lineWidth: isSelected ? 1.5 : AppMetrics.borderWidth)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(brand.name)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
    }
}
