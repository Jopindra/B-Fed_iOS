import SwiftUI
import SwiftData

// MARK: - Settings View
struct SettingsView: View {
    @Environment(FeedStore.self) private var feedStore
    @State private var viewModel = SettingsViewModel()
    @State private var showingResetConfirmation = false
    @State private var showingShareSheet = false
    @State private var showingFormulaPicker = false
    @State private var showingCountryPicker = false
    @State private var showingDatePicker = false
    @State private var showingTypePicker = false
    @State private var showingStagePicker = false
    @State private var showingNameEdit = false
    @State private var showingWeightEdit = false
    @State private var showingSavedConfirmation = false
    @State private var shareItems: [Any] = []
    @Query(sort: \Feed.startTime, order: .reverse) private var feeds: [Feed]
    
    var body: some View {
        ZStack {
            Color(hex: "F7F6F2").ignoresSafeArea()
            
            settingsBlobs
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    header
                        .padding(.top, 20)
                    
                    if feedStore.babyProfile != nil {
                        babyCard
                            .padding(.top, 24)
                        
                        feedingCard
                            .padding(.top, 20)
                        
                        dataCard
                            .padding(.top, 20)
                        
                        guidesCard
                            .padding(.top, 20)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 80)
            }
            
            if showingSavedConfirmation {
                savedToast
            }
        }
        .safeAreaInset(edge: .bottom) {
            if feedStore.babyProfile != nil {
                saveButtonContainer
            }
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
        .sheet(isPresented: $showingDatePicker) {
            DatePickerSheet(selectedDate: $viewModel.dateOfBirth)
        }
        .sheet(isPresented: $showingTypePicker) {
            PickerSheet(
                title: "Feeding Type",
                options: FeedingType.allCases.map { ($0.displayName, $0) },
                selection: $viewModel.feedingType
            )
        }
        .sheet(isPresented: $showingStagePicker) {
            let options: [(String, FormulaStage?)] = [("Not specified", nil)] + FormulaStage.allCases.map { ($0.displayName, $0) }
            PickerSheet(
                title: "Formula Stage",
                options: options,
                selection: $viewModel.formulaStage
            )
        }
        .sheet(isPresented: $showingNameEdit) {
            TextEditSheet(title: "Baby's Name", text: $viewModel.babyName)
        }
        .sheet(isPresented: $showingWeightEdit) {
            WeightEditSheet(
                weightKg: $viewModel.weightKg,
                weightUnit: $viewModel.weightUnit
            )
        }
        .alert("Reset all data?", isPresented: $showingResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                feedStore.deleteAllData()
            }
        } message: {
            Text("This will permanently delete all feeds and cannot be undone.")
        }
    }
    
    // MARK: — Blobs
    
    private var settingsBlobs: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "DDD8C0").opacity(0.30))
                .frame(width: 140, height: 140)
                .position(x: UIScreen.main.bounds.width + 50, y: -40)
            
            Circle()
                .fill(Color(hex: "C8C0D4").opacity(0.25))
                .frame(width: 120, height: 120)
                .position(x: -40, y: UIScreen.main.bounds.height + 40)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
    
    // MARK: — Header
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Settings")
                .font(AppFont.sans(22, weight: .semibold))
                .foregroundColor(Color(hex: "1C2421"))
            
            Text("Manage your profile")
                .font(AppFont.sans(13))
                .foregroundColor(Color(hex: "888780"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: — Baby Card
    
    private var babyCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionLabel("Baby")
            
            VStack(spacing: 0) {
                tappableRow(label: "Name", value: viewModel.babyName) {
                    showingNameEdit = true
                }
                
                rowDivider
                
                tappableRow(label: "Date of birth", value: formattedDate(viewModel.dateOfBirth)) {
                    showingDatePicker = true
                }
                
                rowDivider
                
                readOnlyRow(label: "Age", value: viewModel.ageDescription)
                
                rowDivider
                
                tappableRow(
                    label: "Weight",
                    value: viewModel.weightDisplayString,
                    valueColor: viewModel.weightKg == nil ? Color(hex: "C8C0D4") : Color(hex: "1C2421")
                ) {
                    showingWeightEdit = true
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 0.5)
            )
        }
    }
    
    // MARK: — Feeding Card
    
    private var feedingCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionLabel("Feeding")
            
            VStack(spacing: 0) {
                tappableRow(label: "Type", value: viewModel.feedingType.displayName) {
                    showingTypePicker = true
                }
                
                rowDivider
                
                tappableRow(
                    label: "Country",
                    value: viewModel.country.isEmpty ? "Select" : viewModel.country,
                    valueColor: viewModel.country.isEmpty ? Color(hex: "C8C0D4") : Color(hex: "1C2421")
                ) {
                    showingCountryPicker = true
                }
                
                if viewModel.showsFormulaFields {
                    rowDivider
                    
                    tappableRow(
                        label: "Formula brand",
                        value: viewModel.formulaBrand.isEmpty ? "Select" : viewModel.formulaBrand,
                        valueColor: viewModel.formulaBrand.isEmpty ? Color(hex: "C8C0D4") : Color(hex: "1C2421")
                    ) {
                        showingFormulaPicker = true
                    }
                    
                    rowDivider
                    
                    tappableRow(
                        label: "Stage",
                        value: viewModel.stageDisplayName
                    ) {
                        showingStagePicker = true
                    }
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 0.5)
            )
        }
    }
    
    // MARK: — Data Card
    
    private var dataCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionLabel("Data")
            
            VStack(spacing: 0) {
                tappableRow(label: "Export feeds", value: nil, showsChevron: true) {
                    exportHistory()
                }
                
                rowDivider
                
                Button(action: { showingResetConfirmation = true }) {
                    HStack {
                        Text("Reset all data")
                            .font(AppFont.sans(14))
                            .foregroundColor(Color(hex: "E24B4A"))
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(AppFont.sans(12, weight: .medium))
                            .foregroundColor(Color(hex: "E24B4A"))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 0.5)
            )
        }
    }
    
    // MARK: — Guides Card
    
    private var guidesCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionLabel("Guides")
            
            NavigationLink {
                BottlePrepGuideView()
            } label: {
                HStack {
                    Text("Bottle prep guide")
                        .font(AppFont.sans(14))
                        .foregroundColor(Color(hex: "1C2421"))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(AppFont.sans(12, weight: .medium))
                        .foregroundColor(Color(hex: "B4B2A9"))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
            }
            .buttonStyle(PlainButtonStyle())
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 0.5)
            )
        }
    }
    
    // MARK: — Save Button
    
    private var saveButtonContainer: some View {
        VStack(spacing: 0) {
            Button(action: saveChanges) {
                Text("Save changes")
                    .font(AppFont.sans(15, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color(hex: "1C2421"))
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .opacity(viewModel.hasChanges ? 1.0 : 0.4)
            .disabled(!viewModel.hasChanges)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(Color(hex: "F7F6F2"))
    }
    
    private var savedToast: some View {
        VStack {
            Text("Saved")
                .font(AppFont.sans(15, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(hex: "5A8A5A"))
                )
            Spacer()
        }
        .padding(.top, 60)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    // MARK: — Helpers
    
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(AppFont.sans(10, weight: .semibold))
            .foregroundColor(Color(hex: "888780"))
            .tracking(0.06 * 10)
            .textCase(.uppercase)
            .padding(.bottom, 8)
    }
    
    private var rowDivider: some View {
        Divider()
            .background(Color.black.opacity(0.05))
            .padding(.horizontal, 16)
    }
    
    private func tappableRow(
        label: String,
        value: String?,
        valueColor: Color = Color(hex: "1C2421"),
        showsChevron: Bool = true,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(AppFont.sans(14))
                    .foregroundColor(Color(hex: "888780"))
                
                Spacer()
                
                if let value = value {
                    Text(value)
                        .font(AppFont.sans(14, weight: .medium))
                        .foregroundColor(valueColor)
                }
                
                if showsChevron {
                    Image(systemName: "chevron.right")
                        .font(AppFont.sans(12, weight: .medium))
                        .foregroundColor(Color(hex: "B4B2A9"))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func readOnlyRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(AppFont.sans(14))
                .foregroundColor(Color(hex: "B4B2A9"))
            
            Spacer()
            
            Text(value)
                .font(AppFont.sans(13))
                .foregroundColor(Color(hex: "B4B2A9"))
                .italic()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .background(Color(hex: "FAFAF8"))
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func saveChanges() {
        guard viewModel.hasChanges else { return }
        viewModel.save(to: feedStore)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        withAnimation(.easeInOut(duration: 0.25)) {
            showingSavedConfirmation = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.25)) {
                showingSavedConfirmation = false
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
    var weightKg: Double? = nil
    var weightUnit: String = "kg"
    var feedingType: FeedingType = .formula
    var formulaBrand = ""
    var formulaStage: FormulaStage?
    var country = ""
    var countryCode = ""
    var parentName = ""
    var parentEmail = ""
    
    private var originalSnapshot: Snapshot?
    
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
    
    var stageDisplayName: String {
        formulaStage?.displayName ?? "Not specified"
    }
    
    var weightDisplayString: String {
        guard let kg = weightKg else { return "Not set" }
        if weightUnit == "kg" {
            return String(format: "%.1f kg", kg)
        } else {
            let totalLb = kg * 2.20462
            let lb = Int(totalLb)
            let oz = Int(round((totalLb - Double(lb)) * 16))
            return "\(lb) lb \(oz) oz"
        }
    }
    
    var hasChanges: Bool {
        guard let orig = originalSnapshot else { return false }
        return babyName != orig.babyName
            || !Calendar.current.isDate(dateOfBirth, inSameDayAs: orig.dateOfBirth)
            || weightKg != orig.weightKg
            || weightUnit != orig.weightUnit
            || feedingType != orig.feedingType
            || formulaBrand != orig.formulaBrand
            || formulaStage != orig.formulaStage
            || country != orig.country
            || countryCode != orig.countryCode
            || parentName != orig.parentName
            || parentEmail != orig.parentEmail
    }
    
    func load(from profile: BabyProfile?) {
        guard let profile = profile else {
            babyName = ""
            dateOfBirth = Date()
            weightKg = nil
            weightUnit = "kg"
            feedingType = .formula
            formulaBrand = ""
            formulaStage = nil
            country = ""
            countryCode = ""
            parentName = ""
            parentEmail = ""
            originalSnapshot = nil
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
        
        weightKg = profile.weightInKg
        weightUnit = profile.weightUnit
        
        originalSnapshot = Snapshot(
            babyName: babyName,
            dateOfBirth: dateOfBirth,
            weightKg: weightKg,
            weightUnit: weightUnit,
            feedingType: feedingType,
            formulaBrand: formulaBrand,
            formulaStage: formulaStage,
            country: country,
            countryCode: countryCode,
            parentName: parentName,
            parentEmail: parentEmail
        )
    }
    
    func save(to feedStore: FeedStore) {
        let weightGrams = weightKg.map { $0 * 1000 }
        let brand = formulaBrand.isEmpty ? nil : formulaBrand
        let countryValue = country.isEmpty ? nil : country
        let countryCodeValue = countryCode.isEmpty ? nil : countryCode
        
        feedStore.updateBabyProfile(
            babyName: babyName,
            feedingType: feedingType,
            formulaBrand: brand,
            formulaStage: showsFormulaFields ? formulaStage : nil,
            currentWeight: weightGrams,
            weightUnit: weightUnit,
            country: countryValue,
            countryCode: countryCodeValue,
            dateOfBirth: dateOfBirth,
            parentName: parentName,
            parentEmail: parentEmail
        )
    }
    
    private struct Snapshot {
        let babyName: String
        let dateOfBirth: Date
        let weightKg: Double?
        let weightUnit: String
        let feedingType: FeedingType
        let formulaBrand: String
        let formulaStage: FormulaStage?
        let country: String
        let countryCode: String
        let parentName: String
        let parentEmail: String
    }
}

// MARK: - Text Edit Sheet
struct TextEditSheet: View {
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var validator: ((String) -> String?)? = nil
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool
    @State private var errorMessage: String? = nil
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TextField(title, text: $text)
                    .font(AppFont.sans(17))
                    .keyboardType(keyboardType)
                    .submitLabel(.done)
                    .focused($isFocused)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                if let error = errorMessage {
                    Text(error)
                        .font(AppFont.sans(12))
                        .foregroundColor(Color(hex: "E24B4A"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                }
                
                Spacer()
            }
            .background(Color(hex: "F7F6F2"))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let validator = validator, let error = validator(text) {
                            errorMessage = error
                        } else {
                            dismiss()
                        }
                    }
                }
            }
            .onAppear {
                isFocused = true
            }
        }
    }
}

// MARK: - Date Picker Sheet
struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "Date of birth",
                    selection: $selectedDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()
                
                Spacer()
            }
            .background(Color(hex: "F7F6F2"))
            .navigationTitle("Date of birth")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Picker Sheet
struct PickerSheet<T: Hashable>: View {
    let title: String
    let options: [(String, T)]
    @Binding var selection: T
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(options, id: \.1) { label, value in
                    Button(action: {
                        selection = value
                        dismiss()
                    }) {
                        HStack {
                            Text(label)
                                .font(AppFont.sans(16))
                                .foregroundColor(.inkPrimary)
                            Spacer()
                            if selection == value {
                                Image(systemName: "checkmark")
                                    .font(AppFont.sans(14, weight: .semibold))
                                    .foregroundColor(.inkPrimary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .listStyle(.plain)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
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

// MARK: - Weight Edit Sheet
struct WeightEditSheet: View {
    @Binding var weightKg: Double?
    @Binding var weightUnit: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedUnit: String
    @State private var kgText: String
    @State private var lbText: String
    @State private var ozText: String
    @State private var errorMessage: String?
    
    @FocusState private var kgFocused: Bool
    @FocusState private var lbFocused: Bool
    @FocusState private var ozFocused: Bool
    
    init(weightKg: Binding<Double?>, weightUnit: Binding<String>) {
        self._weightKg = weightKg
        self._weightUnit = weightUnit
        let initialUnit = weightUnit.wrappedValue
        _selectedUnit = State(initialValue: initialUnit)
        
        if let kg = weightKg.wrappedValue {
            if initialUnit == "kg" {
                _kgText = State(initialValue: String(format: "%.1f", kg))
                _lbText = State(initialValue: "")
                _ozText = State(initialValue: "")
            } else {
                _kgText = State(initialValue: "")
                let totalLb = kg * 2.20462
                let lb = Int(totalLb)
                let oz = Int(round((totalLb - Double(lb)) * 16))
                _lbText = State(initialValue: String(lb))
                _ozText = State(initialValue: String(oz))
            }
        } else {
            _kgText = State(initialValue: "")
            _lbText = State(initialValue: "")
            _ozText = State(initialValue: "")
        }
    }
    
    private var isKg: Bool { selectedUnit == "kg" }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Unit", selection: $selectedUnit) {
                    Text("kg").tag("kg")
                    Text("lb & oz").tag("lb_oz")
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .tint(Color(hex: "5A8A5A"))
                .onChange(of: selectedUnit) { _, newUnit in
                    convertValues(to: newUnit)
                }
                
                if isKg {
                    kgInput
                } else {
                    lbOzInput
                }
                
                if let error = errorMessage {
                    Text(error)
                        .font(AppFont.sans(12))
                        .foregroundColor(Color(hex: "E24B4A"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                }
                
                Spacer()
            }
            .background(Color(hex: "F7F6F2"))
            .navigationTitle("Weight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if validateAndSave() {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
    private var kgInput: some View {
        HStack(spacing: 8) {
            TextField("e.g. 5.2", text: $kgText)
                .font(AppFont.sans(17))
                .keyboardType(.decimalPad)
                .focused($kgFocused)
            
            Text("kg")
                .font(AppFont.sans(15))
                .foregroundStyle(Color(hex: "888780"))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.black.opacity(0.08), lineWidth: 0.5)
                )
        )
        .padding(.horizontal, 20)
        .padding(.top, 24)
    }
    
    private var lbOzInput: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                TextField("lb", text: $lbText)
                    .font(AppFont.sans(17))
                    .keyboardType(.numberPad)
                    .focused($lbFocused)
                
                Text("lb")
                    .font(AppFont.sans(15))
                    .foregroundStyle(Color(hex: "888780"))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.black.opacity(0.08), lineWidth: 0.5)
                    )
            )
            
            HStack(spacing: 8) {
                TextField("oz", text: $ozText)
                    .font(AppFont.sans(17))
                    .keyboardType(.numberPad)
                    .focused($ozFocused)
                    .onChange(of: ozText) { _, newValue in
                        if let oz = Int(newValue), oz > 15 {
                            ozText = "15"
                        }
                    }
                
                Text("oz")
                    .font(AppFont.sans(15))
                    .foregroundStyle(Color(hex: "888780"))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.black.opacity(0.08), lineWidth: 0.5)
                    )
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
    }
    
    private func convertValues(to newUnit: String) {
        errorMessage = nil
        if newUnit == "kg" {
            if let lb = Int(lbText), lb >= 0,
               let oz = Int(ozText.isEmpty ? "0" : ozText), oz >= 0 {
                let totalLb = Double(lb) + Double(oz) / 16.0
                let kg = totalLb / 2.20462
                kgText = String(format: "%.1f", kg)
            } else {
                kgText = ""
            }
            lbText = ""
            ozText = ""
        } else {
            if let kg = Double(kgText), kg >= 0 {
                let totalLb = kg * 2.20462
                let lb = Int(totalLb)
                let oz = Int(round((totalLb - Double(lb)) * 16))
                lbText = String(lb)
                ozText = String(oz)
            } else {
                lbText = ""
                ozText = ""
            }
            kgText = ""
        }
    }
    
    private func validateAndSave() -> Bool {
        if selectedUnit == "kg" {
            guard let kg = Double(kgText), kg >= 0.5, kg <= 30 else {
                errorMessage = "Please enter a weight between 0.5 and 30 kg"
                return false
            }
            weightKg = kg
            weightUnit = "kg"
        } else {
            guard let lb = Int(lbText), lb >= 0,
                  let oz = Int(ozText.isEmpty ? "0" : ozText), oz >= 0, oz <= 15 else {
                errorMessage = "Please enter a valid weight"
                return false
            }
            let totalOz = lb * 16 + oz
            guard totalOz >= 16, totalOz <= 1056 else {
                errorMessage = "Please enter a valid weight"
                return false
            }
            let kg = Double(totalOz) / 35.27396
            weightKg = kg
            weightUnit = "lb_oz"
        }
        errorMessage = nil
        return true
    }
}

#Preview {
    let store = FeedStore()
    SettingsView()
        .environment(store)
        .modelContainer(for: [Feed.self, BabyProfile.self], inMemory: true)
}
