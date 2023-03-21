import Foundation

/// Represents the log output of a session of the publisher or subscriber example app.
public struct ExampleAppLogFile {
    /// A line from the log output.
    public enum Line: Equatable {
        /// A line from the Asset Tracking SDK.
        case sdk(ExampleAppSDKLogLine)
        /// A line not from the Asset Tracking SDK.
        case other(String)
    }

    /// The lines of the log output.
    public var lines: [Line]

    public enum ParseError: Error {
        case dataNotUTF8
    }

    /// Parses the log ouptut of a session of the publisher or subscriber example app.
    public init(data: Data) throws {
        guard let text = String(data: data, encoding: .utf8) else {
            throw ParseError.dataNotUTF8
        }

        let textLines = text.components(separatedBy: .newlines)

        self.lines = textLines.map { textLine in
            do {
                let sdkLine = try ExampleAppSDKLogLine(line: textLine)
                return .sdk(sdkLine)
            } catch {
                return .other(textLine)
            }
        }
    }

    public init(lines: [Line]) {
        self.lines = lines
    }
}
