import Foundation
import XCTest
@testable import JAResources

final class JAResourcesTests: XCTestCase {
    func testModuleBundleIsAvailable() {
        XCTAssertNotNil(Bundle.module.resourceURL)
    }
}
