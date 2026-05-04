import Foundation

// MARK: - Formula Model
struct Formula: Identifiable, Hashable {
    let id: UUID
    let brand: String
    let name: String
    let stage: String
    let scoopsPerOz: Double
    let mlPerScoop: Double
    let powderGramsPerScoop: Double
    let maxHoursAtRoomTemp: Int
    let maxHoursInFridge: Int
    let ageRangeMonths: String
    let notes: String
    let isCustom: Bool
    
    var displayName: String { "\(brand) \(name)" }
    var fullDisplayName: String { "\(brand) \(name) \(stage)" }
}

// MARK: - Formula Service
struct FormulaService {
    
    static let standardMlPerScoop: Double = 30
    static let standardScoopsPerOz: Double = 1
    static let standardPowderGramsPerScoop: Double = 7.5
    
    // MARK: - Database
    static let allFormulas: [Formula] = [
        // Aptamil
        Formula(
            id: UUID(),
            brand: "Aptamil",
            name: "Gold+",
            stage: "Stage 1",
            scoopsPerOz: 1,
            mlPerScoop: 30,
            powderGramsPerScoop: 7.5,
            maxHoursAtRoomTemp: 2,
            maxHoursInFridge: 24,
            ageRangeMonths: "0–6 months",
            notes: "Follow tin instructions for exact scoop weight.",
            isCustom: false
        ),
        Formula(
            id: UUID(),
            brand: "Aptamil",
            name: "Gold+",
            stage: "Stage 2",
            scoopsPerOz: 1,
            mlPerScoop: 30,
            powderGramsPerScoop: 7.5,
            maxHoursAtRoomTemp: 2,
            maxHoursInFridge: 24,
            ageRangeMonths: "6–12 months",
            notes: "Follow tin instructions for exact scoop weight.",
            isCustom: false
        ),
        
        // Karicare
        Formula(
            id: UUID(),
            brand: "Karicare",
            name: "Plus",
            stage: "Stage 1",
            scoopsPerOz: 1,
            mlPerScoop: 30,
            powderGramsPerScoop: 7.3,
            maxHoursAtRoomTemp: 2,
            maxHoursInFridge: 24,
            ageRangeMonths: "0–6 months",
            notes: "Follow tin instructions for exact scoop weight.",
            isCustom: false
        ),
        Formula(
            id: UUID(),
            brand: "Karicare",
            name: "Plus",
            stage: "Stage 2",
            scoopsPerOz: 1,
            mlPerScoop: 30,
            powderGramsPerScoop: 7.3,
            maxHoursAtRoomTemp: 2,
            maxHoursInFridge: 24,
            ageRangeMonths: "6–12 months",
            notes: "Follow tin instructions for exact scoop weight.",
            isCustom: false
        ),
        
        // Nan Comfort
        Formula(
            id: UUID(),
            brand: "Nan",
            name: "Comfort",
            stage: "1",
            scoopsPerOz: 1,
            mlPerScoop: 30,
            powderGramsPerScoop: 7.3,
            maxHoursAtRoomTemp: 2,
            maxHoursInFridge: 24,
            ageRangeMonths: "0–6 months",
            notes: "Follow tin instructions for exact scoop weight.",
            isCustom: false
        ),
        Formula(
            id: UUID(),
            brand: "Nan",
            name: "Comfort",
            stage: "2",
            scoopsPerOz: 1,
            mlPerScoop: 30,
            powderGramsPerScoop: 7.3,
            maxHoursAtRoomTemp: 2,
            maxHoursInFridge: 24,
            ageRangeMonths: "6–12 months",
            notes: "Follow tin instructions for exact scoop weight.",
            isCustom: false
        ),
        
        // S26 Gold
        Formula(
            id: UUID(),
            brand: "S-26",
            name: "Gold",
            stage: "Stage 1",
            scoopsPerOz: 1,
            mlPerScoop: 30,
            powderGramsPerScoop: 7.5,
            maxHoursAtRoomTemp: 2,
            maxHoursInFridge: 24,
            ageRangeMonths: "0–6 months",
            notes: "Follow tin instructions for exact scoop weight.",
            isCustom: false
        ),
        Formula(
            id: UUID(),
            brand: "S-26",
            name: "Gold",
            stage: "Stage 2",
            scoopsPerOz: 1,
            mlPerScoop: 30,
            powderGramsPerScoop: 7.5,
            maxHoursAtRoomTemp: 2,
            maxHoursInFridge: 24,
            ageRangeMonths: "6–12 months",
            notes: "Follow tin instructions for exact scoop weight.",
            isCustom: false
        ),
        
        // Bellamy's Organic
        Formula(
            id: UUID(),
            brand: "Bellamy's",
            name: "Organic",
            stage: "Stage 1",
            scoopsPerOz: 1,
            mlPerScoop: 30,
            powderGramsPerScoop: 7.5,
            maxHoursAtRoomTemp: 2,
            maxHoursInFridge: 24,
            ageRangeMonths: "0–6 months",
            notes: "Follow tin instructions for exact scoop weight.",
            isCustom: false
        ),
        Formula(
            id: UUID(),
            brand: "Bellamy's",
            name: "Organic",
            stage: "Stage 2",
            scoopsPerOz: 1,
            mlPerScoop: 30,
            powderGramsPerScoop: 7.5,
            maxHoursAtRoomTemp: 2,
            maxHoursInFridge: 24,
            ageRangeMonths: "6–12 months",
            notes: "Follow tin instructions for exact scoop weight.",
            isCustom: false
        ),
    ]
    
