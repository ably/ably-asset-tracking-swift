import XCTest
import AblyAssetTrackingInternal
import AblyAssetTrackingCoreTesting

class DefaultHierarchicalLogHandlerTests: XCTestCase {
    func test_init_withNilLogHandler_returnsNil() {
        XCTAssertNil(DefaultHierarchicalLogHandler(logHandler: nil))
    }
    
    func test_addSubsystem_causesLoggedMessagesToIncludeSubsystemName() throws {
        let underlyingLogHandler = LogHandlerMock()
        let logHandler = try XCTUnwrap(DefaultHierarchicalLogHandler(logHandler: underlyingLogHandler))
            .addingSubsystem(.named("myComponent"))

        logHandler.logMessage(level: .info, message: "Here is a message", error: nil)
        
        let receivedArguments = try XCTUnwrap(underlyingLogHandler.logMessageLevelMessageErrorReceivedArguments)
        XCTAssertEqual(receivedArguments.level, .info)
        XCTAssertEqual(receivedArguments.message, "[assetTracking.myComponent] Here is a message")
        XCTAssertNil(receivedArguments.error)
    }
}
