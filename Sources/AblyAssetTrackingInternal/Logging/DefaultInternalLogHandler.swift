import AblyAssetTrackingCore
import Foundation

/// Provides an implementation of ``InternalLogHandler`` by wrapping another instance of ``LogHandler``. It will insert the following information into the log messages that it emits:
/// - a string such as "[assetTracking.publisher.DefaultPublisher]", representing its list of subsystems (any '[' or ']' characters in the subsystems’ names will be replaced by underscores);
/// - optionally, a string such as "@(MyFile.swift:30)", representing the source code location from which the log message was emitted.
public struct DefaultInternalLogHandler: InternalLogHandler {
    private var logHandler: LogHandler
    private var subsystemNames: [String] // Lowest granularity first
    
    /// Creates an instance of ``DefaultInternalLogHandler`` that writes messages to a given ``LogHandler``.
    /// - Parameters:
    ///   - logHandler: A log handler to write messages to. If this is nil, the initializer will return nil.
    ///   - subsystems: The log handler’s initial list of subsystems, in order of increasing granularity.
    public init?(logHandler: LogHandler?, subsystems: [Subsystem] = []) {
        guard let logHandler = logHandler else {
            return nil
        }
        self.logHandler = logHandler

        self.subsystemNames = subsystems.map(\.name)
    }
    
    public func logMessage(level: LogLevel, message: String, error: Error?, codeLocation: CodeLocation?) {
        let taggedMessage = tagMessage(message, codeLocation: codeLocation)

        logHandler.logMessage(level: level, message: taggedMessage, error: error)
    }
    
    public func addingSubsystem(_ subsystem: Subsystem) -> InternalLogHandler {
        var newHandler = self
        newHandler.subsystemNames.append(subsystem.name)
        return newHandler
    }

    public func tagMessage(_ message: String) -> String {
        return tagMessage(message, codeLocation: nil)
    }

    private func tagMessage(_ message: String, codeLocation: CodeLocation?) -> String {
        let sanitizedSubsystemNames = subsystemNames.map(DefaultInternalLogHandler.sanitizeSubsystemName)
        var result = "[\(sanitizedSubsystemNames.joined(separator: "."))]"

        if let codeLocation = codeLocation {
            result.append("@(\((codeLocation.file as NSString).lastPathComponent):\(codeLocation.line))")
        }

        result.append(" \(message)")

        return result
    }

    private static func sanitizeSubsystemName(_ name: String) -> String {
        return (name as NSString)
            .replacingOccurrences(of: "[", with: "_")
            .replacingOccurrences(of: "]", with: "_")
    }
}
