import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(FeedStore.self) private var feedStore
    @State private var viewModel = SettingsViewModel()
    @State private var showingResetConfirmation = false
    @State private var showingShareSheet = false
    @State private var showingFormulaPicker = false
    @State private var showingCountryPicker = false
    @State private var shareItems: [Any] = []
    @Query(sort: \Feed.startTime, order: .reverse) private var feeds: [Feed]
    
    var body: some View {
        NavigationStack {
            List {
                if let profile = feedStore.babyProfile {
                    babySection(profile: profile)
                    feedingSection(profile: profile)
                    parentSection(profile: profile)
                }
                
                dataSection
                guidesSection
            }
            .listStyle(.insetGrouped)
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 32)
            }
            .navigationTitle("Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
        .onAppear {
            viewModel.load(from: feedStore.babyProfile)
        }
        .onChange(of: feedStore.babyProfile) { _, newProfile in
            viewModel.load(from: newProfile)
        }
            .sheet(isPresented: $showingShareSheet) {
                ActivityView(activityItems: shareItems)
            }
            .sheet(isPresented: $showingFormulaPicker) {
                FormulaPickerSheet(
                    countryCode: viewModel.countryCode,
                    currentBrand: viewModel.formulaBrand,
                    currentStage: viewModel.formulaStage,
                    onSave: { brand, stage in
                        viewModel.formulaBrand = brand
                        viewModel.formulaStage = stage
                    }
                )
            }
            .sheet(isPresented: $showingCountryPicker) {
                SettingsCountryPickerSheet(
                    country: $viewModel.country,
                    countryCode: $viewModel.countryCode,
                    onSave: {
                        // Reset formula brand if not available in new country
                        if !viewModel.formulaBrand.isEmpty {
                            let brands = FormulaGuidanceService.brands(forCountryCode: viewModel.countryCode)
                            let isValid = brands.contains { $0.name == viewModel.formulaBrand }
                            if !isValid {
                                viewModel.formulaBrand = ""
                                viewModel.formulaStage = nil
                            }
                        }
                    }
                )
            }
            .alert("Reset All Data?", isPresented: $showingResetConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    feedStore.deleteAllData()
                }
            } message: {
                Text("This will delete all feeds and your baby profile. This action cannot be undone.")
            }
    }
    
    // MARK: - Baby Section
    private func babySection(profile: BabyProfile) -> some View {
        Section("Baby") {
            TextField("Name", text: $viewModel.babyName)
                .submitLabel(.done)
            
            DatePicker("Date of birth", selection: $viewModel.dateOfBirth, in: ...Date(), displayedComponents: .date)
            
            HStack {
                Text("Age")
                Spacer()
                Text(viewModel.ageDescription)
                    .foregroundStyle(Color.inkSecondary)
            }
            
            HStack {
                Text("Weight (kg)")
                Spacer()
                TextField("Weight", text: $viewModel.currentWeight)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
        }
    }
    
    // MARK: - Feeding Section
    private func feedingSection(profile: BabyProfile) -> some View {
        Section("Feeding") {
            Picker("Type", selection: $viewModel.feedingType) {
                ForEach(FeedingType.allCases, id: \.self) { type in
                    Text(type.displayName).tag(type)
                }
            }
            
            Button {
                showingCountryPicker = true
            } label: {
                HStack {
                    Text("Country")
                        .foregroundStyle(Color.inkPrimary)
                    Spacer()
                    Text(viewModel.country.isEmpty ? "Select" : viewModel.country)
                        .foregroundStyle(viewModel.country.isEmpty ? Color.orchidTint : Color.inkSecondary)
                    Image(systemName: "chevron.right")
                        .font(AppFont.sans(13, weight: .semibold))
                        .foregroundStyle(Color.inkSecondary.opacity(0.5))
                }
            }
            .buttonStyle(.plain)
            
            if viewModel.showsFormulaFields {
                Button {
                    showingFormulaPicker = true
                } label: {
                    HStack {
                        Text("Formula brand")
                            .foregroundStyle(Color.inkPrimary)
                        Spacer()
                        Text(viewModel.formulaBrand.isEmpty ? "Select" : viewModel.formulaBrand)
                            .foregroundStyle(viewModel.formulaBrand.isEmpty ? Color.orchidTint : Color.inkSecondary)
                        Image(systemName: "chevron.right")
                            .font(AppFont.sans(13, weight: .semibold))
                            .foregroundStyle(Color.inkSecondary.opacity(0.5))
                    }
                }
                .buttonStyle(.plain)
                
                Picker("Stage", selection: $viewModel.formulaStage) {
                    Text("Not specified").tag(Optional<FormulaStage>.none)
                    ForEach(FormulaStage.allCases, id: \.self) { stage in
                        Text(stage.displayName).tag(Optional(stage))
                    }
                }
            }
            
            Button {
                viewModel.save(to: feedStore)
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            } label: {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Save Changes")
                }
                .font(AppFont.button)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.md)
            }
            .primaryButton()
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
        }
    }
    
    // MARK: - Parent Section
    private func parentSection(profile: BabyProfile) -> some View {
        Section("Parent") {
            TextField("Name", text: $viewModel.parentName)
                .submitLabel(.done)
            
            TextField("Email", text: $viewModel.parentEmail)
                .keyboardType(.emailAddress)
                .submitLabel(.done)
                .textContentType(.emailAddress)
        }
    }
    
    // MARK: - Guides Section
    private var guidesSection: some View {
        Section("Guides") {
            NavigationLink {
                BottlePrepGuideView()
            } label: {
                Label("Bottle prep guide", systemImage: "list.bullet.clipboard")
            }
        }
    }
    
    // MARK: - Data Section
    private var dataSection: some View {
        Section("Data") {
            Button {
                exportHistory()
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(Color.almostAquaDark)
                    Text("Export feed history")
                        .foregroundStyle(Color.inkPrimary)
                }
            }
            
            Button {
                showingResetConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                        .foregroundStyle(Color.peachDustDark)
                    Text("Reset all data")
                        .foregroundStyle(Color.peachDustDark)
                }
            }
        }
    }
    
    private func exportHistory() {
        let text = FeedExporter.exportText(profile: feedStore.babyProfile, feeds: feeds)
        shareItems = [text]
        showingShareSheet = true
    }
}

