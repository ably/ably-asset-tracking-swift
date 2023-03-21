import Foundation
import AblyAssetTrackingCore

public extension InternalLogHandler {
    func verbose(message: String, error: Error?, file: String? = #file, line: Int? = #line) {
        logMessage(level: .verbose, message: message, error: error, file: file, line: line)
    }

    func info(message: String, error: Error?, file: String? = #file, line: Int? = #line) {
        logMessage(level: .info, message: message, error: error, file: file, line: line)
    }

    func debug(message: String, error: Error?, file: String? = #file, line: Int? = #line) {
        logMessage(level: .debug, message: message, error: error, file: file, line: line)
    }

    func warn(message: String, error: Error?, file: String? = #file, line: Int? = #line) {
        logMessage(level: .warn, message: message, error: error, file: file, line: line)
    }

    func error(message: String, error: Error?, file: String? = #file, line: Int? = #line) {
        logMessage(level: .error, message: message, error: error, file: file, line: line)
    }

    func error(error: Error?, file: String? = #file, line: Int? = #line) {
        logMessage(level: .error, message: "", error: error, file: file, line: line)
    }
}
