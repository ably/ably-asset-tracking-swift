import XCTest
import LogParser

class ExampleAppLogFileTests: XCTestCase {
    func test_init_parsesExampleAppLogOutputData() throws {
        let text = """
        2022-12-13T09:06:06.341000-03:00 debug: [noError] [assetTracking.someComponent] Here is a message
        Some other line
        2022-12-13T09:06:10.729000-03:00 info: [noError] [assetTracking.someOtherComponent]@(MyFile.swift:130) Here is another message
        2022-12-13T09:06:32.282000-03:00 error: [error(len:24): Here is an error message] [assetTracking.someComponent] Here is a message with an attached error
        """
        let data = try XCTUnwrap(text.data(using: .utf8))
        
        let exampleAppLogFile = try ExampleAppLogFile(data: data)
        
        let expectedLines: [ExampleAppLogFile.Line] = [
            .sdk(.init(timestamp: Date(timeIntervalSince1970: 1670933166.341),
                       logLevel: "debug",
                       message: .init(subsystems: ["assetTracking", "someComponent"],
                                      codeLocation: nil,
                                      message: "Here is a message"),
                       errorMessage: nil)),
            .other("Some other line"),
            .sdk(.init(timestamp: Date(timeIntervalSince1970: 1670933170.729),
                       logLevel: "info",
                       message: .init(subsystems: ["assetTracking", "someOtherComponent"],
                                      codeLocation: .init(file: "MyFile.swift", line: 130),
                                      message: "Here is another message"),
                       errorMessage: nil)),
            .sdk(.init(timestamp: Date(timeIntervalSince1970: 1670933192.282),
                       logLevel: "error",
                       message: .init(subsystems: ["assetTracking", "someComponent"],
                                      codeLocation: nil,
                                      message: "Here is a message with an attached error"),
                       errorMessage: "Here is an error message"))
        ]
        
        XCTAssertEqual(exampleAppLogFile.lines, expectedLines)
    }
}
