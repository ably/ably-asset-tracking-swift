import XCTest
import AblyAssetTrackingInternal
import AblyAssetTrackingInternalTesting

class InternalLogHandlerTests: XCTestCase {
    func test_protocolExtension_logMessage_defaultArguments_populatesFileAndLine() throws {
        let handler = InternalLogHandlerMock()

        let expectedLine = #line + 1
        handler.logMessage(level: .info, message: "Here is a message", error: nil)

        let receivedArguments = try XCTUnwrap(handler.logMessageLevelMessageErrorCodeLocationReceivedArguments)

        XCTAssertEqual(receivedArguments.level, .info)
        XCTAssertEqual(receivedArguments.message, "Here is a message")
        XCTAssertNil(receivedArguments.error)
        XCTAssertEqual(receivedArguments.codeLocation, .init(file: #file, line: expectedLine))
    }
}
