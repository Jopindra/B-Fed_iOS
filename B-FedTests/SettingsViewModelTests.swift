import XCTest
@testable import B_Fed

@MainActor
final class SettingsViewModelTests: XCTestCase {
    
    func testLoadFromProfile() {
        let viewModel = SettingsViewModel()
        let profile = BabyProfile(
            parentName: "Sarah",
            parentEmail: "sarah@example.com",
            babyName: "Lily",
            feedingType: .formula,
            formulaBrand: "Aptamil",
            formulaStage: .stage1
        )
        profile.currentWeight = 4200
        
        viewModel.load(from: profile)
        
        XCTAssertEqual(viewModel.babyName, "Lily")
        XCTAssertEqual(viewModel.feedingType, .formula)
        XCTAssertEqual(viewModel.formulaBrand, "Aptamil")
        XCTAssertEqual(viewModel.formulaStage, .stage1)
        XCTAssertEqual(viewModel.parentName, "Sarah")
        XCTAssertEqual(viewModel.parentEmail, "sarah@example.com")
        XCTAssertEqual(viewModel.currentWeight, "4.20")
    }
    
    func testShowsFormulaFieldsForFormula() {
        let viewModel = SettingsViewModel()
        viewModel.feedingType = .formula
        XCTAssertTrue(viewModel.showsFormulaFields)
    }
    
    func testShowsFormulaFieldsForMixed() {
        let viewModel = SettingsViewModel()
        viewModel.feedingType = .mixed
        XCTAssertTrue(viewModel.showsFormulaFields)
    }
    
    func testShowsFormulaFieldsForBreast() {
        let viewModel = SettingsViewModel()
        viewModel.feedingType = .breast
        XCTAssertFalse(viewModel.showsFormulaFields)
    }
    
    func testLoadFromNilProfile() {
        let viewModel = SettingsViewModel()
        viewModel.load(from: nil)
        XCTAssertEqual(viewModel.babyName, "")
    }
}
