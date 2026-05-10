import SwiftUI
import SwiftData

// MARK: - Settings View Model
@MainActor
@Observable
final class SettingsViewModel {
    var babyName = ""
    var dateOfBirth: Date = Date()
    var weightKg: Double? = nil
    var weightUnit: String = "kg"
    var feedingType: FeedingType = .formula
    var formulaBrand = ""
    var formulaStage: FormulaStage?
    var country = ""
    var countryCode = ""
    var parentName = ""

    private var originalSnapshot: Snapshot?

    var showsFormulaFields: Bool {
        feedingType == .formula || feedingType == .mixed
    }

    var ageDescription: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: dateOfBirth, to: Date())
        let months = (components.year ?? 0) * 12 + (components.month ?? 0)
        let days = components.day ?? 0

        if months < 1 {
            let weeks = days / 7
            if weeks < 1 { return "Newborn" }
            return "\(weeks) week\(weeks == 1 ? "" : "s") old"
        } else if months < 24 {
            return "\(months) month\(months == 1 ? "" : "s") old"
        } else {
            let years = months / 12
            return "\(years) year\(years == 1 ? "" : "s") old"
        }
    }

    var stageDisplayName: String {
        formulaStage?.displayName ?? "Not specified"
    }

    var weightDisplayString: String {
        guard let kg = weightKg else { return "Not set" }
        if weightUnit == "kg" {
            return String(format: "%.1f kg", kg)
        } else {
            let totalLb = kg * 2.20462
            let lb = Int(totalLb)
            let oz = Int(round((totalLb - Double(lb)) * 16))
            return "\(lb) lb \(oz) oz"
        }
    }

    var hasChanges: Bool {
        guard let orig = originalSnapshot else { return false }
        return babyName != orig.babyName
            || !Calendar.current.isDate(dateOfBirth, inSameDayAs: orig.dateOfBirth)
            || weightKg != orig.weightKg
            || weightUnit != orig.weightUnit
            || feedingType != orig.feedingType
            || formulaBrand != orig.formulaBrand
            || formulaStage != orig.formulaStage
            || country != orig.country
            || countryCode != orig.countryCode
            || parentName != orig.parentName
    }

    func load(from profile: BabyProfile?) {
        guard let profile = profile else {
            babyName = ""
            dateOfBirth = Date()
            weightKg = nil
            weightUnit = "kg"
            feedingType = .formula
            formulaBrand = ""
            formulaStage = nil
            country = ""
            countryCode = ""
            parentName = ""
            originalSnapshot = nil
            return
        }
        babyName = profile.babyName
        dateOfBirth = profile.dateOfBirth
        feedingType = profile.feedingType
        formulaBrand = profile.formulaBrand ?? ""
        formulaStage = profile.formulaStage
        country = profile.country
        countryCode = profile.countryCode
        parentName = profile.parentName

        weightKg = profile.weightInKg
        weightUnit = profile.weightUnit

        originalSnapshot = Snapshot(
            babyName: babyName,
            dateOfBirth: dateOfBirth,
            weightKg: weightKg,
            weightUnit: weightUnit,
            feedingType: feedingType,
            formulaBrand: formulaBrand,
            formulaStage: formulaStage,
            country: country,
            countryCode: countryCode,
            parentName: parentName
        )
    }

    func save(to feedStore: FeedStore) {
        let weightGrams = weightKg.map { $0 * 1000 }
        let brand = formulaBrand.isEmpty ? nil : formulaBrand
        let countryValue = country.isEmpty ? nil : country
        let countryCodeValue = countryCode.isEmpty ? nil : countryCode

        feedStore.updateBabyProfile(
            babyName: babyName,
            feedingType: feedingType,
            formulaBrand: brand,
            formulaStage: showsFormulaFields ? formulaStage : nil,
            currentWeight: weightGrams,
            weightUnit: weightUnit,
            country: countryValue,
            countryCode: countryCodeValue,
            dateOfBirth: dateOfBirth,
            parentName: parentName
        )
    }

    private struct Snapshot {
        let babyName: String
        let dateOfBirth: Date
        let weightKg: Double?
        let weightUnit: String
        let feedingType: FeedingType
        let formulaBrand: String
        let formulaStage: FormulaStage?
        let country: String
        let countryCode: String
        let parentName: String
    }
}
