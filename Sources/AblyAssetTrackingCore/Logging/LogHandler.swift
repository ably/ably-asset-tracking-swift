import Foundation

// sourcery: AutoMockable
/**
 * Simple protocol that allows to handle logs sent from the SDK.
 */
public protocol LogHandler {
    /**
     * Gets called when a log message is sent from the SDK.
     * param `level` - The importance level of the message.
     * param `message` - The message text.
     * param `error` - Optional error object.
     */
    func logMessage(level: LogLevel, message: String, error: Error?)
}

/**
 * Defines importance levels for log messages.
 */
public enum LogLevel {
    // swiftlint:disable missing_docs
    case verbose
    case info
    case debug
    case warn
    case error
    // swiftlint:enable missing_docs
}
