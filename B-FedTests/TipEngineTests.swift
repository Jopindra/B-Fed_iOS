import XCTest
@testable import B_Fed

final class TipEngineTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        DismissedTipStore.reset()
    }
    
    func testTipsForNewborn() {
        let profile = BabyProfile(babyName: "Test", dateOfBirth: Date().addingTimeInterval(-86400 * 3), feedingType: .breast)
        let tips = TipEngine.tips(for: profile, feeds: [])
        
        XCTAssertTrue(tips.contains { $0.id == "newborn-cluster" })
    }
    
    func testTipsForFormulaFeeding() {
        let profile = BabyProfile(babyName: "Test", dateOfBirth: Date().addingTimeInterval(-86400 * 30), feedingType: .formula)
        let tips = TipEngine.tips(for: profile, feeds: [])
        
        XCTAssertTrue(tips.contains { $0.id == "formula-prep" })
    }
    
    func testTipsForMixedFeedingIncludesFormula() {
        let profile = BabyProfile(babyName: "Test", dateOfBirth: Date().addingTimeInterval(-86400 * 30), feedingType: .mixed)
        let tips = TipEngine.tips(for: profile, feeds: [])
        
        XCTAssertTrue(tips.contains { $0.id == "formula-prep" })
    }
    
    func testTipsForLowIntake() {
        let profile = BabyProfile(babyName: "Test", dateOfBirth: Date().addingTimeInterval(-86400 * 30), feedingType: .breast)
        let feed = Feed(startTime: Date(), amount: 100)
        let tips = TipEngine.tips(for: profile, feeds: [feed])
        
        XCTAssertTrue(tips.contains { $0.id == "low-intake-okay" })
    }
    
    func testTipsForPartialFeeds() {
        let profile = BabyProfile(babyName: "Test", dateOfBirth: Date().addingTimeInterval(-86400 * 30), feedingType: .breast)
        let feed1 = Feed(startTime: Date(), amount: 100, completed: false)
        let feed2 = Feed(startTime: Date().addingTimeInterval(-3600), amount: 80, completed: false)
        let tips = TipEngine.tips(for: profile, feeds: [feed1, feed2])
        
        XCTAssertTrue(tips.contains { $0.id == "partial-normal" })
    }
    
    func testTipsLimitToTwo() {
        let profile = BabyProfile(babyName: "Test", dateOfBirth: Date().addingTimeInterval(-86400 * 3), feedingType: .formula)
        let tips = TipEngine.tips(for: profile, feeds: [])
        
        XCTAssertLessThanOrEqual(tips.count, 2)
    }
    
    func testDismissedTipStore() {
        XCTAssertFalse(DismissedTipStore.isDismissed("test-tip"))
        DismissedTipStore.dismiss("test-tip")
        XCTAssertTrue(DismissedTipStore.isDismissed("test-tip"))
    }
    
    func testDismissedTipStoreReset() {
        DismissedTipStore.dismiss("test-tip")
        DismissedTipStore.reset()
        XCTAssertFalse(DismissedTipStore.isDismissed("test-tip"))
    }
}
