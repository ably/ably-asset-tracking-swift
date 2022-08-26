import Foundation

public extension AblyLogHandler {
    func v(message: String, error: Error?) {
        log(level: .verbose, message: message, error: error)
    }
    
    func i(message: String, error: Error?) {
        log(level: .info, message: message, error: error)
    }
    
    func d(message: String, error: Error?) {
        log(level: .debug, message: message, error: error)
    }
    
    func w(message: String, error: Error?) {
        log(level: .warn, message: message, error: error)
    }
    
    func e(message: String, error: Error?) {
        log(level: .error, message: message, error: error)
    }

    func e(error: Error?) {
        log(level: .error, message: "", error: error)
    }
    
    private func log(level: LogLevel, message: String, error: Error?) {
        let timestampString = getFormattedCurrentTimestamp()
        logMessage(level: level, message: "\(timestampString): \(message)", error: error)
    }
    
    private func getFormattedCurrentTimestamp() -> String{
        let currentDate = Date(timeIntervalSince1970: Date.timeIntervalSinceReferenceDate)
        
        let dateFormat = DateFormatter()
        
        dateFormat.locale = Locale.current
        dateFormat.setLocalizedDateFormatFromTemplate("dd-MM-yy HH:mm:ss.SSS")
        return dateFormat.string(from: currentDate)
    }
}
