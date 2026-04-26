import XCTest
@testable import B_Fed

@MainActor
final class OnboardingViewModelTests: XCTestCase {

    var viewModel: OnboardingViewModel!

    override func setUp() async throws {
        try await super.setUp()
        viewModel = OnboardingViewModel()
    }

    override func tearDown() async throws {
        viewModel = nil
        try await super.tearDown()
    }

    // MARK: - Initial State

    func testInitialState() {
        XCTAssertEqual(viewModel.parentName, "")
        XCTAssertEqual(viewModel.parentEmail, "")
        XCTAssertEqual(viewModel.country, "")
        XCTAssertEqual(viewModel.babyName, "")
        XCTAssertEqual(viewModel.feedingType, "")
        XCTAssertEqual(viewModel.birthWeight, "")
        XCTAssertEqual(viewModel.currentWeight, "")
        XCTAssertEqual(viewModel.weightUnit, "kg")
        XCTAssertEqual(viewModel.currentStep, 0)
        XCTAssertFalse(viewModel.showingValidationErrors)
    }

    // MARK: - Email Validation

    func testIsEmailValidWithEmptyEmail() {
        viewModel.parentEmail = ""
        XCTAssertFalse(viewModel.isEmailValid)
    }

    func testIsEmailValidWithInvalidEmail() {
        viewModel.parentEmail = "notanemail"
        XCTAssertFalse(viewModel.isEmailValid)
    }

    func testIsEmailValidWithValidEmail() {
        viewModel.parentEmail = "user@example.com"
        XCTAssertTrue(viewModel.isEmailValid)
    }

    // MARK: - Feeding Selection

    func testHasFeedingSelectionEmpty() {
        viewModel.feedingType = ""
        XCTAssertFalse(viewModel.hasFeedingSelection)
    }

    func testHasFeedingSelectionValid() {
        viewModel.feedingType = "breast"
        XCTAssertTrue(viewModel.hasFeedingSelection)
    }

    // MARK: - Weight Unit

    func testIsKgTrue() {
        viewModel.weightUnit = "kg"
        XCTAssertTrue(viewModel.isKg)
    }

    func testIsKgFalse() {
        viewModel.weightUnit = "lb_oz"
        XCTAssertFalse(viewModel.isKg)
    }

    // MARK: - Continue Enabled Per Step

    func testContinueEnabledStep1() {
        viewModel.parentName = ""
        XCTAssertFalse(viewModel.isContinueEnabled(forStep: 1))
        viewModel.parentName = "Sarah"
        XCTAssertTrue(viewModel.isContinueEnabled(forStep: 1))
    }

    func testContinueEnabledStep2() {
        viewModel.parentEmail = "bad"
        XCTAssertFalse(viewModel.isContinueEnabled(forStep: 2))
        viewModel.parentEmail = "sarah@example.com"
        XCTAssertTrue(viewModel.isContinueEnabled(forStep: 2))
    }

    func testContinueEnabledStep3() {
        viewModel.country = ""
        XCTAssertFalse(viewModel.isContinueEnabled(forStep: 3))
        viewModel.country = "Australia"
        XCTAssertTrue(viewModel.isContinueEnabled(forStep: 3))
    }

    func testContinueEnabledStep4() {
        viewModel.babyName = ""
        XCTAssertFalse(viewModel.isContinueEnabled(forStep: 4))
        viewModel.babyName = "Lily"
        XCTAssertTrue(viewModel.isContinueEnabled(forStep: 4))
    }

    func testContinueEnabledStep5() {
        XCTAssertTrue(viewModel.isContinueEnabled(forStep: 5))
    }

    func testContinueEnabledStep6() {
        viewModel.feedingType = ""
        XCTAssertFalse(viewModel.isContinueEnabled(forStep: 6))
        viewModel.feedingType = "formula"
        XCTAssertTrue(viewModel.isContinueEnabled(forStep: 6))
    }

    func testContinueEnabledStep7() {
        XCTAssertTrue(viewModel.isContinueEnabled(forStep: 7))
    }

    // MARK: - Navigation

