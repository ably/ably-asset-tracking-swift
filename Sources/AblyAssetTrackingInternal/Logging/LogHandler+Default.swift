import Foundation
import AblyAssetTrackingCore

public extension LogHandler {
    func verbose(message: String, error: Error?) {
        log(level: .verbose, message: message, error: error)
    }
    
    func info(message: String, error: Error?) {
        log(level: .info, message: message, error: error)
    }
    
    func debug(message: String, error: Error?) {
        log(level: .debug, message: message, error: error)
    }
    
    func warn(message: String, error: Error?) {
        log(level: .warn, message: message, error: error)
    }
    
    func error(message: String, error: Error?) {
        log(level: .error, message: message, error: error)
    }

    func error(error: Error?) {
        log(level: .error, message: "", error: error)
    }
    
    private func log(level: LogLevel, message: String, error: Error?) {
        let timestampString = getFormattedCurrentTimestamp()
        logMessage(level: level, message: "\(timestampString): \(message)", error: error)
    }
    
    private func getFormattedCurrentTimestamp() -> String{
        let currentDate = Date()
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss.SSS"
        return dateFormatter.string(from: currentDate)
    }
}
