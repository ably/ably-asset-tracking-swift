import XCTest
import AblyAssetTrackingInternal
import AblyAssetTrackingCoreTesting

class DefaultInternalLogHandlerTests: XCTestCase {
    func test_init_withNilLogHandler_returnsNil() {
        XCTAssertNil(DefaultInternalLogHandler(logHandler: nil))
    }
    
    func test_addSubsystem_causesLoggedMessagesToIncludeSubsystemName() throws {
        let underlyingLogHandler = LogHandlerMock()
        let logHandler = try XCTUnwrap(DefaultInternalLogHandler(logHandler: underlyingLogHandler))
            .addingSubsystem(.named("myComponent"))

        logHandler.logMessage(level: .info, message: "Here is a message", error: nil)
        
        let receivedArguments = try XCTUnwrap(underlyingLogHandler.logMessageLevelMessageErrorReceivedArguments)
        XCTAssertEqual(receivedArguments.level, .info)
        XCTAssertEqual(receivedArguments.message, "[assetTracking.myComponent] Here is a message")
        XCTAssertNil(receivedArguments.error)
    }
}
