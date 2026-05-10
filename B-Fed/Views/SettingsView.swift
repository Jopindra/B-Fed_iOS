import SwiftUI
import SwiftData

// MARK: - Settings View
struct SettingsView: View {
    @Environment(FeedStore.self) private var feedStore
    @Environment(ProfileStore.self) private var profileStore
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
            Color.surfaceCream.ignoresSafeArea()
            
            settingsBlobs
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    header
                        .padding(.top, 20)
                    
                    if profileStore.fetchProfile() != nil {
                        babyCard
                            .padding(.top, 24)

                        feedingCard
                            .padding(.top, 20)

                        dataCard
                            .padding(.top, 20)

                        guidesCard
                            .padding(.top, 20)
                    } else {
                        noProfileCard
                            .padding(.top, 40)
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
            if profileStore.fetchProfile() != nil {
                saveButtonContainer
            }
        }
        .onAppear {
            viewModel.load(from: profileStore.fetchProfile())
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
                .fill(Color.accentLavender.opacity(0.25))
                .frame(width: 120, height: 120)
                .position(x: -40, y: UIScreen.main.bounds.height + 40)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .ignoresSafeArea()
    }
    
    // MARK: — Header
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Settings")
                .font(AppFont.sans(22, weight: .semibold))
                .foregroundColor(Color.textPrimary)
            
            Text("Manage your profile")
                .font(AppFont.sans(13))
                .foregroundColor(Color.textSecondary)
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
                    valueColor: viewModel.weightKg == nil ? Color.accentLavender : Color.textPrimary
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
                    valueColor: viewModel.country.isEmpty ? Color.accentLavender : Color.textPrimary
                ) {
                    showingCountryPicker = true
                }
                
                if viewModel.showsFormulaFields {
                    rowDivider
                    
                    tappableRow(
                        label: "Formula brand",
                        value: viewModel.formulaBrand.isEmpty ? "Select" : viewModel.formulaBrand,
                        valueColor: viewModel.formulaBrand.isEmpty ? Color.accentLavender : Color.textPrimary
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
                            .foregroundColor(Color.errorRed)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(AppFont.sans(12, weight: .medium))
                            .foregroundColor(Color.errorRed)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel("Reset all data")
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
                        .foregroundColor(Color.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(AppFont.sans(12, weight: .medium))
                        .foregroundColor(Color.textTertiary)
                        .accessibilityHidden(true)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
            }
            .accessibilityLabel("Bottle prep guide")
            .buttonStyle(PlainButtonStyle())
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 0.5)
            )
        }
    }
    
    // MARK: — No Profile Card
    
    private var noProfileCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(Color.accentLavender)
            
            Text("Add your baby's details")
                .font(AppFont.sans(17, weight: .medium))
                .foregroundColor(Color.textPrimary)
            
            Text("Set up your baby's profile to get personalised feeding guidance and track their progress.")
                .font(AppFont.sans(13))
                .foregroundColor(Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 0.5)
        )
        .padding(.horizontal, 20)
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
                            .fill(Color.textPrimary)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("Save changes")
            .opacity(viewModel.hasChanges ? 1.0 : 0.4)
            .disabled(!viewModel.hasChanges)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(Color.surfaceCream)
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
                        .fill(Color.accentGreen)
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
            .foregroundColor(Color.textSecondary)
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
        valueColor: Color = Color.textPrimary,
        showsChevron: Bool = true,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(AppFont.sans(14))
                    .foregroundColor(Color.textSecondary)
                
                Spacer()
                
                if let value = value {
                    Text(value)
                        .font(AppFont.sans(14, weight: .medium))
                        .foregroundColor(valueColor)
                }
                
                if showsChevron {
                    Image(systemName: "chevron.right")
                        .font(AppFont.sans(12, weight: .medium))
                        .foregroundColor(Color.textTertiary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label)\(value != nil ? ", \(value!)" : "")")
    }
    
    private func readOnlyRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(AppFont.sans(14))
                .foregroundColor(Color.textTertiary)
            
            Spacer()
            
            Text(value)
                .font(AppFont.sans(13))
                .foregroundColor(Color.textTertiary)
                .italic()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .background(Color(hex: "FAFAF8"))
    }
    
    private func formattedDate(_ date: Date) -> String {
        AppFormatters.mediumDate.string(from: date)
    }
    
    private func saveChanges() {
        guard viewModel.hasChanges else { return }
        viewModel.save(to: feedStore)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        if UIAccessibility.isReduceMotionEnabled {
            showingSavedConfirmation = true
            UIAccessibility.post(notification: .announcement, argument: "Settings saved")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showingSavedConfirmation = false
            }
        } else {
            withAnimation(.easeInOut(duration: 0.25)) {
                showingSavedConfirmation = true
            }
            UIAccessibility.post(notification: .announcement, argument: "Settings saved")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showingSavedConfirmation = false
                }
            }
        }
    }
    
    private func exportHistory() {
        let text = FeedExporter.exportText(profile: profileStore.fetchProfile(), feeds: feeds)
        shareItems = [text]
        showingShareSheet = true
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
                        .foregroundColor(Color.errorRed)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                }
                
                Spacer()
            }
            .background(Color.surfaceCream)
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
            .background(Color.surfaceCream)
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
                .tint(Color.accentGreen)
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
                        .foregroundColor(Color.errorRed)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                }
                
                Spacer()
            }
            .background(Color.surfaceCream)
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
                .foregroundStyle(Color.textSecondary)
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
                    .foregroundStyle(Color.textSecondary)
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
                    .foregroundStyle(Color.textSecondary)
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
    SettingsView()
        .environment(FeedStore())
        .environment(ProfileStore())
        .modelContainer(for: [Feed.self, BabyProfile.self], inMemory: true)
}
