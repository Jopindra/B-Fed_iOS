import Foundation

// MARK: - Formula Seed Data
/// Local, curated formula data for the initial launch.
///
/// TODO: Move to backend/API for remote updates.
/// TODO: Add verified source URLs for each product.
/// TODO: Add audit/review dates for formula database freshness.
/// TODO: Add barcode scanning support (EAN/UPC codes).
/// TODO: Add remote config for formula product availability.
/// TODO: Add parent preference / most-used sorting.
enum FormulaSeedData {
    
    // MARK: - Countries
    static let countries: [Country] = [
        Country(id: "AU", countryCode: "AU", name: "Australia"),
        Country(id: "GB", countryCode: "GB", name: "United Kingdom"),
        Country(id: "US", countryCode: "US", name: "United States"),
        Country(id: "NZ", countryCode: "NZ", name: "New Zealand"),
        Country(id: "CA", countryCode: "CA", name: "Canada")
    ]
    
    // MARK: - Brands
    static let brands: [FormulaBrand] = [
        // Australia
        FormulaBrand(id: "aptamil", name: "Aptamil", manufacturer: "Danone Nutricia", websiteURL: "https://www.aptamil.com.au", isActive: true),
        FormulaBrand(id: "karicare", name: "Karicare", manufacturer: "Danone Nutricia", websiteURL: "https://www.karicare.com.au", isActive: true),
        FormulaBrand(id: "nan", name: "NAN", manufacturer: "Nestlé", websiteURL: "https://www.nestle.com.au", isActive: true),
        FormulaBrand(id: "s26", name: "S-26 / Alula", manufacturer: "Aspen Pharmacare", websiteURL: nil, isActive: true),
        FormulaBrand(id: "bubs", name: "Bubs", manufacturer: "Bubs Australia", websiteURL: "https://www.bubs.com.au", isActive: true),
        FormulaBrand(id: "a2platinum", name: "A2 Platinum", manufacturer: "The a2 Milk Company", websiteURL: "https://www.a2milk.com.au", isActive: true),
        
        // United Kingdom
        FormulaBrand(id: "cowgate", name: "Cow & Gate", manufacturer: "Danone Nutricia", websiteURL: "https://www.cowandgate.co.uk", isActive: true),
        FormulaBrand(id: "sma", name: "SMA", manufacturer: "Nestlé", websiteURL: "https://www.smababy.co.uk", isActive: true),
        FormulaBrand(id: "kendamil", name: "Kendamil", manufacturer: "Kendal Nutricare", websiteURL: "https://www.kendamil.com", isActive: true),
        FormulaBrand(id: "hipp", name: "HiPP Organic", manufacturer: "HiPP", websiteURL: "https://www.hipp.co.uk", isActive: true),
        FormulaBrand(id: "mamia", name: "Mamia", manufacturer: "Aldi", websiteURL: nil, isActive: true),
        
        // United States
        FormulaBrand(id: "similac", name: "Similac", manufacturer: "Abbott", websiteURL: "https://www.similac.com", isActive: true),
        FormulaBrand(id: "enfamil", name: "Enfamil", manufacturer: "Reckitt", websiteURL: "https://www.enfamil.com", isActive: true),
        FormulaBrand(id: "gerber", name: "Gerber / Good Start", manufacturer: "Nestlé", websiteURL: "https://www.gerber.com", isActive: true),
        FormulaBrand(id: "bobbie", name: "Bobbie", manufacturer: "Bobbie Baby", websiteURL: "https://www.hibobbie.com", isActive: true),
        FormulaBrand(id: "byheart", name: "ByHeart", manufacturer: "ByHeart", websiteURL: "https://www.byheart.com", isActive: true),
        
        // New Zealand (overlaps with AU for some brands)
        // Canada
        FormulaBrand(id: "goodstart_ca", name: "Good Start", manufacturer: "Nestlé", websiteURL: "https://www.goodstart.ca", isActive: true),
        FormulaBrand(id: "nestle_nan_ca", name: "Nestlé NAN", manufacturer: "Nestlé", websiteURL: nil, isActive: true)
    ]
    
