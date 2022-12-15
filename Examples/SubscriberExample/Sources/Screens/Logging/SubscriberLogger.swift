import Foundation
import AblyAssetTrackingCore
import Logging

class SubscriberLogger: AblyAssetTrackingCore.LogHandler {
    private let logger: Logger
        
    init(logger: Logger) {
        self.logger = logger
    }
    
    func logMessage(level: LogLevel, message: String, error: Error?) {
        let prefix: String

        if let error = error {
            // The LogParser library needs to be able to extract the error description from the log message; for this reason we emit its length
            let errorDescription = error.localizedDescription
            prefix = "[error(len:\(errorDescription.count)): \(errorDescription)] "
        } else {
            prefix = "[noError] "
        }
        
        logger.log(level: level.swiftLogLevel, "\(prefix)\(message)")
    }
}

private extension LogLevel {
    var swiftLogLevel: Logger.Level {
        switch self {
        case .verbose: return .trace
        case .info: return .info
        case .debug: return .debug
        case .warn: return .warning
        case .error: return .error
        }
    }
}
