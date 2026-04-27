import Foundation

// MARK: - Formula Setup Step
enum FormulaSetupStep: Int, CaseIterable {
    case feedingType = 0
    case brandSelection
    case productStage
    case gentleGuide
}

// MARK: - Formula Setup View Model
@Observable
class FormulaSetupViewModel {
    
    // MARK: State
    var countryCode: String = ""
    var feedingType: FeedingType = .formula
    var selectedBrandId: String?
    var selectedProductId: String?
    var selectedStage: FormulaStage?
    var customBrandName: String = ""
    var customProductName: String = ""
    var searchQuery: String = ""
    var showingCustomEntry: Bool = false
    var hasntChosenYet: Bool = false
    
    // MARK: Computed
    
    var availableBrands: [FormulaBrand] {
        guard !countryCode.isEmpty else { return [] }
        return FormulaGuidanceService.brands(forCountryCode: countryCode)
    }
    
    var filteredBrands: [FormulaBrand] {
        if searchQuery.isEmpty { return availableBrands }
        return availableBrands.filter {
            $0.name.localizedCaseInsensitiveContains(searchQuery)
        }
    }
    
    var selectedBrand: FormulaBrand? {
        guard let id = selectedBrandId else { return nil }
        return FormulaSeedData.brands.first { $0.id == id }
    }
    
    var availableProducts: [FormulaProduct] {
        guard let brandId = selectedBrandId, !countryCode.isEmpty else { return [] }
        return FormulaGuidanceService.products(forBrandId: brandId, countryCode: countryCode)
    }
    
    var selectedProduct: FormulaProduct? {
        guard let id = selectedProductId else { return nil }
        return FormulaSeedData.products.first { $0.id == id }
    }
    
    var isUsingCustomBrand: Bool {
        !customBrandName.isEmpty
    }
    
    var canProceedFromBrand: Bool {
        selectedBrandId != nil || isUsingCustomBrand || hasntChosenYet
    }
    
    var canProceedFromProduct: Bool {
        selectedStage != nil || hasntChosenYet
    }
    
    var displayBrandName: String {
        if isUsingCustomBrand { return customBrandName }
        return selectedBrand?.name ?? ""
    }
    
    var displayProductName: String {
        if !customProductName.isEmpty { return customProductName }
        return selectedProduct?.productName ?? ""
    }
    
    // MARK: Actions
    
    func selectBrand(_ brand: FormulaBrand) {
        selectedBrandId = brand.id
        customBrandName = ""
        showingCustomEntry = false
        hasntChosenYet = false
        selectedProductId = nil
        selectedStage = nil
    }
    
    func selectCustomBrand() {
        selectedBrandId = nil
        showingCustomEntry = true
        hasntChosenYet = false
        selectedProductId = nil
        selectedStage = nil
    }
    
    func selectHaventChosen() {
        selectedBrandId = nil
        customBrandName = ""
        customProductName = ""
        showingCustomEntry = false
        hasntChosenYet = true
        selectedProductId = nil
        selectedStage = nil
    }
    
    func selectProduct(_ product: FormulaProduct) {
        selectedProductId = product.id
        selectedStage = product.stage
    }
    
    func selectStage(_ stage: FormulaStage) {
        selectedStage = stage
    }
    
    func buildFormulaProfile() -> BabyFormulaProfile {
        BabyFormulaProfile(
            selectedCountryCode: countryCode,
            selectedBrandId: selectedBrandId,
            selectedProductId: selectedProductId,
            selectedStage: selectedStage,
            usesFormulaGuide: feedingType == .formula || feedingType == .mixed,
            customFormulaBrand: customBrandName.isEmpty ? nil : customBrandName,
            customFormulaProduct: customProductName.isEmpty ? nil : customProductName
        )
    }
    
    func reset() {
        countryCode = ""
        feedingType = .formula
        selectedBrandId = nil
        selectedProductId = nil
        selectedStage = nil
        customBrandName = ""
        customProductName = ""
        searchQuery = ""
        showingCustomEntry = false
        hasntChosenYet = false
    }
}
