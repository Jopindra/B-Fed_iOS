import SwiftUI

struct FormulaSelector: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SelectedFormulaStore.self) private var formulaStore
    @Environment(FeedStore.self) private var feedStore

    @State private var searchText: String = ""
    @State private var showingCustomInput: Bool = false
    @State private var customName: String = ""

    private var babyDOB: Date? {
        feedStore.babyProfile?.dateOfBirth
    }

    private var babyName: String {
        feedStore.babyProfile?.babyName ?? "your baby"
    }

    private var recommendedStage: FormulaStage? {
        guard let dob = babyDOB else { return nil }
        return FormulaStageService.recommendedStage(for: dob)
    }

    private var hasRecommendation: Bool {
        recommendedStage != nil
    }

    private var hasMatchingRecommendedProduct: Bool {
        guard let stage = recommendedStage else { return false }
        return filteredFormulas.contains { matchesStage($0, stage: stage) }
    }

    private var filteredFormulas: [Formula] {
        FormulaService.searchFormulas(query: searchText)
    }

    private var sortedFormulas: [Formula] {
        guard let stage = recommendedStage else {
            return filteredFormulas
        }
        return filteredFormulas.sorted {
            let aMatches = matchesStage($0, stage: stage)
            let bMatches = matchesStage($1, stage: stage)
            if aMatches == bMatches {
                return $0.brand < $1.brand
            }
            return aMatches && !bMatches
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .font(AppFont.sans(14, weight: .regular))
                        .foregroundStyle(Color.inkSecondary)

                    TextField("Search formula", text: $searchText)
                        .font(AppFont.sans(14, weight: .regular))
                        .foregroundStyle(Color.inkPrimary)

                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(AppFont.sans(14))
                                .foregroundStyle(Color.inkSecondary)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.backgroundBase)
                )
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 8)

                List {
                    // Recommendation banner
                    if hasRecommendation, let dob = babyDOB {
                        Section {
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
                            .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }

                    // Toddler guidance card (when no products match recommended stage)
                    if hasRecommendation, let stage = recommendedStage, !hasMatchingRecommendedProduct {
                        Section {
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
                            .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }

                    // Flat formula list — recommended first, then others
                    if !sortedFormulas.isEmpty {
                        let recommended = sortedFormulas.filter { matchesStage($0, stage: recommendedStage) }
                        let others = sortedFormulas.filter { !matchesStage($0, stage: recommendedStage) }

                        if !recommended.isEmpty {
                            Section {
                                ForEach(recommended) { formula in
                                    FormulaRow(
                                        formula: formula,
                                        isSelected: formulaStore.selectedFormula?.id == formula.id,
                                        isRecommended: true
                                    )
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        formulaStore.select(formula)
                                        dismiss()
                                    }
                                    .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                }
                            }
                        }

                        if !others.isEmpty {
                            Section {
                                ForEach(others) { formula in
                                    FormulaRow(
                                        formula: formula,
                                        isSelected: formulaStore.selectedFormula?.id == formula.id,
                                        isRecommended: false
                                    )
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        formulaStore.select(formula)
                                        dismiss()
                                    }
                                    .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                }
                            } header: {
                                if !recommended.isEmpty {
                                    Text("Other stages")
                                        .font(AppFont.sans(10, weight: .semibold))
                                        .foregroundStyle(Color.inkSecondary)
                                        .tracking(0.3)
                                }
                            }
                        }
                    }

                    // Add your own
                    Section {
                        Button(action: { showingCustomInput = true }) {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color.orchidTintLight)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Image(systemName: "plus")
                                            .font(AppFont.sans(12, weight: .semibold))
                                            .foregroundStyle(Color.orchidTintDark)
                                    )

                                Text("Add your own")
                                    .font(AppFont.sans(14, weight: .medium))
                                    .foregroundStyle(Color.inkPrimary)

                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Select Formula")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .sheet(isPresented: $showingCustomInput) {
                CustomFormulaSheet { name in
                    let custom = FormulaService.customFormula(name: name)
                    formulaStore.select(custom)
                    dismiss()
                }
            }
        }
    }

    private func matchesStage(_ formula: Formula, stage: FormulaStage?) -> Bool {
        guard let stage else { return false }
        let stageString = formula.stage.lowercased()
        switch stage {
        case .stage1:
            return stageString.contains("1") && !stageString.contains("2") && !stageString.contains("3")
        case .stage2:
            return stageString.contains("2") && !stageString.contains("3")
        case .stage3:
            return stageString.contains("3")
        case .toddler:
            return stageString.contains("toddler")
        default:
            return false
        }
    }
}

// MARK: - Formula Row
struct FormulaRow: View {
    let formula: Formula
    let isSelected: Bool
    let isRecommended: Bool

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.almostAquaLight)
                .frame(width: 32, height: 32)
                .overlay(
                    Text(String(formula.brand.prefix(1)).uppercased())
                        .font(AppFont.sans(12, weight: .semibold))
                        .foregroundStyle(Color.almostAquaDark)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(formula.displayName)
                    .font(AppFont.sans(14, weight: .medium))
                    .foregroundStyle(Color.inkPrimary)

                Text(formula.stage)
                    .font(AppFont.sans(11, weight: .regular))
                    .foregroundStyle(Color.inkSecondary)
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

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(AppFont.sans(20, weight: .regular))
                    .foregroundStyle(Color.inkPrimary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Custom Formula Sheet
struct CustomFormulaSheet: View {
    let onSave: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Enter your formula name")
                    .font(AppFont.sans(14, weight: .regular))
                    .foregroundStyle(Color.inkSecondary)
                    .padding(.top, 20)

                TextField("Formula name", text: $name)
                    .font(AppFont.sans(16, weight: .regular))
                    .padding(.horizontal, 16)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.backgroundBase)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.inkPrimary.opacity(AppMetrics.borderOpacity), lineWidth: AppMetrics.borderWidth)
                            )
                    )
                    .padding(.horizontal, 20)

                Spacer()
            }
            .navigationTitle("Custom Formula")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmed = name.trimmingCharacters(in: .whitespaces)
                        if !trimmed.isEmpty {
                            onSave(trimmed)
                        }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    FormulaSelector()
        .environment(SelectedFormulaStore())
        .environment(FeedStore())
}
