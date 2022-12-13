import XCTest
import LogParser

class ExampleAppLogFileTests: XCTestCase {
    func test_init_parsesExampleAppLogOutputData() throws {
        let text = """
        2022-12-13T09:06:06.341000-03:00 debug: [assetTracking.someComponent] Here is a message
        Some other line
        2022-12-13T09:06:10.729000-03:00 info: [assetTracking.someOtherComponent]@(MyFile.swift:130) Here is another message
        """
        let data = try XCTUnwrap(text.data(using: .utf8))
        
        let exampleAppLogFile = try ExampleAppLogFile(data: data)
        
        let expectedLines: [ExampleAppLogFile.Line] = [
            .sdk(.init(timestamp: Date(timeIntervalSince1970: 1670933166.341),
                       logLevel: "debug",
                       message: .init(subsystems: ["assetTracking", "someComponent"],
                                      codeLocation: nil,
                                      message: "Here is a message"))),
            .other("Some other line"),
            .sdk(.init(timestamp: Date(timeIntervalSince1970: 1670933170.729),
                       logLevel: "info",
                       message: .init(subsystems: ["assetTracking", "someOtherComponent"],
                                      codeLocation: .init(file: "MyFile.swift", line: 130),
                                      message: "Here is another message"))),
        ]
        
        XCTAssertEqual(exampleAppLogFile.lines, expectedLines)
    }
}
