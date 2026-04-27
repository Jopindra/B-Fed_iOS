import Foundation
import SwiftData

// MARK: - Onboarding View Model
/// Centralised state and logic for the onboarding flow.
/// Extracted from the view layer for testability.
@Observable
class OnboardingViewModel {
    // MARK: Form State
    var parentName: String = ""
    var parentEmail: String = ""
    var country: String = ""
    var countryCode: String = ""
    var babyName: String = ""
    var babyDOB: Date = Date()
    var feedingType: String = ""
    var formulaBrand: String = ""
    var formulaStage: String = ""
    var birthWeight: String = ""
    var currentWeight: String = ""
    var weightUnit: String = "kg"
    var currentStep: Int = 0
    var showingValidationErrors: Bool = false
    
    // MARK: - Formula Setup
    var formulaSetupViewModel = FormulaSetupViewModel()
    
    var showsFormulaSetup: Bool {
        let type = feedingType.lowercased()
        return type == "formula" || type == "both"
    }
    
    var totalSteps: Int {
        showsFormulaSetup ? 10 : 7
    }

    // MARK: Computed Validation

    var isEmailValid: Bool {
        OnboardingValidation.isValidEmail(parentEmail)
    }

    var hasFeedingSelection: Bool {
        !feedingType.isEmpty
    }

    var isKg: Bool {
        weightUnit == "kg"
    }

    // MARK: Step-specific continue enabled states

    func isContinueEnabled(forStep step: Int) -> Bool {
        switch step {
        case 1: return !parentName.isEmpty
        case 2: return isEmailValid
        case 3: return !country.isEmpty
        case 4: return !babyName.isEmpty
        case 5: return true
        case 6: return hasFeedingSelection
        case 7: return true
        default: return true
        }
    }

    // MARK: Navigation

    func advanceToStep(_ step: Int) {
        showingValidationErrors = false
        currentStep = step
    }

    func goBackToStep(_ step: Int) {
        showingValidationErrors = false
        currentStep = step
    }

    func reset() {
        parentName = ""
        parentEmail = ""
        country = ""
        countryCode = ""
        babyName = ""
        babyDOB = Date()
        feedingType = ""
        formulaBrand = ""
        formulaStage = ""
        birthWeight = ""
        currentWeight = ""
        weightUnit = "kg"
        currentStep = 0
        showingValidationErrors = false
        formulaSetupViewModel.reset()
    }

    // MARK: Profile Creation

    func createProfile() -> BabyProfile {
        let mappedFeedingType: FeedingType
        switch feedingType.lowercased() {
        case "breast": mappedFeedingType = .breast
        case "formula": mappedFeedingType = .formula
        case "both": mappedFeedingType = .mixed
        default: mappedFeedingType = .formula
        }

        let birthWeightGrams = isKg
            ? Double(birthWeight).map { $0 * 1000 }
            : nil

        let currentWeightGrams = isKg
            ? Double(currentWeight).map { $0 * 1000 }
            : nil

        let parentDOB = Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date()
        
        let stageEnum = FormulaStage(rawValue: formulaStage)
        let brand = formulaBrand.isEmpty ? nil : formulaBrand
        
        // Formula Library profile
        let formulaProfile = formulaSetupViewModel.buildFormulaProfile()

        return BabyProfile(
            parentName: parentName,
            parentEmail: parentEmail,
            parentDOB: parentDOB,
            country: country,
            countryCode: countryCode,
            babyName: babyName.isEmpty ? "Baby" : babyName,
            dateOfBirth: babyDOB,
            birthWeight: birthWeightGrams,
            currentWeight: currentWeightGrams,
            feedingType: mappedFeedingType,
            formulaBrand: brand ?? formulaProfile.customFormulaBrand ?? formulaProfile.displayBrandName,
            formulaStage: stageEnum ?? formulaProfile.selectedStage,
            selectedBrandId: formulaProfile.selectedBrandId,
            selectedProductId: formulaProfile.selectedProductId,
            usesFormulaGuide: formulaProfile.usesFormulaGuide,
            customFormulaBrand: formulaProfile.customFormulaBrand,
            customFormulaProduct: formulaProfile.customFormulaProduct
        )
    }

    // MARK: Pre-fill for testing / preview

    func prefillWithSampleData() {
        parentName = "Sarah"
        parentEmail = "sarah@example.com"
        country = "Australia"
        countryCode = "AU"
        babyName = "Lily"
        babyDOB = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        feedingType = "formula"
        formulaBrand = ""
        formulaStage = ""
        birthWeight = "3.4"
        currentWeight = "4.2"
        weightUnit = "kg"
        formulaSetupViewModel.countryCode = "AU"
        formulaSetupViewModel.feedingType = .formula
    }
}
