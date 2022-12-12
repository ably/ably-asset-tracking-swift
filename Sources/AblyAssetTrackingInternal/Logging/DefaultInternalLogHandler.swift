import AblyAssetTrackingCore
import Foundation

/// Provides an implementation of ``InternalLogHandler`` by wrapping another instance of ``LogHandler``. It will insert the following information into the log messages that it emits:
/// - a string such as "[asset-tracking.publisher.DefaultPublisher]", representing its list of subsystems;
/// - optionally, a string such as "@(MyFile.swift:30)", representing the source code location from which the log message was emitted.
public struct DefaultInternalLogHandler: InternalLogHandler {
    private var logHandler: LogHandler
    private var subsystemNames: [String] // Lowest granularity first
    
    /// Creates an instance of ``DefaultInternalLogHandler`` that writes messages to a given ``LogHandler``. The lowest-granularity subsystem of the returned log handler will always be "assetTracking".
    /// - Parameters:
    ///   - logHandler: A log handler to write messages to. If this is nil, the initializer will return nil.
    ///   - subsystem: A subsystem to add to the list
    public init?(logHandler: LogHandler?, subsystem: Subsystem? = nil) {
        guard let logHandler = logHandler else {
            return nil
        }
        self.logHandler = logHandler
        
        self.subsystemNames = ["assetTracking"]
        if let subsystem = subsystem {
            self.subsystemNames.append(subsystem.name)
        }
    }
    
    public func logMessage(level: LogLevel, message: String, error: Error?, codeLocation: CodeLocation?) {
        var messageToEmit = "[\(subsystemNames.joined(separator: "."))]"

        if let codeLocation = codeLocation {
            messageToEmit.append("@(\((codeLocation.file as NSString).lastPathComponent):\(codeLocation.line))")
        }
        
        messageToEmit.append(" \(message)")
        
        logHandler.logMessage(level: level, message: messageToEmit, error: error)
    }
    
    public func addingSubsystem(_ subsystem: Subsystem) -> InternalLogHandler {
        var newHandler = self
        newHandler.subsystemNames.append(subsystem.name)
        return newHandler
    }
}
