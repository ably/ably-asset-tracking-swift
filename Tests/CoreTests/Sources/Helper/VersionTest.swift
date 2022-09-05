import XCTest
@testable import AblyAssetTrackingCore

class VersionTest: XCTestCase {
    private let libraryVersion = "1.0.0-rc.1"
    
    func testCurrentVersionIsSetAndSemantic() {
        XCTAssertEqual(libraryVersion, Version.libraryVersion)
    }
}
