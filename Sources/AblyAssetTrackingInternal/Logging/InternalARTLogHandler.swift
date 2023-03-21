import Ably
import AblyAssetTrackingCore
import Foundation

/**
 * This log handler provides an subclass of the ably-cocoa SDK’s ``ARTLog`` class.
 * It forwards the log messages to a given instance of ``InternalLogHandler``.
 */
public class InternalARTLogHandler: ARTLog {
    private let logHandler: InternalLogHandler?

    public init(logHandler: InternalLogHandler?) {
        self.logHandler = logHandler?.addingSubsystem(.named("ablySDK"))
    }

    private func log(_ message: String, level: LogLevel, error: Error?) {
        // We don't add line numbers to messages emitted by ably-cocoa,
        // since it doesn’t expose that information to us through the
        // ARTLog interface. Also, some (but not all) log messages from
        // ably-cocoa already include line number information.
        switch level {
        case .verbose:
            logHandler?.verbose(message: message, error: error, file: nil, line: nil)
        case .info:
            logHandler?.info(message: message, error: error, file: nil, line: nil)
        case .debug:
            logHandler?.debug(message: message, error: error, file: nil, line: nil)
        case .warn:
            logHandler?.warn(message: message, error: error, file: nil, line: nil)
        case .error:
            logHandler?.error(message: message, error: error, file: nil, line: nil)
        }
    }

    private func convertLogLevel(artLogLevel: ARTLogLevel) -> LogLevel {
        switch artLogLevel {
        case .verbose:
            return LogLevel.verbose
        case .debug:
            return LogLevel.debug
        case .info:
            return LogLevel.info
        case .warn:
            return LogLevel.warn
        case .error:
            return LogLevel.error
        default:
            return LogLevel.warn
        }
    }

    override public func log(_ message: String, with level: ARTLogLevel) {
        let convertedLogLevel = convertLogLevel(artLogLevel: level)
        log(message, level: convertedLogLevel, error: nil)
    }

    override public func logWithError(_ error: ARTErrorInfo) {
        let convertedLogLevel = convertLogLevel(artLogLevel: .error)
        log(error.message, level: convertedLogLevel, error: nil)
    }
}
