import SwiftUI

struct SettingsView: View {
    @Environment(FeedStore.self) private var feedStore
    @State private var viewModel = SettingsViewModel()
    @State private var showingResetConfirmation = false
    
    var body: some View {
        NavigationStack {
            List {
                if let profile = feedStore.babyProfile {
                    babySection(profile: profile)
                    feedingSection(profile: profile)
                    parentSection(profile: profile)
                }
                
                dataSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .onAppear {
                viewModel.load(from: feedStore.babyProfile)
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
    }
    
    // MARK: - Baby Section
    private func babySection(profile: BabyProfile) -> some View {
        Section("Baby") {
            TextField("Name", text: $viewModel.babyName)
                .submitLabel(.done)
            
            HStack {
                Text("Date of birth")
                Spacer()
                Text(profile.dateOfBirth, style: .date)
                    .foregroundStyle(Color.inkSecondary)
            }
            
            HStack {
                Text("Age")
                Spacer()
                Text(profile.formattedAge)
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
            
            if viewModel.showsFormulaFields {
                TextField("Formula brand", text: $viewModel.formulaBrand)
                    .submitLabel(.done)
                
                Picker("Stage", selection: $viewModel.formulaStage) {
                    Text("Not specified").tag(Optional<FormulaStage>.none)
                    ForEach(FormulaStage.allCases, id: \.self) { stage in
                        Text(stage.displayName).tag(Optional(stage))
                    }
                }
            }
            
            Button("Save Changes") {
                viewModel.save(to: feedStore)
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(Color.almostAquaDark)
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
    
    // MARK: - Data Section
    private var dataSection: some View {
        Section("Data") {
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
            
            NavigationLink(destination: BottlePrepGuideView()) {
                HStack {
                    Image(systemName: "drop.fill")
                        .foregroundStyle(Color.almostAquaDark)
                    Text("Bottle Prep Guide")
                        .foregroundStyle(Color.inkPrimary)
                }
            }
        }
    }
}

// MARK: - Settings View Model
@MainActor
@Observable
final class SettingsViewModel {
    var babyName = ""
    var currentWeight = ""
    var feedingType: FeedingType = .formula
    var formulaBrand = ""
    var formulaStage: FormulaStage?
    var parentName = ""
    var parentEmail = ""
    
    var showsFormulaFields: Bool {
        feedingType == .formula || feedingType == .mixed
    }
    
    func load(from profile: BabyProfile?) {
        guard let profile = profile else { return }
        babyName = profile.babyName
        feedingType = profile.feedingType
        formulaBrand = profile.formulaBrand ?? ""
        formulaStage = profile.formulaStage
        parentName = profile.parentName
        parentEmail = profile.parentEmail
        
        if let weight = profile.currentWeight ?? profile.birthWeight {
            currentWeight = String(format: "%.2f", weight / 1000)
        }
    }
    
    func save(to feedStore: FeedStore) {
        let weightGrams = Double(currentWeight).map { $0 * 1000 }
        let brand = formulaBrand.isEmpty ? nil : formulaBrand
        
        feedStore.updateBabyProfile(
            babyName: babyName,
            feedingType: feedingType,
            formulaBrand: brand,
            formulaStage: showsFormulaFields ? formulaStage : nil,
            currentWeight: weightGrams,
            parentName: parentName,
            parentEmail: parentEmail
        )
    }
}

#Preview {
    SettingsView()
        .environment(FeedStore())
        .modelContainer(for: [Feed.self, BabyProfile.self], inMemory: true)
}
