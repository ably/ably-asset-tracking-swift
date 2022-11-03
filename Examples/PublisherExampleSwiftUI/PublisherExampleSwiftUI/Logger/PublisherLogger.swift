import Foundation
import AblyAssetTrackingCore
import Logging

class PublisherLogger: AblyAssetTrackingCore.LogHandler {
    private let swiftLog: Logger
        
    init(swiftLog: Logger) {
        self.swiftLog = swiftLog
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
