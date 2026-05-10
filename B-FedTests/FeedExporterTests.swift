import XCTest
@testable import B_Fed

final class FeedExporterTests: XCTestCase {
    
    func testExportTextIncludesBabyName() {
        let profile = BabyProfile(babyName: "Lily", feedingType: .formula)
        let text = FeedExporter.exportText(profile: profile, feeds: [])
        XCTAssertTrue(text.contains("Baby: Lily"))
    }
    
    func testExportTextIncludesFeedCount() {
        let feed1 = Feed(startTime: Date(), amount: 120)
        let feed2 = Feed(startTime: Date().addingTimeInterval(-3600), amount: 90)
        let text = FeedExporter.exportText(profile: nil, feeds: [feed1, feed2])
        XCTAssertTrue(text.contains("Total feeds: 2"))
        XCTAssertTrue(text.contains("Total amount: 210 ml"))
    }
    
    func testExportTextIncludesPartialFeedMarker() {
        let feed = Feed(startTime: Date(), amount: 100, completed: false)
        let text = FeedExporter.exportText(profile: nil, feeds: [feed])
        XCTAssertTrue(text.contains("[left some]"))
    }
    
    func testExportTextIncludesDuration() {
        let start = Date()
        let end = start.addingTimeInterval(600)
        let feed = Feed(startTime: start, endTime: end, amount: 100)
        let text = FeedExporter.exportText(profile: nil, feeds: [feed])
        XCTAssertTrue(text.contains("(10m)"))
    }
    
    func testExportFilenameFormat() {
        let filename = FeedExporter.exportFilename()
        XCTAssertTrue(filename.hasPrefix("b-fed-history-"))
        XCTAssertTrue(filename.hasSuffix(".txt"))
    }
}
