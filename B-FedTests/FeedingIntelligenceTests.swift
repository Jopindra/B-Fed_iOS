import XCTest
@testable import B_Fed

final class FeedingIntelligenceTests: XCTestCase {

    // MARK: - Daily Intake Guide

    func testDailyIntakeGuideNoProfile() {
        let guide = FeedingIntelligence.dailyIntakeGuide(for: nil)
        XCTAssertEqual(guide.typical.min, 500)
        XCTAssertEqual(guide.typical.max, 750)
        XCTAssertEqual(guide.display, "500–750")
    }

    func testDailyIntakeGuideWeightBased() {
        let profile = BabyProfile(currentWeight: 4000) // 4kg
        let guide = FeedingIntelligence.dailyIntakeGuide(for: profile)
        // 4kg * 150ml = 600ml base; ±20% = 480–720
        XCTAssertEqual(guide.typical.min, 480)
        XCTAssertEqual(guide.typical.max, 720)
    }

    func testDailyIntakeGuideBirthWeightFallback() {
        let profile = BabyProfile(birthWeight: 3000) // 3kg, no current weight
        let guide = FeedingIntelligence.dailyIntakeGuide(for: profile)
        // 3kg * 150ml = 450ml base; ±20% = 360–540
        XCTAssertEqual(guide.typical.min, 360)
        XCTAssertEqual(guide.typical.max, 540)
    }

    func testDailyIntakeGuideAgeBasedNewborn() {
        let dob = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        let profile = BabyProfile(dateOfBirth: dob)
        let guide = FeedingIntelligence.dailyIntakeGuide(for: profile)
        XCTAssertEqual(guide.typical.min, 300)
        XCTAssertEqual(guide.typical.max, 500)
    }

    func testDailyIntakeGuideAgeBasedTwoWeeks() {
        let dob = Calendar.current.date(byAdding: .day, value: -20, to: Date())!
        let profile = BabyProfile(dateOfBirth: dob)
        let guide = FeedingIntelligence.dailyIntakeGuide(for: profile)
        XCTAssertEqual(guide.typical.min, 400)
        XCTAssertEqual(guide.typical.max, 700)
    }

    func testDailyIntakeGuideAgeBasedOneMonth() {
        let dob = Calendar.current.date(byAdding: .day, value: -45, to: Date())!
        let profile = BabyProfile(dateOfBirth: dob)
        let guide = FeedingIntelligence.dailyIntakeGuide(for: profile)
        XCTAssertEqual(guide.typical.min, 500)
        XCTAssertEqual(guide.typical.max, 900)
    }

    func testDailyIntakeGuideAgeBasedThreeMonths() {
        let dob = Calendar.current.date(byAdding: .day, value: -90, to: Date())!
        let profile = BabyProfile(dateOfBirth: dob)
        let guide = FeedingIntelligence.dailyIntakeGuide(for: profile)
        XCTAssertEqual(guide.typical.min, 600)
        XCTAssertEqual(guide.typical.max, 1000)
    }

    func testDailyIntakeGuideAgeBasedFiveMonths() {
        let dob = Calendar.current.date(byAdding: .day, value: -150, to: Date())!
        let profile = BabyProfile(dateOfBirth: dob)
        let guide = FeedingIntelligence.dailyIntakeGuide(for: profile)
        XCTAssertEqual(guide.typical.min, 700)
        XCTAssertEqual(guide.typical.max, 1200)
    }

    func testDailyIntakeGuideAgeBasedSevenMonths() {
        let dob = Calendar.current.date(byAdding: .month, value: -7, to: Date())!
        let profile = BabyProfile(dateOfBirth: dob)
        let guide = FeedingIntelligence.dailyIntakeGuide(for: profile)
        XCTAssertEqual(guide.typical.min, 600)
        XCTAssertEqual(guide.typical.max, 900)
    }

    // MARK: - Per Feed Guide

    func testPerFeedGuide() {
        let profile = BabyProfile(currentWeight: 4000)
        let guide = FeedingIntelligence.perFeedGuide(for: profile)
        // Daily avg = (480+720)/2 = 600; per feed = 600/8 to 600/6 = 75–100
        XCTAssertEqual(guide.typical.min, 75)
        XCTAssertEqual(guide.typical.max, 100)
        XCTAssertTrue(guide.display.contains("Typical feed:"))
    }

