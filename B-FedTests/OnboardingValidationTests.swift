import XCTest
@testable import B_Fed

final class OnboardingValidationTests: XCTestCase {

    // MARK: - Email Validation

    func testValidEmails() {
        let validEmails = [
            "user@example.com",
            "test.email@domain.co.uk",
            "user+tag@example.com",
            "first.last@company.io",
            "123@numeric.com",
            "UPPER@CASE.COM",
            "mixed-CASE@Example.Org"
        ]
        for email in validEmails {
            XCTAssertTrue(OnboardingValidation.isValidEmail(email), "\(email) should be valid")
        }
    }

    func testInvalidEmails() {
        let invalidEmails = [
            "",
            " ",
            "plainstring",
            "@nodomain.com",
            "missing@domain",
            "spaces in@domain.com",
            "double@@domain.com",
            "noat.symbol",
            "@.com",
            "user@.com",
            "user@domain.",
            "a@b.c"  // too short TLD per regex
        ]
        for email in invalidEmails {
            XCTAssertFalse(OnboardingValidation.isValidEmail(email), "\(email) should be invalid")
        }
    }

    // MARK: - Name Validation

    func testValidNames() {
        XCTAssertTrue(OnboardingValidation.isValidName("Sarah"))
        XCTAssertTrue(OnboardingValidation.isValidName("John Doe"))
        XCTAssertTrue(OnboardingValidation.isValidName("Mary-Jane"))
        XCTAssertTrue(OnboardingValidation.isValidName("  Trimmed  "))
        XCTAssertTrue(OnboardingValidation.isValidName("O'Connor"))
    }

    func testInvalidNames() {
        XCTAssertFalse(OnboardingValidation.isValidName(""))
        XCTAssertFalse(OnboardingValidation.isValidName("   "))
        XCTAssertFalse(OnboardingValidation.isValidName("\n\t"))
    }

    // MARK: - Country Validation

    func testValidCountries() {
        XCTAssertTrue(OnboardingValidation.isValidCountry("Australia"))
        XCTAssertTrue(OnboardingValidation.isValidCountry("  United Kingdom  "))
    }

    func testInvalidCountries() {
        XCTAssertFalse(OnboardingValidation.isValidCountry(""))
        XCTAssertFalse(OnboardingValidation.isValidCountry("   "))
    }

    // MARK: - Weight Validation

    func testValidWeights() {
        XCTAssertTrue(OnboardingValidation.isValidWeight("3.4"))
        XCTAssertTrue(OnboardingValidation.isValidWeight("  2.5  "))
        XCTAssertTrue(OnboardingValidation.isValidWeight("10"))
        XCTAssertTrue(OnboardingValidation.isValidWeight("0.1"))
    }

    func testInvalidWeights() {
        XCTAssertFalse(OnboardingValidation.isValidWeight(""))
        XCTAssertFalse(OnboardingValidation.isValidWeight("abc"))
        XCTAssertFalse(OnboardingValidation.isValidWeight("0"))
        XCTAssertFalse(OnboardingValidation.isValidWeight("-5"))
        XCTAssertFalse(OnboardingValidation.isValidWeight("  "))
    }

    // MARK: - Feeding Type Validation

    func testValidFeedingTypes() {
        XCTAssertTrue(OnboardingValidation.isValidFeedingType("breast"))
        XCTAssertTrue(OnboardingValidation.isValidFeedingType("formula"))
        XCTAssertTrue(OnboardingValidation.isValidFeedingType("both"))
        XCTAssertTrue(OnboardingValidation.isValidFeedingType("BREAST"))
        XCTAssertTrue(OnboardingValidation.isValidFeedingType("Formula"))
        XCTAssertTrue(OnboardingValidation.isValidFeedingType("Both"))
    }

    func testInvalidFeedingTypes() {
        XCTAssertFalse(OnboardingValidation.isValidFeedingType(""))
        XCTAssertFalse(OnboardingValidation.isValidFeedingType("solid"))
        XCTAssertFalse(OnboardingValidation.isValidFeedingType("unknown"))
    }

    // MARK: - Date of Birth Validation

    func testValidDateOfBirth() {
        let past = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let today = Date()
        XCTAssertTrue(OnboardingValidation.isValidDateOfBirth(past))
        XCTAssertTrue(OnboardingValidation.isValidDateOfBirth(today))
    }

    func testInvalidDateOfBirth() {
        let future = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        XCTAssertFalse(OnboardingValidation.isValidDateOfBirth(future))
    }

    // MARK: - Full Form Validation

    func testValidForm() {
        let errors = OnboardingValidation.validateOnboardingForm(
            parentName: "Sarah",
            parentEmail: "sarah@example.com",
            country: "Australia",
            babyName: "Lily",
            babyDOB: Calendar.current.date(byAdding: .day, value: -30, to: Date())!,
            feedingType: "breast"
        )
        XCTAssertTrue(errors.isEmpty)
    }

    func testInvalidFormAllFields() {
        let future = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let errors = OnboardingValidation.validateOnboardingForm(
            parentName: "",
            parentEmail: "invalid",
            country: "",
            babyName: "   ",
            babyDOB: future,
            feedingType: "unknown"
        )
        XCTAssertEqual(errors.count, 6)
        XCTAssertTrue(errors.contains("Please enter your name"))
        XCTAssertTrue(errors.contains("Please enter a valid email address"))
        XCTAssertTrue(errors.contains("Please select your country"))
        XCTAssertTrue(errors.contains("Please enter your baby's name"))
        XCTAssertTrue(errors.contains("Date of birth cannot be in the future"))
        XCTAssertTrue(errors.contains("Please select a feeding method"))
    }

    func testInvalidFormPartialFields() {
        let errors = OnboardingValidation.validateOnboardingForm(
            parentName: "Sarah",
            parentEmail: "sarah@example.com",
            country: "",
            babyName: "Lily",
            babyDOB: Date(),
            feedingType: "breast"
        )
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors.first, "Please select your country")
    }
}