    // MARK: - Country Brand Priorities
    static let countryBrandPriorities: [CountryBrandPriority] = [
        // Australia
        CountryBrandPriority(countryCode: "AU", brandId: "aptamil", priorityRank: 1, notes: "Widely available"),
        CountryBrandPriority(countryCode: "AU", brandId: "karicare", priorityRank: 2, notes: "Widely available"),
        CountryBrandPriority(countryCode: "AU", brandId: "nan", priorityRank: 3, notes: nil),
        CountryBrandPriority(countryCode: "AU", brandId: "s26", priorityRank: 4, notes: nil),
        CountryBrandPriority(countryCode: "AU", brandId: "bubs", priorityRank: 5, notes: "Growing popularity"),
        CountryBrandPriority(countryCode: "AU", brandId: "a2platinum", priorityRank: 6, notes: nil),
        
        // United Kingdom
        CountryBrandPriority(countryCode: "GB", brandId: "aptamil", priorityRank: 1, notes: "Market leader"),
        CountryBrandPriority(countryCode: "GB", brandId: "cowgate", priorityRank: 2, notes: nil),
        CountryBrandPriority(countryCode: "GB", brandId: "sma", priorityRank: 3, notes: nil),
        CountryBrandPriority(countryCode: "GB", brandId: "kendamil", priorityRank: 4, notes: "Growing"),
        CountryBrandPriority(countryCode: "GB", brandId: "hipp", priorityRank: 5, notes: nil),
        CountryBrandPriority(countryCode: "GB", brandId: "mamia", priorityRank: 6, notes: "Budget option"),
        
        // United States
        CountryBrandPriority(countryCode: "US", brandId: "similac", priorityRank: 1, notes: nil),
        CountryBrandPriority(countryCode: "US", brandId: "enfamil", priorityRank: 2, notes: nil),
        CountryBrandPriority(countryCode: "US", brandId: "gerber", priorityRank: 3, notes: nil),
        CountryBrandPriority(countryCode: "US", brandId: "bobbie", priorityRank: 4, notes: "Organic"),
        CountryBrandPriority(countryCode: "US", brandId: "kendamil", priorityRank: 5, notes: "European style"),
        CountryBrandPriority(countryCode: "US", brandId: "byheart", priorityRank: 6, notes: "Whole milk based"),
        
        // New Zealand
        CountryBrandPriority(countryCode: "NZ", brandId: "karicare", priorityRank: 1, notes: nil),
        CountryBrandPriority(countryCode: "NZ", brandId: "aptamil", priorityRank: 2, notes: nil),
        CountryBrandPriority(countryCode: "NZ", brandId: "s26", priorityRank: 3, notes: nil),
        CountryBrandPriority(countryCode: "NZ", brandId: "a2platinum", priorityRank: 4, notes: nil),
        CountryBrandPriority(countryCode: "NZ", brandId: "nan", priorityRank: 5, notes: nil),
        
        // Canada
        CountryBrandPriority(countryCode: "CA", brandId: "enfamil", priorityRank: 1, notes: nil),
        CountryBrandPriority(countryCode: "CA", brandId: "similac", priorityRank: 2, notes: nil),
        CountryBrandPriority(countryCode: "CA", brandId: "goodstart_ca", priorityRank: 3, notes: nil),
        CountryBrandPriority(countryCode: "CA", brandId: "nestle_nan_ca", priorityRank: 4, notes: nil),
        CountryBrandPriority(countryCode: "CA", brandId: "kendamil", priorityRank: 5, notes: nil)
    ]
    
