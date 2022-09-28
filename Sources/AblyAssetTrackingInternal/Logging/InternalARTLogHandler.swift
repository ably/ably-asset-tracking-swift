import Foundation
import Ably
import AblyAssetTrackingCore

/**
* This log handler is supposed to be used only for capturing internal events from the ably-cocoa sdk and passing them on
* to the LogHandler (passed by users via publisher/subscriber builder methods) via `logCallback`
*/
public class InternalARTLogHandler: ARTLog {
    var logCallback: ((_ message: String, _ level: LogLevel, _ error: Error?) -> Void)?
    
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
        logCallback?(message, convertedLogLevel, nil)
    }
    
    override public func logWithError(_ error: ARTErrorInfo) {
        let convertedLogLevel = convertLogLevel(artLogLevel: .error)
        logCallback?(error.message, convertedLogLevel, error)
    }
}
