import Foundation

/// Represents a log line emitted by the Asset Tracking SDK in the publisher and subscriber example apps.
public struct ExampleAppSDKLogLine: Equatable {
    /// The timestamp contained in the log line.
    public var timestamp: Date
    /// The log level described by the log line.
    public var logLevel: String
    /// The remainder of the log line.
    ///
    /// > Note: The ``SDKLogMessage/message`` of this value is not necessarily the exact value that was passed as the `message` argument of AblyAssetTrackingCore’s `LogHandler.logMessage(level:message:error:)`. It may contain a suffix added by the example apps’ log handlers, to add a trailing full stop and information about the `error` argument.
    ///
    /// Future versions of this library might address this issue.
    public var message: SDKLogMessage
    
    public enum ParseError: Error {
        case generalError
    }
    
    private static let isoDateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFractionalSeconds, .withInternetDateTime]
        return formatter
    }()
    
    /// Parses a line of log output from an example app.
    /// - Parameter line: A line of log output from the publisher or subscriber example app. Any trailing line terminators will be stripped.
    public init(line: String) throws {
        let scanner = Scanner(string: line)
        scanner.charactersToBeSkipped = []
        guard let isoTimestamp = scanner.scanUpToString(" ") else {
            throw ParseError.generalError
        }
        
        guard let timestamp = Self.isoDateFormatter.date(from: isoTimestamp) else {
            throw ParseError.generalError
        }
        
        self.timestamp = timestamp
        
        guard scanner.scanString(" ") != nil else {
            throw ParseError.generalError
        }
        
        guard let logLevel = scanner.scanUpToString(":") else {
            throw ParseError.generalError
        }
        
        self.logLevel = logLevel
        
        guard scanner.scanString(": ") != nil else {
            throw ParseError.generalError
        }
        
        let remainder = scanner.isAtEnd ? "" : line[scanner.currentIndex...]
        self.message = try .init(emittedMessage: String(remainder))
    }
    
    public init(timestamp: Date, logLevel: String, message: SDKLogMessage) {
        self.timestamp = timestamp
        self.logLevel = logLevel
        self.message = message
    }
}
