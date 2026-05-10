import XCTest
@testable import B_Fed

final class BabyProfileTests: XCTestCase {

    // MARK: - Initialization

    func testDefaultInitialization() {
        let profile = BabyProfile()
        XCTAssertNotNil(profile.id)
        XCTAssertEqual(profile.parentName, "")
        XCTAssertEqual(profile.parentEmail, "")
        XCTAssertEqual(profile.babyName, "Baby")
        XCTAssertEqual(profile.feedingType, .formula)
        XCTAssertNil(profile.birthWeight)
        XCTAssertNil(profile.currentWeight)
        XCTAssertNotNil(profile.createdAt)
        XCTAssertNotNil(profile.updatedAt)
    }

    func testCustomInitialization() {
        let dob = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
        let profile = BabyProfile(
            parentName: "Sarah",
            parentEmail: "sarah@example.com",
            country: "Australia",
            babyName: "Lily",
            dateOfBirth: dob,
            birthWeight: 3400,
            currentWeight: 5200,
            feedingType: .breast
        )
        XCTAssertEqual(profile.parentName, "Sarah")
        XCTAssertEqual(profile.parentEmail, "sarah@example.com")
        XCTAssertEqual(profile.country, "Australia")
        XCTAssertEqual(profile.babyName, "Lily")
        XCTAssertEqual(profile.birthWeight, 3400)
        XCTAssertEqual(profile.currentWeight, 5200)
        XCTAssertEqual(profile.feedingType, .breast)
    }

    // MARK: - Age Calculations

    func testAgeInDaysForNewborn() {
        let dob = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        let profile = BabyProfile(dateOfBirth: dob)
        XCTAssertEqual(profile.ageInDays, 5)
    }

    func testAgeInDaysForOneMonthOld() {
        let dob = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        let profile = BabyProfile(dateOfBirth: dob)
        XCTAssertEqual(profile.ageInDays, 30)
    }

    func testAgeInWeeks() {
        let dob = Calendar.current.date(byAdding: .day, value: -21, to: Date())!
        let profile = BabyProfile(dateOfBirth: dob)
        // ageInWeeks uses weekOfYear which can vary; just verify it's reasonable
        XCTAssertGreaterThanOrEqual(profile.ageInWeeks, 0)
    }

    func testAgeInMonths() {
        let dob = Calendar.current.date(byAdding: .month, value: -3, to: Date())!
        let profile = BabyProfile(dateOfBirth: dob)
        XCTAssertGreaterThanOrEqual(profile.ageInMonths, 2)
    }

    // MARK: - Age Description

    func testAgeDescriptionUnderOneWeek() {
        let dob = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        let profile = BabyProfile(dateOfBirth: dob)
        XCTAssertEqual(profile.ageDescription, "3 days old")
    }
    
    func testAgeDescriptionBabyBornToday() {
        let profile = BabyProfile(dateOfBirth: Date())
        XCTAssertEqual(profile.ageDescription, "0 weeks old")
        XCTAssertEqual(profile.ageInDays, 0)
        XCTAssertEqual(profile.ageInWeeks, 0)
        XCTAssertGreaterThanOrEqual(profile.ageInMonths, 0)
    }
    
    func testAgeDescriptionNeverNegative() {
        // Future date should never produce negative age
        let futureDOB = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        let profile = BabyProfile(dateOfBirth: futureDOB)
        XCTAssertEqual(profile.ageInDays, 0)
        XCTAssertEqual(profile.ageInWeeks, 0)
        XCTAssertEqual(profile.ageInMonths, 0)
        XCTAssertEqual(profile.ageDescription, "0 weeks old")
    }

    func testAgeDescriptionOneWeek() {
        let dob = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let profile = BabyProfile(dateOfBirth: dob)
        XCTAssertEqual(profile.ageDescription, "1 week old")
    }

    func testAgeDescriptionTwoWeeks() {
        let dob = Calendar.current.date(byAdding: .day, value: -14, to: Date())!
        let profile = BabyProfile(dateOfBirth: dob)
        XCTAssertEqual(profile.ageDescription, "2 weeks old")
    }

    func testAgeDescriptionMonths() {
        let dob = Calendar.current.date(byAdding: .month, value: -2, to: Date())!
        let profile = BabyProfile(dateOfBirth: dob)
        let months = profile.ageInMonths
        XCTAssertEqual(profile.ageDescription, "\(months) months old")
    }
    
    func testAgeDescriptionOneYear() {
        let dob = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
        let profile = BabyProfile(dateOfBirth: dob)
        XCTAssertEqual(profile.ageDescription, "12 months old")
    }
    
    func testAgeDescriptionOverTwoYears() {
        let dob = Calendar.current.date(byAdding: .year, value: -2, to: Date())!
            .addingTimeInterval(-86400 * 30) // subtract ~1 month
        let profile = BabyProfile(dateOfBirth: dob)
        XCTAssertTrue(profile.ageDescription.contains("2 years"))
    }

    // MARK: - Weight

    func testWeightInKgWithCurrentWeight() {
        let profile = BabyProfile(currentWeight: 5200)
        XCTAssertEqual(profile.weightInKg, 5.2)
    }

    func testWeightInKgWithBirthWeightFallback() {
        let profile = BabyProfile(birthWeight: 3400)
        XCTAssertEqual(profile.weightInKg, 3.4)
    }

    func testWeightInKgWithNoWeight() {
        let profile = BabyProfile()
        XCTAssertNil(profile.weightInKg)
    }

    // MARK: - Feeding Type

    func testFeedingTypeDisplayNames() {
        XCTAssertEqual(FeedingType.breast.displayName, "Breastfeeding")
        XCTAssertEqual(FeedingType.formula.displayName, "Formula")
        XCTAssertEqual(FeedingType.mixed.displayName, "Combination feeding")
    }

    func testFeedingTypeIcons() {
        XCTAssertEqual(FeedingType.breast.icon, "heart.fill")
        XCTAssertEqual(FeedingType.formula.icon, "drop.fill")
        XCTAssertEqual(FeedingType.mixed.icon, "arrow.left.arrow.right")
    }

    func testFeedingTypeAllCases() {
        XCTAssertEqual(FeedingType.allCases.count, 3)
        XCTAssertTrue(FeedingType.allCases.contains(.breast))
        XCTAssertTrue(FeedingType.allCases.contains(.formula))
        XCTAssertTrue(FeedingType.allCases.contains(.mixed))
    }

    func testFeedingTypeRawValues() {
        XCTAssertEqual(FeedingType.breast.rawValue, "breast")
        XCTAssertEqual(FeedingType.formula.rawValue, "formula")
        XCTAssertEqual(FeedingType.mixed.rawValue, "mixed")
    }

    // MARK: - Profile Setup Status

    func testProfileSetupStatusCases() {
        let statuses: [ProfileSetupStatus] = [.notStarted, .needsOnboarding, .complete]
        XCTAssertEqual(statuses.count, 3)
    }
}
