import Foundation

/// Represents a log line emitted by the Asset Tracking SDK in the publisher and subscriber example apps.
public struct ExampleAppSDKLogLine: Equatable {
    /// The timestamp contained in the log line.
    public var timestamp: Date
    /// The log level described by the log line.
    public var logLevel: String
    /// The message received from the Asset Tracking SDK.
    public var message: SDKLogMessage
    /// The `localizedDescription` of the error received from the Asset Tracking SDK, if any.
    public var errorMessage: String?

    public enum ParseError: Error {
        case generalError
        case missingErrorMarker
        case missingErrorMessageLength
        case missingErrorLengthTerminator
        case missingErrorTerminator
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

        if scanner.scanString("[noError] ") != nil {
            self.errorMessage = nil
        } else if scanner.scanString("[error(len:") != nil {
            var errorMessageLength = 0
            guard scanner.scanInt(&errorMessageLength) else {
                throw ParseError.missingErrorMessageLength
            }
            guard scanner.scanString("): ") != nil else {
                throw ParseError.missingErrorLengthTerminator
            }

            let errorMessageEndIndex = line.index(scanner.currentIndex, offsetBy: errorMessageLength)
            self.errorMessage = String(line[scanner.currentIndex..<errorMessageEndIndex])
            scanner.currentIndex = errorMessageEndIndex

            guard scanner.scanString("] ") != nil else {
                throw ParseError.missingErrorTerminator
            }
        } else {
            throw ParseError.missingErrorMarker
        }

        let remainder = scanner.isAtEnd ? "" : line[scanner.currentIndex...]
        self.message = try .init(emittedMessage: String(remainder))
    }

    public init(timestamp: Date, logLevel: String, message: SDKLogMessage, errorMessage: String?) {
        self.timestamp = timestamp
        self.logLevel = logLevel
        self.message = message
        self.errorMessage = errorMessage
    }
}
