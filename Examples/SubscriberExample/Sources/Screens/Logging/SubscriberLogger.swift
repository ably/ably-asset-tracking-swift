import Foundation
import AblyAssetTrackingCore
import Logging

class SubscriberLogger: AblyAssetTrackingCore.LogHandler {
    private let logger: Logger
        
    init(logger: Logger) {
        self.logger = logger
    }
    
    func logMessage(level: LogLevel, message: String, error: Error?) {
        let errorString = error?.localizedDescription
        switch level {
        case .verbose:
            logger.log(level: .trace, "\(message). \(errorString ?? "")")
        case .info:
            logger.log(level: .info, "\(message). \(errorString ?? "")")
        case .debug:
            logger.log(level: .debug, "\(message). \(errorString ?? "")")
        case .warn:
            logger.log(level: .warning, "\(message). \(errorString ?? "")")
        case .error:
            logger.log(level: .error, "\(message). \(errorString ?? "")")
        }
    }
}
