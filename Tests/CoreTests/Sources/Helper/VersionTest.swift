@testable import AblyAssetTrackingCore
import XCTest

class VersionTest: XCTestCase {
    private let libraryVersion = "1.0.0-alpha.1"

    func testCurrentVersionIsSetAndSemantic() {
        XCTAssertEqual(libraryVersion, Version.libraryVersion)
    }
}
