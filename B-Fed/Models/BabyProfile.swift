import Foundation
import SwiftData

// MARK: - Baby Profile
/// Stores baby information for intelligent feeding guidance
@Model
class BabyProfile {
    var id: UUID = UUID()
    
    // Parent information
    var parentName: String = ""
    var parentEmail: String = ""
    var parentDOB: Date = Date()
    var country: String = ""
    var countryCode: String = ""
    
    // Baby information
    var babyName: String = "Baby"
    var dateOfBirth: Date = Date()
    var birthWeight: Double? // in grams
    var currentWeight: Double? // in grams
    var weightUnit: String = "kg"
    var feedingType: FeedingType = FeedingType.formula
    var formulaBrand: String?
    var formulaStage: FormulaStage?
    
    // Formula Library + Smart Guide
    var selectedBrandId: String?
    var selectedProductId: String?
    var usesFormulaGuide: Bool = false
    var customFormulaBrand: String?
    var customFormulaProduct: String?
    
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    /// Whether this profile has formula information worth displaying
    var showsFormulaInfo: Bool {
        feedingType == .formula || feedingType == .mixed
    }
    
    init(
        id: UUID = UUID(),
        parentName: String = "",
        parentEmail: String = "",
        parentDOB: Date = Date(),
        country: String = "",
        countryCode: String = "",
        babyName: String = "Baby",
        dateOfBirth: Date = Date(),
        birthWeight: Double? = nil,
        currentWeight: Double? = nil,
        weightUnit: String = "kg",
        feedingType: FeedingType = .formula,
        formulaBrand: String? = nil,
        formulaStage: FormulaStage? = nil,
        selectedBrandId: String? = nil,
        selectedProductId: String? = nil,
        usesFormulaGuide: Bool = false,
        customFormulaBrand: String? = nil,
        customFormulaProduct: String? = nil
    ) {
        self.id = id
        self.parentName = parentName
        self.parentEmail = parentEmail
        self.parentDOB = parentDOB
        self.country = country
        self.countryCode = countryCode
        self.babyName = babyName
        self.dateOfBirth = dateOfBirth
        self.birthWeight = birthWeight
        self.currentWeight = currentWeight
        self.weightUnit = weightUnit
        self.feedingType = feedingType
        self.formulaBrand = formulaBrand
        self.formulaStage = formulaStage
        self.selectedBrandId = selectedBrandId
        self.selectedProductId = selectedProductId
        self.usesFormulaGuide = usesFormulaGuide
        self.customFormulaBrand = customFormulaBrand
        self.customFormulaProduct = customFormulaProduct
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    /// Age in days
    var ageInDays: Int {
        Calendar.current.dateComponents([.day], from: dateOfBirth, to: Date()).day ?? 0
    }
    
    /// Age in weeks
    var ageInWeeks: Int {
        Calendar.current.dateComponents([.weekOfYear], from: dateOfBirth, to: Date()).weekOfYear ?? 0
    }
    
    /// Age in months
    var ageInMonths: Int {
        Calendar.current.dateComponents([.month], from: dateOfBirth, to: Date()).month ?? 0
    }
    
    /// Formatted age string for display
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
    
    /// Weight in kg for display
    var weightInKg: Double? {
        guard let weight = currentWeight ?? birthWeight else { return nil }
        return weight / 1000.0
    }
}

// MARK: - Feeding Type
enum FeedingType: String, Codable, CaseIterable {
    case breast = "breast"
    case formula = "formula"
    case mixed = "mixed"
    
    var displayName: String {
        switch self {
        case .breast:
            return "Breast milk"
        case .formula:
            return "Formula"
        case .mixed:
            return "Mixed feeding"
        }
    }
    
    var icon: String {
        switch self {
        case .breast:
            return "heart.fill"
        case .formula:
            return "drop.fill"
        case .mixed:
            return "arrow.left.arrow.right"
        }
    }
}

// MARK: - Profile Status
// MARK: - Formula Stage
enum FormulaStage: String, Codable, CaseIterable {
    case newborn = "newborn"
    case stage1 = "stage1"
    case stage2 = "stage2"
    case stage3 = "stage3"
    case toddler = "toddler"
    
    var displayName: String {
        switch self {
        case .newborn:
            return "Newborn"
        case .stage1:
            return "Stage 1 (0–6 months)"
        case .stage2:
            return "Stage 2 (6–12 months)"
        case .stage3:
            return "Stage 3 (1–2 years)"
        case .toddler:
            return "Toddler (2+ years)"
        }
    }
}

enum ProfileSetupStatus {
    case notStarted
    case needsOnboarding
    case complete
}
