import Foundation
import AblyAssetTrackingCore

public extension LogHandler {
    func verbose(message: String, error: Error?) {
        logMessage(level: .verbose, message: message, error: error)
    }
    
    func info(message: String, error: Error?) {
        logMessage(level: .info, message: message, error: error)
    }
    
    func debug(message: String, error: Error?) {
        logMessage(level: .debug, message: message, error: error)
    }
    
    func warn(message: String, error: Error?) {
        logMessage(level: .warn, message: message, error: error)
    }
    
    func error(message: String, error: Error?) {
        logMessage(level: .error, message: message, error: error)
    }

    func error(error: Error?) {
        logMessage(level: .error, message: "", error: error)
    }
}
