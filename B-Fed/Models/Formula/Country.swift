import Foundation

// MARK: - Country
/// Supported markets for formula brand suggestions.
struct Country: Identifiable, Codable, Hashable {
    let id: String
    let countryCode: String
    let name: String
}

// MARK: - Formula Brand
/// A formula manufacturer. Brands may be available in multiple countries.
struct FormulaBrand: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let manufacturer: String
    let websiteURL: String?
    let isActive: Bool
}

// MARK: - Formula Product
/// A specific formula SKU available in a given country.
struct FormulaProduct: Identifiable, Codable, Hashable {
    let id: String
    let brandId: String
    let countryCode: String
    let productName: String
    let formulaType: FormulaType
    let stage: FormulaStage
    let minAgeMonths: Int
    let maxAgeMonths: Int?
    let milkBase: String?
    let isSpecialist: Bool
    let requiresMedicalAdvice: Bool
    let preparationNotes: String?
    let sourceURL: String?
    let lastVerifiedAt: Date?
}

// MARK: - Formula Type
enum FormulaType: String, Codable, CaseIterable {
    case standard = "standard"
    case specialist = "specialist"
    case organic = "organic"
    case goat = "goat"
    case plantBased = "plant_based"
    
    var displayName: String {
        switch self {
        case .standard: return "Standard"
        case .specialist: return "Specialist"
        case .organic: return "Organic"
        case .goat: return "Goat milk"
        case .plantBased: return "Plant based"
        }
    }
}

// MARK: - Country Brand Priority
/// Ranks formula brands by popularity/availability within a country.
struct CountryBrandPriority: Codable, Hashable {
    let countryCode: String
    let brandId: String
    let priorityRank: Int
    let notes: String?
}

// MARK: - Feeding Guideline
/// Country-agnostic or country-specific daily intake guidelines by age.
struct FeedingGuideline: Codable, Hashable {
    let countryCode: String?
    let minAgeMonths: Int
    let maxAgeMonths: Int?
    let mlPerKgPerDayMin: Double
    let mlPerKgPerDayMax: Double
    let feedsPerDayMin: Int
    let feedsPerDayMax: Int
    let notes: String?
}
