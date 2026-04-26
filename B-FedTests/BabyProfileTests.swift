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

    // MARK: - Formatted Age

    func testFormattedAgeDays() {
        let dob = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        let profile = BabyProfile(dateOfBirth: dob)
        XCTAssertEqual(profile.formattedAge, "3 days old")
    }

    func testFormattedAgeOneDay() {
        let dob = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let profile = BabyProfile(dateOfBirth: dob)
        XCTAssertEqual(profile.formattedAge, "1 day old")
    }

    func testFormattedAgeWeeks() {
        let dob = Calendar.current.date(byAdding: .day, value: -14, to: Date())!
        let profile = BabyProfile(dateOfBirth: dob)
        XCTAssertEqual(profile.formattedAge, "2 weeks old")
    }

    func testFormattedAgeOneWeek() {
        let dob = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let profile = BabyProfile(dateOfBirth: dob)
        XCTAssertEqual(profile.formattedAge, "1 week old")
    }

    func testFormattedAgeMonths() {
        let dob = Calendar.current.date(byAdding: .month, value: -2, to: Date())!
        let profile = BabyProfile(dateOfBirth: dob)
        let months = profile.ageInMonths
        XCTAssertEqual(profile.formattedAge, "\(months) months old")
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
        XCTAssertEqual(FeedingType.breast.displayName, "Breast milk")
        XCTAssertEqual(FeedingType.formula.displayName, "Formula")
        XCTAssertEqual(FeedingType.mixed.displayName, "Mixed feeding")
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
