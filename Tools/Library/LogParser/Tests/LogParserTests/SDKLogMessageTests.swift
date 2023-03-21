import XCTest
import LogParser

final class SDKLogMessageTests: XCTestCase {
    // MARK: subsystems

    func test_init_with_validEmittedMessage_parsesSubsystems() throws {
        let emittedMessage = "[assetTracking.someComponent]@(MyFile.swift:130) Here is a message"
        let logMessage = try SDKLogMessage(emittedMessage: emittedMessage)

        XCTAssertEqual(logMessage.subsystems, ["assetTracking", "someComponent"])
    }

    func test_init_whenEmittedMessageDoesNotStartWithSubsystems_throwsError() throws {
        let emittedMessage = "Here is a message"

        XCTAssertThrowsError(try SDKLogMessage(emittedMessage: emittedMessage)) { error in
            XCTAssertEqual(error as? SDKLogMessage.ParsingError, .doesNotMatchExpectedPattern)
        }
    }

    func test_init_whenAssetTrackingIsNotFirstSubsystem_throwsError() throws {
        let emittedMessage = "[someComponent]@(MyFile.swift:130) Here is a message"

        XCTAssertThrowsError(try SDKLogMessage(emittedMessage: emittedMessage)) { error in
            XCTAssertEqual(error as? SDKLogMessage.ParsingError, .firstSubsystemIsNotAssetTracking)
        }
    }

    // MARK: codeLocation

    func test_init_with_validEmittedMessage_withCodeLocation_parsesCodeLocation() throws {
        let emittedMessage = "[assetTracking.someComponent]@(MyFile.swift:130) Here is a message"
        let logMessage = try SDKLogMessage(emittedMessage: emittedMessage)

        XCTAssertEqual(logMessage.codeLocation, .init(file: "MyFile.swift", line: 130))
    }

    func test_init_with_validEmittedMessage_withoutCodeLocation_setsNilCodeLocation() throws {
        let emittedMessage = "[assetTracking.someComponent] Here is a message"
        let logMessage = try SDKLogMessage(emittedMessage: emittedMessage)

        XCTAssertNil(logMessage.codeLocation)
    }

    // MARK: message

    func test_init_withValidEmittedMessage_parsesMessage() throws {
        let emittedMessage = "[assetTracking.someComponent]@(MyFile.swift:130) Here is a message"
        let logMessage = try SDKLogMessage(emittedMessage: emittedMessage)

        XCTAssertEqual(logMessage.message, "Here is a message")
    }
}
