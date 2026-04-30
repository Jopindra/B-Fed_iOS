import SwiftUI

struct CountryScreen: View {
    @Binding var country: String
    @Binding var countryCode: String
    let onBack: () -> Void
    let onContinue: () -> Void

    @State private var showingPicker = false

    private let countries: [(code: String, name: String)] = {
        Locale.Region.isoRegions.compactMap { region in
            let code = region.identifier
            return Locale.current.localizedString(forRegionCode: code).map { (code, $0) }
        }.sorted { $0.name < $1.name }
    }()

    var body: some View {
        OnboardingStepView(
            stepNumber: 3,
            totalSteps: 7,
            question: "Where are you based?",
            onBack: onBack,
            content: {
                VStack(spacing: 0) {
                    Button(action: { showingPicker = true }) {
                        HStack(spacing: AppSpacing.sm) {
                            Text(country.isEmpty ? "Select your country" : country)
                                .font(AppFont.sans(17))
                                .foregroundColor(country.isEmpty ? .orchidTint : .inkPrimary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .font(AppFont.sans(14, weight: .medium))
                                .foregroundColor(.inkSecondary)
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        .frame(height: AppMetrics.inputHeight)
                        .background(Color.backgroundCard)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                                .stroke(Color.black.opacity(AppMetrics.borderOpacity), lineWidth: AppMetrics.borderWidth)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Select your country")
                    .accessibilityValue(country.isEmpty ? "Not selected" : country)
                    .accessibilityIdentifier("onboarding-country-button")
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, AppSpacing.xl)

                    Spacer()
                }
            },
            onContinue: onContinue,
            continueEnabled: true,
            showContinue: false,
            showSkip: true,
            background: { OnboardingBackground.country() }
        )
        .sheet(isPresented: $showingPicker) {
            CountryPickerSheet(country: $country, countryCode: $countryCode, countries: countries, onContinue: onContinue)
        }
    }
}

// MARK: - Country Picker Sheet

private struct CountryPickerSheet: View {
    @Binding var country: String
    @Binding var countryCode: String
    let countries: [(code: String, name: String)]
    let onContinue: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private var filteredCountries: [(code: String, name: String)] {
        if searchText.isEmpty { return countries }
        return countries.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List(filteredCountries, id: \.code) { item in
                Button(action: {
                    country = item.name
                    countryCode = item.code
                    Task {
                        try? await Task.sleep(for: .seconds(0.3))
                        dismiss()
                        onContinue()
                    }
                }) {
                    HStack {
                        Text(item.name)
                            .font(AppFont.bodyLarge)
                            .foregroundColor(.inkPrimary)
                        Spacer()
                        if country == item.name {
                            Image(systemName: "checkmark")
                                .font(AppFont.sans(14, weight: .semibold))
                                .foregroundColor(.inkPrimary)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            .listStyle(.plain)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle("Select Country")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(AppFont.sans(16, weight: .semibold))
                }
            }
        }
    }
}

#Preview {
    CountryScreen(
        country: .constant(""),
        countryCode: .constant(""),
        onBack: {},
        onContinue: {}
    )
}