    // MARK: - Intake Display

    func testIntakeDisplay() {
        let profile = BabyProfile(currentWeight: 4000)
        let display = FeedingIntelligence.intakeDisplay(current: 520, profile: profile)
        XCTAssertEqual(display, "520 / 720 ml")
    }

    // MARK: - Bottle Fill Level

    func testBottleFillLevelZero() {
        let profile = BabyProfile(currentWeight: 4000)
        let level = FeedingIntelligence.bottleFillLevel(current: 0, profile: profile)
        XCTAssertEqual(level, 0.1) // base 10%
    }

    func testBottleFillLevelHalf() {
        let profile = BabyProfile(currentWeight: 4000)
        // target = 720, current = 360, percentage = 0.5
        let level = FeedingIntelligence.bottleFillLevel(current: 360, profile: profile)
        XCTAssertEqual(level, CGFloat(0.1 + (0.5 * 0.85)), accuracy: 0.01)
    }

    func testBottleFillLevelCapped() {
        let profile = BabyProfile(currentWeight: 4000)
        // Way over target; should cap at 85% progress
        let level = FeedingIntelligence.bottleFillLevel(current: 10000, profile: profile)
        XCTAssertEqual(level, CGFloat(0.1 + (0.85 * 0.85)), accuracy: 0.01)
    }

    // MARK: - Supporting Messages

    func testSupportingMessageOnTrack() {
        let profile = BabyProfile(currentWeight: 4000)
        let message = FeedingIntelligence.supportingMessage(current: 650, profile: profile)
        let onTrackMessages = ["You're right on track", "Today is going smoothly", "Today is unfolding gently"]
        XCTAssertTrue(onTrackMessages.contains(message))
    }

    func testSupportingMessageGettingThere() {
        let profile = BabyProfile(currentWeight: 4000)
        let message = FeedingIntelligence.supportingMessage(current: 400, profile: profile)
        let midMessages = ["Building steadily", "You're doing fine", "Gentle progress"]
        XCTAssertTrue(midMessages.contains(message))
    }

    func testSupportingMessageLowIntake() {
        let profile = BabyProfile(currentWeight: 4000)
        let message = FeedingIntelligence.supportingMessage(current: 100, profile: profile)
        let reassuranceMessages = [
            "Frequent small feeds are completely normal",
            "Every baby has lighter days",
            "Trust your baby's appetite",
            "You're responding perfectly to their needs",
            "Some days are simply lighter — that's okay"
        ]
        XCTAssertTrue(reassuranceMessages.contains(message))
    }

    // MARK: - Contextual Guidance

    func testContextualGuidanceNoProfile() {
        let guidance = FeedingIntelligence.contextualGuidance(current: 100, profile: nil)
        XCTAssertNil(guidance)
    }

    // MARK: - Insights

    func testInsightsEmptyFeeds() {
        let insights = FeedingIntelligence.insights(from: [], profile: nil)
        XCTAssertTrue(insights.isEmpty)
    }

    func testInsightsFewFeeds() {
        let now = Date()
        let feeds = (0..<3).map { i in
            Feed(startTime: now.addingTimeInterval(Double(i) * 3600), amount: 100)
        }
        let insights = FeedingIntelligence.insights(from: feeds, profile: nil)
        XCTAssertTrue(insights.isEmpty || insights == ["You're building a beautiful routine"])
    }

    func testInsightsTimePattern() {
        let calendar = Calendar.current
        var feeds: [Feed] = []
        for i in 0..<5 {
            var components = calendar.dateComponents([.year, .month, .day], from: Date())
            components.hour = 9
            components.minute = 0
            let date = calendar.date(from: components)!
            feeds.append(Feed(startTime: date.addingTimeInterval(Double(i) * 86400), amount: 100))
        }
        let insights = FeedingIntelligence.insights(from: feeds, profile: nil)
        XCTAssertTrue(insights.contains("Most feeds happen in the morning"))
    }
}
