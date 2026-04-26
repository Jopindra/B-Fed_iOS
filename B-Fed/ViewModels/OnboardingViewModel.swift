import Foundation
import SwiftData

// MARK: - Onboarding View Model
/// Centralised state and logic for the onboarding flow.
/// Extracted from the view layer for testability.
@MainActor
@Observable
class OnboardingViewModel {
    // MARK: Form State
    var parentName: String = ""
    var parentEmail: String = ""
    var country: String = ""
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

        return BabyProfile(
            parentName: parentName,
            parentEmail: parentEmail,
            parentDOB: parentDOB,
            country: country,
            babyName: babyName.isEmpty ? "Baby" : babyName,
            dateOfBirth: babyDOB,
            birthWeight: birthWeightGrams,
            currentWeight: currentWeightGrams,
            feedingType: mappedFeedingType,
            formulaBrand: brand,
            formulaStage: stageEnum
        )
    }

    // MARK: Pre-fill for testing / preview

    func prefillWithSampleData() {
        parentName = "Sarah"
        parentEmail = "sarah@example.com"
        country = "Australia"
        babyName = "Lily"
        babyDOB = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        feedingType = "breast"
        formulaBrand = ""
        formulaStage = ""
        birthWeight = "3.4"
        currentWeight = "4.2"
        weightUnit = "kg"
    }
}
