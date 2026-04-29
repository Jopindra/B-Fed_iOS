import Foundation

// MARK: - Formula Stage Service
/// Recommends the appropriate formula stage based on the baby's age in months.
struct FormulaStageService {

    static func recommendedStage(for dob: Date) -> FormulaStage {
        let months = ageInMonths(from: dob)

        switch months {
        case 0..<6:
            return .stage1
        case 6..<12:
            return .stage2
        case 12..<24:
            return .stage3
        default:
            return .toddler
        }
    }

    static func stageLabel(for dob: Date) -> String {
        let months = ageInMonths(from: dob)

        switch months {
        case 0..<6:
            return "Stage 1 (0–6 months)"
        case 6..<12:
            return "Stage 2 (6–12 months)"
        case 12..<24:
            return "Stage 3 (12–24 months)"
        default:
            return "Toddler formula (24+ months)"
        }
    }

    static func stageExplanation(for dob: Date, babyName: String) -> String {
        let months = ageInMonths(from: dob)

        switch months {
        case 0..<6:
            return "\(babyName) is \(months) month\(months == 1 ? "" : "s") old. Stage 1 is designed for newborns from birth to 6 months."
        case 6..<12:
            return "\(babyName) is \(months) months old. Stage 2 is suitable from 6 months."
        case 12..<24:
            return "\(babyName) is \(months) months old. Stage 3 is suitable from 12 months."
        default:
            let years = months / 12
            return "\(babyName) is \(years) year\(years == 1 ? "" : "s") old. Toddler formula is suitable from 24 months."
        }
    }

    static func ageInMonths(from dob: Date) -> Int {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.month], from: dob, to: now)
        return max(0, components.month ?? 0)
    }
}
