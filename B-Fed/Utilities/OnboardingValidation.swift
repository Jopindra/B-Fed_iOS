import Foundation

// MARK: - Onboarding Validation
/// Pure validation functions for onboarding form fields.
/// Stateless and testable — no UI dependencies.
enum OnboardingValidation {

    /// Validates that a name field is non-empty after trimming.
    static func isValidName(_ name: String) -> Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Validates that a country has been selected.
    static func isValidCountry(_ country: String) -> Bool {
        !country.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Validates that a weight string can be parsed as a positive number.
    static func isValidWeight(_ weight: String) -> Bool {
        guard let value = Double(weight.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            return false
        }
        return value > 0
    }

    /// Validates that a feeding type string is one of the accepted values.
    static func isValidFeedingType(_ feedingType: String) -> Bool {
        ["breast", "formula", "both"].contains(feedingType.lowercased())
    }

    /// Validates that a date of birth is not in the future.
    static func isValidDateOfBirth(_ date: Date) -> Bool {
        date <= Date()
    }

    /// Comprehensive validation for the entire onboarding form.
    /// Returns an array of error messages for invalid fields.
    static func validateOnboardingForm(
        parentName: String,
        country: String,
        babyName: String,
        babyDOB: Date,
        feedingType: String
    ) -> [String] {
        var errors: [String] = []

        if !isValidName(parentName) {
            errors.append("Please enter your name")
        }

        if !isValidCountry(country) {
            errors.append("Please select your country")
        }

        if !isValidName(babyName) {
            errors.append("Please enter your baby's name")
        }

        if !isValidDateOfBirth(babyDOB) {
            errors.append("Date of birth cannot be in the future")
        }

        if !isValidFeedingType(feedingType) {
            errors.append("Please select a feeding method")
        }

        return errors
    }
}