    // MARK: - Products
    static let products: [FormulaProduct] = [
        // Aptamil (AU)
        FormulaProduct(id: "aptamil-au-gold-1", brandId: "aptamil", countryCode: "AU", productName: "Gold+ Stage 1", formulaType: .standard, stage: .stage1, minAgeMonths: 0, maxAgeMonths: 6, milkBase: "Cow", isSpecialist: false, requiresMedicalAdvice: false, preparationNotes: "Follow tin instructions. Use cooled boiled water.", sourceURL: nil, lastVerifiedAt: nil),
        FormulaProduct(id: "aptamil-au-gold-2", brandId: "aptamil", countryCode: "AU", productName: "Gold+ Stage 2", formulaType: .standard, stage: .stage2, minAgeMonths: 6, maxAgeMonths: 12, milkBase: "Cow", isSpecialist: false, requiresMedicalAdvice: false, preparationNotes: nil, sourceURL: nil, lastVerifiedAt: nil),
        FormulaProduct(id: "aptamil-au-gold-3", brandId: "aptamil", countryCode: "AU", productName: "Gold+ Stage 3", formulaType: .standard, stage: .stage3, minAgeMonths: 12, maxAgeMonths: 24, milkBase: "Cow", isSpecialist: false, requiresMedicalAdvice: false, preparationNotes: nil, sourceURL: nil, lastVerifiedAt: nil),
        FormulaProduct(id: "aptamil-au-ha", brandId: "aptamil", countryCode: "AU", productName: "HA (Hypoallergenic)", formulaType: .specialist, stage: .stage1, minAgeMonths: 0, maxAgeMonths: 12, milkBase: "Cow", isSpecialist: true, requiresMedicalAdvice: true, preparationNotes: "Partially hydrolysed. Consult health professional.", sourceURL: nil, lastVerifiedAt: nil),
        
        // Karicare (AU)
        FormulaProduct(id: "karicare-au-1", brandId: "karicare", countryCode: "AU", productName: "First Infant Milk", formulaType: .standard, stage: .stage1, minAgeMonths: 0, maxAgeMonths: 6, milkBase: "Cow", isSpecialist: false, requiresMedicalAdvice: false, preparationNotes: nil, sourceURL: nil, lastVerifiedAt: nil),
        FormulaProduct(id: "karicare-au-goat-1", brandId: "karicare", countryCode: "AU", productName: "Goat Milk Stage 1", formulaType: .goat, stage: .stage1, minAgeMonths: 0, maxAgeMonths: 6, milkBase: "Goat", isSpecialist: false, requiresMedicalAdvice: false, preparationNotes: nil, sourceURL: nil, lastVerifiedAt: nil),
        
        // NAN (AU)
        FormulaProduct(id: "nan-au-pro-1", brandId: "nan", countryCode: "AU", productName: "Optipro Stage 1", formulaType: .standard, stage: .stage1, minAgeMonths: 0, maxAgeMonths: 6, milkBase: "Cow", isSpecialist: false, requiresMedicalAdvice: false, preparationNotes: nil, sourceURL: nil, lastVerifiedAt: nil),
        FormulaProduct(id: "nan-au-pro-2", brandId: "nan", countryCode: "AU", productName: "Optipro Stage 2", formulaType: .standard, stage: .stage2, minAgeMonths: 6, maxAgeMonths: 12, milkBase: "Cow", isSpecialist: false, requiresMedicalAdvice: false, preparationNotes: nil, sourceURL: nil, lastVerifiedAt: nil),
        
        // S-26 / Alula (AU)
        FormulaProduct(id: "s26-au-1", brandId: "s26", countryCode: "AU", productName: "Original Stage 1", formulaType: .standard, stage: .stage1, minAgeMonths: 0, maxAgeMonths: 6, milkBase: "Cow", isSpecialist: false, requiresMedicalAdvice: false, preparationNotes: nil, sourceURL: nil, lastVerifiedAt: nil),
        FormulaProduct(id: "s26-au-2", brandId: "s26", countryCode: "AU", productName: "Original Stage 2", formulaType: .standard, stage: .stage2, minAgeMonths: 6, maxAgeMonths: 12, milkBase: "Cow", isSpecialist: false, requiresMedicalAdvice: false, preparationNotes: nil, sourceURL: nil, lastVerifiedAt: nil),
        
        // Bubs (AU)
        FormulaProduct(id: "bubs-au-organic-1", brandId: "bubs", countryCode: "AU", productName: "Organic Grass Fed Stage 1", formulaType: .organic, stage: .stage1, minAgeMonths: 0, maxAgeMonths: 6, milkBase: "Cow", isSpecialist: false, requiresMedicalAdvice: false, preparationNotes: nil, sourceURL: nil, lastVerifiedAt: nil),
        FormulaProduct(id: "bubs-au-goat-1", brandId: "bubs", countryCode: "AU", productName: "Goat Milk Stage 1", formulaType: .goat, stage: .stage1, minAgeMonths: 0, maxAgeMonths: 6, milkBase: "Goat", isSpecialist: false, requiresMedicalAdvice: false, preparationNotes: nil, sourceURL: nil, lastVerifiedAt: nil),
        
        // A2 Platinum (AU)
        FormulaProduct(id: "a2-au-1", brandId: "a2platinum", countryCode: "AU", productName: "Premium Stage 1", formulaType: .standard, stage: .stage1, minAgeMonths: 0, maxAgeMonths: 6, milkBase: "A2 Cow", isSpecialist: false, requiresMedicalAdvice: false, preparationNotes: nil, sourceURL: nil, lastVerifiedAt: nil),
        FormulaProduct(id: "a2-au-2", brandId: "a2platinum", countryCode: "AU", productName: "Premium Stage 2", formulaType: .standard, stage: .stage2, minAgeMonths: 6, maxAgeMonths: 12, milkBase: "A2 Cow", isSpecialist: false, requiresMedicalAdvice: false, preparationNotes: nil, sourceURL: nil, lastVerifiedAt: nil),
        
        // Aptamil (GB)
        FormulaProduct(id: "aptamil-gb-1", brandId: "aptamil", countryCode: "GB", productName: "First Infant Milk", formulaType: .standard, stage: .stage1, minAgeMonths: 0, maxAgeMonths: 6, milkBase: "Cow", isSpecialist: false, requiresMedicalAdvice: false, preparationNotes: nil, sourceURL: nil, lastVerifiedAt: nil),
        FormulaProduct(id: "aptamil-gb-2", brandId: "aptamil", countryCode: "GB", productName: "Follow On Milk", formulaType: .standard, stage: .stage2, minAgeMonths: 6, maxAgeMonths: 12, milkBase: "Cow", isSpecialist: false, requiresMedicalAdvice: false, preparationNotes: nil, sourceURL: nil, lastVerifiedAt: nil),
        
        // Cow & Gate (GB)
        FormulaProduct(id: "cowgate-gb-1", brandId: "cowgate", countryCode: "GB", productName: "First Infant Milk", formulaType: .standard, stage: .stage1, minAgeMonths: 0, maxAgeMonths: 6, milkBase: "Cow", isSpecialist: false, requiresMedicalAdvice: false, preparationNotes: nil, sourceURL: nil, lastVerifiedAt: nil),
        FormulaProduct(id: "cowgate-gb-2", brandId: "cowgate", countryCode: "GB", productName: "Follow On Milk", formulaType: .standard, stage: .stage2, minAgeMonths: 6, maxAgeMonths: 12, milkBase: "Cow", isSpecialist: false, requiresMedicalAdvice: false, preparationNotes: nil, sourceURL: nil, lastVerifiedAt: nil),
        
        // Kendamil (GB / US / CA)
        FormulaProduct(id: "kendamil-gb-1", brandId: "kendamil", countryCode: "GB", productName: "Classic First Milk", formulaType: .standard, stage: .stage1, minAgeMonths: 0, maxAgeMonths: 6, milkBase: "Whole cow", isSpecialist: false, requiresMedicalAdvice: false, preparationNotes: nil, sourceURL: nil, lastVerifiedAt: nil),
        FormulaProduct(id: "kendamil-gb-organic-1", brandId: "kendamil", countryCode: "GB", productName: "Organic First Milk", formulaType: .organic, stage: .stage1, minAgeMonths: 0, maxAgeMonths: 6, milkBase: "Whole cow", isSpecialist: false, requiresMedicalAdvice: false, preparationNotes: nil, sourceURL: nil, lastVerifiedAt: nil),
        FormulaProduct(id: "kendamil-us-1", brandId: "kendamil", countryCode: "US", productName: "Whole Milk Formula", formulaType: .standard, stage: .stage1, minAgeMonths: 0, maxAgeMonths: 6, milkBase: "Whole cow", isSpecialist: false, requiresMedicalAdvice: false, preparationNotes: nil, sourceURL: nil, lastVerifiedAt: nil),
        FormulaProduct(id: "kendamil-ca-1", brandId: "kendamil", countryCode: "CA", productName: "Classic First Milk", formulaType: .standard, stage: .stage1, minAgeMonths: 0, maxAgeMonths: 6, milkBase: "Whole cow", isSpecialist: false, requiresMedicalAdvice: false, preparationNotes: nil, sourceURL: nil, lastVerifiedAt: nil),
        
        // Similac (US / CA)
        FormulaProduct(id: "similac-us-pro-1", brandId: "similac", countryCode: "US", productName: "360 Total Care", formulaType: .standard, stage: .stage1, minAgeMonths: 0, maxAgeMonths: 12, milkBase: "Cow", isSpecialist: false, requiresMedicalAdvice: false, preparationNotes: nil, sourceURL: nil, lastVerifiedAt: nil),
        FormulaProduct(id: "similac-us-pro-sensitive", brandId: "similac", countryCode: "US", productName: "360 Total Care Sensitive", formulaType: .specialist, stage: .stage1, minAgeMonths: 0, maxAgeMonths: 12, milkBase: "Cow", isSpecialist: true, requiresMedicalAdvice: true, preparationNotes: "For fussiness and gas. Consult paediatrician.", sourceURL: nil, lastVerifiedAt: nil),
        FormulaProduct(id: "similac-ca-1", brandId: "similac", countryCode: "CA", productName: "Pro-Advance Stage 1", formulaType: .standard, stage: .stage1, minAgeMonths: 0, maxAgeMonths: 12, milkBase: "Cow", isSpecialist: false, requiresMedicalAdvice: false, preparationNotes: nil, sourceURL: nil, lastVerifiedAt: nil),
        
        // Enfamil (US / CA)
        FormulaProduct(id: "enfamil-us-neuro-1", brandId: "enfamil", countryCode: "US", productName: "NeuroPro", formulaType: .standard, stage: .stage1, minAgeMonths: 0, maxAgeMonths: 12, milkBase: "Cow", isSpecialist: false, requiresMedicalAdvice: false, preparationNotes: nil, sourceURL: nil, lastVerifiedAt: nil),
        FormulaProduct(id: "enfamil-us-gentlease", brandId: "enfamil", countryCode: "US", productName: "Gentlease", formulaType: .specialist, stage: .stage1, minAgeMonths: 0, maxAgeMonths: 12, milkBase: "Cow", isSpecialist: true, requiresMedicalAdvice: true, preparationNotes: "For easy digestion. Consult paediatrician.", sourceURL: nil, lastVerifiedAt: nil),
        FormulaProduct(id: "enfamil-ca-a-1", brandId: "enfamil", countryCode: "CA", productName: "A+", formulaType: .standard, stage: .stage1, minAgeMonths: 0, maxAgeMonths: 12, milkBase: "Cow", isSpecialist: false, requiresMedicalAdvice: false, preparationNotes: nil, sourceURL: nil, lastVerifiedAt: nil),
        
        // Bobbie (US)
        FormulaProduct(id: "bobbie-us-1", brandId: "bobbie", countryCode: "US", productName: "Organic Infant Formula", formulaType: .organic, stage: .stage1, minAgeMonths: 0, maxAgeMonths: 12, milkBase: "Cow", isSpecialist: false, requiresMedicalAdvice: false, preparationNotes: nil, sourceURL: nil, lastVerifiedAt: nil),
        
        // ByHeart (US)
        FormulaProduct(id: "byheart-us-1", brandId: "byheart", countryCode: "US", productName: "Whole Nutrition", formulaType: .standard, stage: .stage1, minAgeMonths: 0, maxAgeMonths: 12, milkBase: "Whole cow", isSpecialist: false, requiresMedicalAdvice: false, preparationNotes: nil, sourceURL: nil, lastVerifiedAt: nil),
        
        // Karicare (NZ)
        FormulaProduct(id: "karicare-nz-1", brandId: "karicare", countryCode: "NZ", productName: "Plus Stage 1", formulaType: .standard, stage: .stage1, minAgeMonths: 0, maxAgeMonths: 6, milkBase: "Cow", isSpecialist: false, requiresMedicalAdvice: false, preparationNotes: nil, sourceURL: nil, lastVerifiedAt: nil),
        FormulaProduct(id: "karicare-nz-goat-1", brandId: "karicare", countryCode: "NZ", productName: "Goat Milk Stage 1", formulaType: .goat, stage: .stage1, minAgeMonths: 0, maxAgeMonths: 6, milkBase: "Goat", isSpecialist: false, requiresMedicalAdvice: false, preparationNotes: nil, sourceURL: nil, lastVerifiedAt: nil),
        
        // Good Start (CA)
        FormulaProduct(id: "goodstart-ca-1", brandId: "goodstart_ca", countryCode: "CA", productName: "Plus 1", formulaType: .standard, stage: .stage1, minAgeMonths: 0, maxAgeMonths: 12, milkBase: "Cow", isSpecialist: false, requiresMedicalAdvice: false, preparationNotes: nil, sourceURL: nil, lastVerifiedAt: nil)
    ]
    
