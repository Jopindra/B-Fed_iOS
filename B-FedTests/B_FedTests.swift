import XCTest
@testable import B_Fed

final class B_FedTests: XCTestCase {
    func testBundleLoads() {
        XCTAssertNotNil(Bundle(for: B_FedTests.self))
    }
}