    // MARK: - Custom Formula
    static func customFormula(name: String) -> Formula {
        Formula(
            id: UUID(),
            brand: "",
            name: name,
            stage: "",
            scoopsPerOz: standardScoopsPerOz,
            mlPerScoop: standardMlPerScoop,
            powderGramsPerScoop: standardPowderGramsPerScoop,
            maxHoursAtRoomTemp: 2,
            maxHoursInFridge: 24,
            ageRangeMonths: "",
            notes: "Follow the instructions on your formula tin.",
            isCustom: true
        )
    }
    
    // MARK: - Search
    static func searchFormulas(query: String) -> [Formula] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return allFormulas }
        let lower = trimmed.lowercased()
        return allFormulas.filter {
            $0.brand.lowercased().contains(lower) ||
            $0.name.lowercased().contains(lower) ||
            $0.stage.lowercased().contains(lower)
        }
    }
    
    // MARK: - Grouped by Brand
    static var formulasByBrand: [(brand: String, formulas: [Formula])] {
        let grouped = Dictionary(grouping: allFormulas) { $0.brand }
        return grouped.keys.sorted().map { brand in
            (brand, grouped[brand]!.sorted { $0.stage < $1.stage })
        }
    }
    
    // MARK: - Preparation Guidance
    static func scoopsForVolume(_ ml: Double, formula: Formula) -> Int {
        guard formula.mlPerScoop > 0 else { return 0 }
        return Int(round(ml / formula.mlPerScoop))
    }
    
    static func preparationSteps(volumeMl: Double, formula: Formula) -> [String] {
        let scoops = scoopsForVolume(volumeMl, formula: formula)
        return [
            "Boil fresh water, then let it cool. Your formula tin will tell you the right temperature.",
            "Pour \(Int(volumeMl))ml of water into a sterilised bottle",
            "Add \(scoops) level scoop\(scoops == 1 ? "" : "s") of \(formula.fullDisplayName)",
            "Mix gently until the powder has dissolved",
            "Cool under running water before feeding"
        ]
    }
    
    static func quickScoopGuide(formula: Formula) -> [(ml: Int, scoops: Int)] {
        [60, 90, 120, 150, 180, 210].map { ml in
            (ml, scoopsForVolume(Double(ml), formula: formula))
        }
    }
    
    // MARK: - Storage Guidance
    static func storageGuidance(formula: Formula) -> (roomTemp: String, fridge: String, warnings: [String]) {
        (
            roomTemp: "Use within \(formula.maxHoursAtRoomTemp) hours",
            fridge: "Use within \(formula.maxHoursInFridge) hours",
            warnings: [
                "Do not reheat a bottle twice",
                "Do not keep leftover milk from a feed"
            ]
        )
    }
}

// MARK: - Selected Formula Store
/// Lightweight observable store for the currently selected formula in the log flow.
@Observable
class SelectedFormulaStore {
    var selectedFormula: Formula?
    
    func select(_ formula: Formula) {
        selectedFormula = formula
    }
    
    func clear() {
        selectedFormula = nil
    }
}