// MARK: - Settings View Model
@MainActor
@Observable
final class SettingsViewModel {
    var babyName = ""
    var dateOfBirth: Date = Date()
    var currentWeight = ""
    var feedingType: FeedingType = .formula
    var formulaBrand = ""
    var formulaStage: FormulaStage?
    var country = ""
    var countryCode = ""
    var parentName = ""
    var parentEmail = ""
    
    var showsFormulaFields: Bool {
        feedingType == .formula || feedingType == .mixed
    }
    
    var ageDescription: String {
        let now = Date()
        let components = Calendar.current.dateComponents([.year, .month, .weekOfYear], from: dateOfBirth, to: now)
        let months = (components.year ?? 0) * 12 + (components.month ?? 0)
        let weeks = components.weekOfYear ?? 0

        if months < 1 {
            return "\(weeks) week\(weeks == 1 ? "" : "s") old"
        } else if months < 24 {
            return "\(months) month\(months == 1 ? "" : "s") old"
        } else {
            let years = months / 12
            return "\(years) year\(years == 1 ? "" : "s") old"
        }
    }
    
    func load(from profile: BabyProfile?) {
        guard let profile = profile else {
            // Reset all fields when profile is nil
            babyName = ""
            dateOfBirth = Date()
            currentWeight = ""
            feedingType = .formula
            formulaBrand = ""
            formulaStage = nil
            country = ""
            countryCode = ""
            parentName = ""
            parentEmail = ""
            return
        }
        babyName = profile.babyName
        dateOfBirth = profile.dateOfBirth
        feedingType = profile.feedingType
        formulaBrand = profile.formulaBrand ?? ""
        formulaStage = profile.formulaStage
        country = profile.country
        countryCode = profile.countryCode
        parentName = profile.parentName
        parentEmail = profile.parentEmail
        
        if let weight = profile.currentWeight ?? profile.birthWeight {
            currentWeight = String(format: "%.2f", weight / 1000)
        } else {
            currentWeight = ""
        }
    }
    
    func save(to feedStore: FeedStore) {
        let weightGrams = Double(currentWeight).map { $0 * 1000 }
        let brand = formulaBrand.isEmpty ? nil : formulaBrand
        let countryValue = country.isEmpty ? nil : country
        let countryCodeValue = countryCode.isEmpty ? nil : countryCode
        
        feedStore.updateBabyProfile(
            babyName: babyName,
            feedingType: feedingType,
            formulaBrand: brand,
            formulaStage: showsFormulaFields ? formulaStage : nil,
            currentWeight: weightGrams,
            country: countryValue,
            countryCode: countryCodeValue,
            dateOfBirth: dateOfBirth,
            parentName: parentName,
            parentEmail: parentEmail
        )
    }
}

// MARK: - Formula Picker Sheet
struct FormulaPickerSheet: View {
    let countryCode: String
    let currentBrand: String
    let currentStage: FormulaStage?
    let onSave: (String, FormulaStage?) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = FormulaSetupViewModel()
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            BrandSelectionScreen(
                viewModel: viewModel,
                stepNumber: 1,
                totalSteps: 2,
                onBack: { dismiss() },
                onContinue: { path.append(FormulaPickerStep.stage) }
            )
            .navigationDestination(for: FormulaPickerStep.self) { step in
                switch step {
                case .stage:
                    ProductStageSelectionScreen(
                        viewModel: viewModel,
                        stepNumber: 2,
                        totalSteps: 2,
                        onBack: { path.removeLast() },
                        onContinue: {
                            let brand = viewModel.displayBrandName
                            let stage = viewModel.selectedStage
                            onSave(brand, stage)
                            dismiss()
                        }
                    )
                }
            }
        }
        .onAppear {
            viewModel.countryCode = countryCode
            viewModel.feedingType = .formula
            // Pre-select current brand if it matches seed data
            if let match = FormulaSeedData.brands.first(where: { $0.name == currentBrand }) {
                viewModel.selectBrand(match)
            } else if !currentBrand.isEmpty {
                viewModel.selectCustomBrand()
                viewModel.customBrandName = currentBrand
            }
            viewModel.selectedStage = currentStage
        }
    }
}

private enum FormulaPickerStep: Hashable {
    case stage
}

// MARK: - Country Picker Sheet (Settings)
struct SettingsCountryPickerSheet: View {
    @Binding var country: String
    @Binding var countryCode: String
    let onSave: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    private let countries: [(code: String, name: String)] = {
        Locale.Region.isoRegions.compactMap { region in
            let code = region.identifier
            return Locale.current.localizedString(forRegionCode: code).map { (code, $0) }
        }.sorted { $0.name < $1.name }
    }()
    
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
                    onSave()
                    dismiss()
                }) {
                    HStack {
                        Text(item.name)
                            .font(AppFont.sans(16))
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
    let store = FeedStore()
    SettingsView()
        .environment(store)
        .modelContainer(for: [Feed.self, BabyProfile.self], inMemory: true)
}
