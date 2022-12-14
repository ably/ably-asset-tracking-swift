import XCTest
import LogParser

class ExampleAppSDKLogLineTests: XCTestCase {
    func test_init_withLogLineEmittedBySDK_parsesTimestamp() throws {
        let line = "2022-12-13T09:06:06.341000-03:00 debug: [assetTracking.publisher.DefaultPublisher]@(DefaultPublisher.swift:906) ablyPublisher.didChangeConnectionState. State: ConnectionState.online."
        let result = try ExampleAppSDKLogLine(line: line)
        
        XCTAssertEqual(result.timestamp, Date(timeIntervalSince1970: 1670933166.341))
    }
    
    func test_init_withLogLineEmittedBySDK_parsesLogLevel() throws {
        let line = "2022-12-13T09:06:06.341000-03:00 debug: [assetTracking.publisher.DefaultPublisher]@(DefaultPublisher.swift:906) ablyPublisher.didChangeConnectionState. State: ConnectionState.online."
        let result = try ExampleAppSDKLogLine(line: line)
        
        XCTAssertEqual(result.logLevel, "debug")
    }
    
    func test_init_withLogLineEmittedBySDK_parsesMessage() throws {
        let line = "2022-12-13T09:06:06.341000-03:00 debug: [assetTracking.publisher.DefaultPublisher]@(DefaultPublisher.swift:906) ablyPublisher.didChangeConnectionState. State: ConnectionState.online."
        let result = try ExampleAppSDKLogLine(line: line)
        
        let expectedMessage = SDKLogMessage(
            subsystems: ["assetTracking", "publisher", "DefaultPublisher"],
            codeLocation: .init(file: "DefaultPublisher.swift", line: 906),
            message: "ablyPublisher.didChangeConnectionState. State: ConnectionState.online."
        )
        XCTAssertEqual(result.message, expectedMessage)
    }

    func test_init_withLogLineEmittedBySDK_withTrailingLineTerminator_parsesMessage_strippingLineTerminator() throws {
        let line = "2022-12-13T09:06:06.341000-03:00 debug: [assetTracking.publisher.DefaultPublisher]@(DefaultPublisher.swift:906) ablyPublisher.didChangeConnectionState. State: ConnectionState.online.\n"
        let result = try ExampleAppSDKLogLine(line: line)
        
        XCTAssertEqual(result.message.message, "ablyPublisher.didChangeConnectionState. State: ConnectionState.online.")
    }
    
    func test_init_withLogLineNotFromSDK_throwsError() {
        let line = "2022-12-13 09:06:04.088025-0300 PublisherExampleSwiftUI[44811:4709249] [Mapbox] [Info, maps-core]: Using Mapbox Core Maps SDK v10.9.0(10541225b5)"
        
        XCTAssertThrowsError(try ExampleAppSDKLogLine(line: line)) { error in
            XCTAssertEqual(error as? ExampleAppSDKLogLine.ParseError, .generalError)
        }
    }
}
