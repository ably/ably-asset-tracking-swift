import Foundation
import Ably
import AblyAssetTrackingCore

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
}
