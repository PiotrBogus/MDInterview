import SwiftUI
import XCTest
@testable import JADesignSystem

final class ColorExtensionTests: XCTestCase {
    func testHexInitializerCreatesColorForValidHex() {
        XCTAssertNotNil(Color(hex: "#FFFFFF"))
    }

    func testHexInitializerReturnsNilForInvalidHex() {
        XCTAssertNil(Color(hex: "#FFF"))
    }

    func testStaticPaletteColorIsAvailable() {
        let color = Color.primary500

        XCTAssertNotNil(color)
    }
}