    // MARK: - Feeding Guidelines
    /// General age-based guidelines. Not country-specific for initial launch.
    static let guidelines: [FeedingGuideline] = [
        FeedingGuideline(countryCode: nil, minAgeMonths: 0, maxAgeMonths: 3, mlPerKgPerDayMin: 120, mlPerKgPerDayMax: 180, feedsPerDayMin: 6, feedsPerDayMax: 10, notes: "Newborns feed frequently. Follow hunger cues."),
        FeedingGuideline(countryCode: nil, minAgeMonths: 3, maxAgeMonths: 6, mlPerKgPerDayMin: 100, mlPerKgPerDayMax: 150, feedsPerDayMin: 5, feedsPerDayMax: 8, notes: "Feeding intervals may lengthen."),
        FeedingGuideline(countryCode: nil, minAgeMonths: 6, maxAgeMonths: 12, mlPerKgPerDayMin: 80, mlPerKgPerDayMax: 120, feedsPerDayMin: 4, feedsPerDayMax: 6, notes: "Complementary foods introduced around 6 months."),
        FeedingGuideline(countryCode: nil, minAgeMonths: 12, maxAgeMonths: 24, mlPerKgPerDayMin: 60, mlPerKgPerDayMax: 100, feedsPerDayMin: 3, feedsPerDayMax: 4, notes: "Toddler milk as part of a balanced diet."),
        FeedingGuideline(countryCode: nil, minAgeMonths: 24, maxAgeMonths: nil, mlPerKgPerDayMin: 50, mlPerKgPerDayMax: 80, feedsPerDayMin: 2, feedsPerDayMax: 3, notes: "Older toddler — milk intake naturally decreases as solid foods increase.")
    ]
}
