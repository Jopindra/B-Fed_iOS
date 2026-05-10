import Foundation

// MARK: - Baby Formula Profile
/// Stores a parent's formula selection alongside their baby profile.
/// Persisted as part of BabyProfile.
struct BabyFormulaProfile: Codable, Hashable {
    var selectedCountryCode: String?
    var selectedBrandId: String?
    var selectedProductId: String?
    var selectedStage: FormulaStage?
    var usesFormulaGuide: Bool
    var customFormulaBrand: String?
    var customFormulaProduct: String?
    
    init(
        selectedCountryCode: String? = nil,
        selectedBrandId: String? = nil,
        selectedProductId: String? = nil,
        selectedStage: FormulaStage? = nil,
        usesFormulaGuide: Bool = false,
        customFormulaBrand: String? = nil,
        customFormulaProduct: String? = nil
    ) {
        self.selectedCountryCode = selectedCountryCode
        self.selectedBrandId = selectedBrandId
        self.selectedProductId = selectedProductId
        self.selectedStage = selectedStage
        self.usesFormulaGuide = usesFormulaGuide
        self.customFormulaBrand = customFormulaBrand
        self.customFormulaProduct = customFormulaProduct
    }
    
    var hasSelection: Bool {
        selectedBrandId != nil || customFormulaBrand != nil
    }
    
    var displayBrandName: String? {
        customFormulaBrand ?? selectedBrandId.map { id in
            FormulaSeedData.brands.first { $0.id == id }?.name
        } ?? nil
    }
    
    var displayProductName: String? {
        customFormulaProduct ?? selectedProductId.map { id in
            FormulaSeedData.products.first { $0.id == id }?.productName
        } ?? nil
    }
}
