import XCTest
import SwiftUI
@testable import B_Fed

final class DesignTokensTests: XCTestCase {

    // MARK: - Color Hex Parsing

    func testColorHex3Digit() {
        let color = Color(hex: "F0A")
        // 3-digit: F*17=255, 0*17=0, A*17=170
        // This tests the parsing path doesn't crash
        XCTAssertNotNil(color)
    }

    func testColorHex6Digit() {
        let color = Color(hex: "E8C4B0")
        XCTAssertNotNil(color)
    }

    func testColorHex8Digit() {
        let color = Color(hex: "FFE8C4B0")
        XCTAssertNotNil(color)
    }

    func testColorHexInvalid() {
        let color = Color(hex: "invalid")
        // Should return a default color (near-black with opacity)
        XCTAssertNotNil(color)
    }

    func testColorHexEmpty() {
        let color = Color(hex: "")
        XCTAssertNotNil(color)
    }

    // MARK: - Semantic Colors Exist

    func testPeachDustColor() {
        XCTAssertNotNil(Color.peachDust)
    }

    func testAlmostAquaColor() {
        XCTAssertNotNil(Color.almostAqua)
    }

    func testLemonIcingColor() {
        XCTAssertNotNil(Color.lemonIcing)
    }

    func testOrchidTintColor() {
        XCTAssertNotNil(Color.orchidTint)
    }

    func testInkPrimaryColor() {
        XCTAssertNotNil(Color.inkPrimary)
    }

    func testBackgroundBaseColor() {
        XCTAssertNotNil(Color.backgroundBase)
    }

    // MARK: - AppFont

    func testSansFontCreation() {
        let font = AppFont.sans(16)
        XCTAssertNotNil(font)
    }

    func testSansFontWithWeight() {
        let font = AppFont.sans(16, weight: .semibold)
        XCTAssertNotNil(font)
    }

    func testSerifFontCreation() {
        let font = AppFont.serif(26)
        XCTAssertNotNil(font)
    }

    func testTypeScaleFonts() {
        XCTAssertNotNil(AppFont.heroTitle)
        XCTAssertNotNil(AppFont.screenTitle)
        XCTAssertNotNil(AppFont.sectionTitle)
        XCTAssertNotNil(AppFont.bodyLarge)
        XCTAssertNotNil(AppFont.body)
        XCTAssertNotNil(AppFont.caption)
        XCTAssertNotNil(AppFont.label)
    }

    // MARK: - Spacing Tokens

    func testSpacingTokens() {
        XCTAssertEqual(AppSpacing.xs, 4)
        XCTAssertEqual(AppSpacing.sm, 8)
        XCTAssertEqual(AppSpacing.md, 12)
        XCTAssertEqual(AppSpacing.lg, 16)
        XCTAssertEqual(AppSpacing.xl, 24)
        XCTAssertEqual(AppSpacing.xxl, 32)
    }

    // MARK: - Radius Tokens

    func testRadiusTokens() {
        XCTAssertEqual(AppRadius.small, 10)
        XCTAssertEqual(AppRadius.button, 14)
        XCTAssertEqual(AppRadius.card, 16)
        XCTAssertEqual(AppRadius.hero, 20)
        XCTAssertEqual(AppRadius.pill, 26)
    }

    // MARK: - Legacy Color Mappings

    func testLegacyMappings() {
        XCTAssertEqual(Color.brandPrimary, Color.almostAquaDark)
        XCTAssertEqual(Color.warmCoral, Color.peachDust)
        XCTAssertEqual(Color.warmLavender, Color.orchidTint)
        // textPrimary and textSecondary are distinct semantic colours,
        // not aliases of inkPrimary/inkSecondary.
        XCTAssertNotNil(Color.textPrimary)
        XCTAssertNotNil(Color.textSecondary)
    }
}
