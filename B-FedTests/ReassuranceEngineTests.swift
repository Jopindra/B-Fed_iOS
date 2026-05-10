import XCTest
@testable import B_Fed

final class ReassuranceEngineTests: XCTestCase {

    func testLowIntakeReassurance() {
        let message = ReassuranceEngine.lowIntakeReassurance()
        let expected = [
            "Frequent small feeds are completely normal",
            "Every baby has lighter days",
            "Trust your baby's appetite",
            "You're responding perfectly to their needs",
            "Some days are simply lighter — that's okay",
            "Baby leads, you follow — you're doing it right"
        ]
        XCTAssertTrue(expected.contains(message))
    }

    func testConsistencyReinforcement() {
        let message = ReassuranceEngine.consistencyReinforcement()
        let expected = [
            "You're building a beautiful routine",
            "Great rhythm developing",
            "Consistency is emerging naturally",
            "You're finding your groove"
        ]
        XCTAssertTrue(expected.contains(message))
    }

    func testImprovementEncouragement() {
        let message = ReassuranceEngine.improvementEncouragement()
        let expected = [
            "Intake is changing",
            "Baby is thriving",
            "Wonderful progress together",
            "You're both doing beautifully"
        ]
        XCTAssertTrue(expected.contains(message))
    }

    func testPostFeedEncouragement() {
        let message = ReassuranceEngine.postFeedEncouragement()
        let expected = [
            "Noted",
            "That feed counts",
            "One feed at a time",
            "That counts",
            "Perfect"
        ]
        XCTAssertTrue(expected.contains(message))
    }
}