    func testAdvanceToStep() {
        viewModel.showingValidationErrors = true
        viewModel.advanceToStep(3)
        XCTAssertEqual(viewModel.currentStep, 3)
        XCTAssertFalse(viewModel.showingValidationErrors)
    }

    func testGoBackToStep() {
        viewModel.currentStep = 5
        viewModel.showingValidationErrors = true
        viewModel.goBackToStep(3)
        XCTAssertEqual(viewModel.currentStep, 3)
        XCTAssertFalse(viewModel.showingValidationErrors)
    }

    // MARK: - Reset

    func testReset() {
        viewModel.prefillWithSampleData()
        viewModel.currentStep = 5
        viewModel.showingValidationErrors = true

        viewModel.reset()

        XCTAssertEqual(viewModel.parentName, "")
        XCTAssertEqual(viewModel.parentEmail, "")
        XCTAssertEqual(viewModel.country, "")
        XCTAssertEqual(viewModel.babyName, "")
        XCTAssertEqual(viewModel.feedingType, "")
        XCTAssertEqual(viewModel.birthWeight, "")
        XCTAssertEqual(viewModel.currentWeight, "")
        XCTAssertEqual(viewModel.weightUnit, "kg")
        XCTAssertEqual(viewModel.currentStep, 0)
        XCTAssertFalse(viewModel.showingValidationErrors)
    }

    // MARK: - Profile Creation

    func testCreateProfileWithAllData() {
        viewModel.prefillWithSampleData()
        let profile = viewModel.createProfile()

        XCTAssertEqual(profile.parentName, "Sarah")
        XCTAssertEqual(profile.parentEmail, "sarah@example.com")
        XCTAssertEqual(profile.country, "Australia")
        XCTAssertEqual(profile.babyName, "Lily")
        XCTAssertEqual(profile.feedingType, .breast)
        XCTAssertEqual(profile.birthWeight, 3400)
        XCTAssertEqual(profile.currentWeight, 4200)
    }

    func testCreateProfileWithEmptyBabyName() {
        viewModel.babyName = ""
        let profile = viewModel.createProfile()
        XCTAssertEqual(profile.babyName, "Baby")
    }

    func testCreateProfileWithFormulaFeeding() {
        viewModel.feedingType = "formula"
        let profile = viewModel.createProfile()
        XCTAssertEqual(profile.feedingType, .formula)
    }

    func testCreateProfileWithMixedFeeding() {
        viewModel.feedingType = "both"
        let profile = viewModel.createProfile()
        XCTAssertEqual(profile.feedingType, .mixed)
    }

    func testCreateProfileWithUnknownFeedingDefaultsToFormula() {
        viewModel.feedingType = "unknown"
        let profile = viewModel.createProfile()
        XCTAssertEqual(profile.feedingType, .formula)
    }

    func testCreateProfileWithNonKgUnitIgnoresWeights() {
        viewModel.prefillWithSampleData()
        viewModel.weightUnit = "lb_oz"
        let profile = viewModel.createProfile()
        XCTAssertNil(profile.birthWeight)
        XCTAssertNil(profile.currentWeight)
    }

    func testCreateProfileWithInvalidWeightStrings() {
        viewModel.birthWeight = "abc"
        viewModel.currentWeight = ""
        viewModel.weightUnit = "kg"
        let profile = viewModel.createProfile()
        XCTAssertNil(profile.birthWeight)
        XCTAssertNil(profile.currentWeight)
    }

    // MARK: - Prefill

    func testPrefillWithSampleData() {
        viewModel.prefillWithSampleData()
        XCTAssertEqual(viewModel.parentName, "Sarah")
        XCTAssertEqual(viewModel.parentEmail, "sarah@example.com")
        XCTAssertEqual(viewModel.country, "Australia")
        XCTAssertEqual(viewModel.babyName, "Lily")
        XCTAssertEqual(viewModel.feedingType, "breast")
        XCTAssertEqual(viewModel.birthWeight, "3.4")
        XCTAssertEqual(viewModel.currentWeight, "4.2")
        XCTAssertEqual(viewModel.weightUnit, "kg")
        XCTAssertEqual(viewModel.currentStep, 0)
    }
}
