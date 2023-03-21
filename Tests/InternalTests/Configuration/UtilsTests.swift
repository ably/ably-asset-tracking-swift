import Ably
import AblyAssetTrackingInternal
import Foundation
import XCTest

class UtilsTests: XCTestCase {
    func testARTErrorInfoHrefIsMappedProperlyToErrorInformationHref() {
        let artError = ARTErrorInfo.create(withCode: 1001, message: "A message")
        let errorInfo = artError.toErrorInformation()

        XCTAssertNotNil(errorInfo.href)
        XCTAssertNotNil(errorInfo.message)
        XCTAssertEqual(artError.message, errorInfo.message)
        XCTAssertEqual(artError.href, errorInfo.href)
    }
}
