import Foundation
import AblyAssetTrackingCore
import Logging

class PublisherLogger: AblyAssetTrackingCore.LogHandler {
    private let logger: Logger
        
    init(logger: Logger) {
        self.logger = logger
    }
    
    func logMessage(level: LogLevel, message: String, error: Error?) {
        let errorString = error?.localizedDescription
        logger.log(level: level.swiftLogLevel, "\(message). \(errorString ?? "")")
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
