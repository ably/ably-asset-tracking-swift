import AblyAssetTrackingCore

/// Provides an implementation of ``HierarchicalLogHandler`` by wrapping another instance of ``LogHandler``. It will insert a string such as "[asset-tracking.publisher.DefaultPublisher]" into the log messages, representing its list of subsystems.
public struct DefaultHierarchicalLogHandler: HierarchicalLogHandler {
    private var logHandler: LogHandler
    private var subsystemNames: [String] // Lowest granularity first
    
    /// Creates an instance of ``DefaultHierarchicalLogHandler`` that writes messages to a given ``LogHandler``. The lowest-granularity subsystem of the returned log handler will always be "assetTracking".
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
    
    public func logMessage(level: LogLevel, message: String, error: Error?) {
        let newMessage = "[\(subsystemNames.joined(separator: "."))] \(message)"
        logHandler.logMessage(level: level, message: newMessage, error: error)
    }
    
    public func addingSubsystem(_ subsystem: Subsystem) -> HierarchicalLogHandler {
        var newHandler = self
        newHandler.subsystemNames.append(subsystem.name)
        return newHandler
    }
}
