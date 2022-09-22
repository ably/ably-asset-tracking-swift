import Foundation
import AblyAssetTrackingCore
import Logging
import LoggingFormatAndPipe

class SubscriberLogger: AblyAssetTrackingCore.LogHandler {
    let swiftLog: Logger

    init (logger: Logger) {
        self.swiftLog = logger
    }
    
    func logMessage(level: LogLevel, message: String, error: Error?) {
        let errorString = error?.localizedDescription
        switch level {
        case .verbose:
            swiftLog.log(level: .trace, "\(message). \(errorString ?? "")")
        case .info:
            swiftLog.log(level: .info, "\(message). \(errorString ?? "")")
        case .debug:
            swiftLog.log(level: .debug, "\(message). \(errorString ?? "")")
        case .warn:
            swiftLog.log(level: .warning, "\(message). \(errorString ?? "")")
        case .error:
            swiftLog.log(level: .error, "\(message). \(errorString ?? "")")
        }
    }
}
