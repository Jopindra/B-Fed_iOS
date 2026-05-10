import XCTest
@testable import B_Fed

final class ErrorLoggerTests: XCTestCase {

    func testSilentLoggerDoesNotCrash() {
        let logger = SilentErrorLogger()
        let error = NSError(domain: "test", code: 1)
        logger.log(error, context: "TestContext")
        // Silent logger does nothing — just verify no crash
    }

    func testPrintLoggerDoesNotCrash() {
        let logger = PrintErrorLogger()
        let error = NSError(domain: "test", code: 2)
        logger.log(error, context: "TestContext")
        // Print logger prints to stdout — just verify no crash
    }
}
