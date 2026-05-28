import Foundation
import XCTest
@testable import IResources

final class IResourcesTests: XCTestCase {
    func testModuleBundleIsAvailable() {
        XCTAssertNotNil(Bundle.module.resourceURL)
    }
}
