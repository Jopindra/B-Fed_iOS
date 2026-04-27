import Foundation

// MARK: - Formula Guidance Result
/// Gentle, non-medical feeding guidance based on baby age and weight.
struct FormulaGuidanceResult {
    let suggestedDailyMin: Int
    let suggestedDailyMax: Int
    let estimatedFeedSizeMin: Int
    let estimatedFeedSizeMax: Int
    let estimatedFeedsPerDay: ClosedRange<Int>
    let applicableStageLabel: String
    let explanationText: String
    let disclaimerText: String
    let weightBased: Bool
}

// MARK: - Formula Guidance Service
/// Rules-based feeding guidance. No machine learning.
///
/// TODO: Add country-specific guideline overrides.
/// TODO: Add remote config for ml/kg values.
/// TODO: Move to backend/API for guideline updates.
enum FormulaGuidanceService {
    
    static let standardDisclaimer = "Formula amounts vary between babies. Use this as a guide only. Always follow the instructions on your formula tin and speak with your doctor, midwife or child health nurse if you have concerns."
    
    static let specialistWarning = "Specialist formulas are for specific feeding needs and should be used with health professional guidance."
    
    // MARK: - Brand Lookup
    
    static func brands(forCountryCode code: String) -> [FormulaBrand] {
        let priorities = FormulaSeedData.countryBrandPriorities
            .filter { $0.countryCode == code }
            .sorted { $0.priorityRank < $1.priorityRank }
        
        let brandIds = priorities.map { $0.brandId }
        let brandMap = Dictionary(uniqueKeysWithValues: FormulaSeedData.brands.map { ($0.id, $0) })
        
        return brandIds.compactMap { brandMap[$0] }
    }
    
    // MARK: - Product Lookup
    
    static func products(forBrandId brandId: String, countryCode: String) -> [FormulaProduct] {
        FormulaSeedData.products
            .filter { $0.brandId == brandId && $0.countryCode == countryCode }
            .sorted { $0.minAgeMonths < $1.minAgeMonths }
    }
    
    static func product(byId id: String) -> FormulaProduct? {
        FormulaSeedData.products.first { $0.id == id }
    }
    
    // MARK: - Guidance Calculation
    
    static func guidance(for profile: BabyProfile) -> FormulaGuidanceResult {
        let ageMonths = profile.ageInMonths
        let ageDays = profile.ageInDays
        
        // Find applicable guideline
        let guideline = FormulaSeedData.guidelines.first { g in
            ageMonths >= g.minAgeMonths && (g.maxAgeMonths == nil || ageMonths < g.maxAgeMonths!)
        }
        
        // Determine stage label
        let stageLabel: String
        switch ageMonths {
        case 0..<6:
            stageLabel = "Stage 1 / Newborn"
        case 6..<12:
            stageLabel = "Stage 2 / Follow-on"
        case 12..<24:
            stageLabel = "Stage 3 / Toddler"
        default:
            stageLabel = "Toddler (2+ years)"
        }
        
        // Weight-based calculation (preferred)
        if let weightGrams = profile.currentWeight ?? profile.birthWeight {
            let weightKg = Double(weightGrams) / 1000.0
            let mlPerKgMin = guideline?.mlPerKgPerDayMin ?? 120
            let mlPerKgMax = guideline?.mlPerKgPerDayMax ?? 150
            
            let dailyMin = Int(weightKg * mlPerKgMin)
            let dailyMax = Int(weightKg * mlPerKgMax)
            
            let feedsMin = guideline?.feedsPerDayMin ?? 6
            let feedsMax = guideline?.feedsPerDayMax ?? 8
            
            let feedSizeMin = dailyMin / feedsMax
            let feedSizeMax = dailyMax / feedsMin
            
            let explanation: String
            if ageDays < 30 {
                explanation = "Based on general guidance for babies around \(ageDays) days old weighing about \(String(format: "%.2f", weightKg)) kg. Newborns feed little and often — every baby settles into their own rhythm."
            } else if ageMonths < 6 {
                explanation = "Based on general guidance for a \(ageMonths)-month-old baby weighing about \(String(format: "%.2f", weightKg)) kg. Every baby's appetite is different — trust their cues."
            } else {
                explanation = "Based on general guidance for a \(ageMonths)-month-old baby weighing about \(String(format: "%.2f", weightKg)) kg. As solids increase, formula intake naturally adjusts."
            }
            
            return FormulaGuidanceResult(
                suggestedDailyMin: dailyMin,
                suggestedDailyMax: dailyMax,
                estimatedFeedSizeMin: feedSizeMin,
                estimatedFeedSizeMax: feedSizeMax,
                estimatedFeedsPerDay: feedsMin...feedsMax,
                applicableStageLabel: stageLabel,
                explanationText: explanation,
                disclaimerText: standardDisclaimer,
                weightBased: true
            )
        }
        
        // Age-only fallback
        let (dailyMin, dailyMax, feedsMin, feedsMax): (Int, Int, Int, Int)
        
        switch ageDays {
        case 0...14:
            (dailyMin, dailyMax, feedsMin, feedsMax) = (300, 500, 8, 12)
        case 15...28:
            (dailyMin, dailyMax, feedsMin, feedsMax) = (400, 700, 7, 10)
        case 29...60:
            (dailyMin, dailyMax, feedsMin, feedsMax) = (500, 900, 6, 8)
        case 61...120:
            (dailyMin, dailyMax, feedsMin, feedsMax) = (600, 1000, 5, 7)
        case 121...180:
            (dailyMin, dailyMax, feedsMin, feedsMax) = (700, 1200, 4, 6)
        default:
            (dailyMin, dailyMax, feedsMin, feedsMax) = (600, 900, 3, 5)
        }
        
        let feedSizeMin = dailyMin / feedsMax
        let feedSizeMax = dailyMax / feedsMin
        
        let explanation: String
        if ageDays < 30 {
            explanation = "Based on general guidance for babies around \(ageDays) days old. For a more tailored estimate, add your baby's weight when you're ready."
        } else {
            explanation = "Based on general guidance for a \(ageMonths)-month-old baby. For a more tailored estimate, add your baby's weight when you're ready."
        }
        
        return FormulaGuidanceResult(
            suggestedDailyMin: dailyMin,
            suggestedDailyMax: dailyMax,
            estimatedFeedSizeMin: feedSizeMin,
            estimatedFeedSizeMax: feedSizeMax,
            estimatedFeedsPerDay: feedsMin...feedsMax,
            applicableStageLabel: stageLabel,
            explanationText: explanation,
            disclaimerText: standardDisclaimer,
            weightBased: false
        )
    }
    
    // MARK: - Stage Recommendation
    
    static func recommendedStage(for ageMonths: Int) -> FormulaStage? {
        switch ageMonths {
        case 0..<6:
            return .stage1
        case 6..<12:
            return .stage2
        case 12..<24:
            return .stage3
        case 24...:
            return .toddler
        default:
            return nil
        }
    }
}
