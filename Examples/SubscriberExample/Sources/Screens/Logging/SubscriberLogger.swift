import Foundation
import AblyAssetTrackingCore
import Logging
import LoggingFormatAndPipe

class SubscriberLogger: AblyLogHandler {
    var swiftLog: Logger
        
    init () {
        swiftLog = Logger(label: "com.ably.SubscriberExample") { _ in
            let myDateFormat = DateFormatter()
            myDateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
            
            let format = BasicFormatter([.timestamp, .level, .message], timestampFormatter: myDateFormat)
            return LoggingFormatAndPipe.Handler(formatter: format, pipe: LoggerTextOutputStreamPipe.standardError)
        }
        
        swiftLog.logLevel = .info
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
