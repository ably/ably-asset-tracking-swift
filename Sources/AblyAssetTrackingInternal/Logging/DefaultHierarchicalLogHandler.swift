import AblyAssetTrackingCore

/// Wraps a ``LogHandler`` to insert information about which high-level system produced the log message.
/// TODO doc and test
public struct DefaultHierarchicalLogHandler: HierarchicalLogHandler {
    private var logHandler: LogHandler
    private var systemNames: [String] // highest-to-lowest level
    
    public init?(logHandler: LogHandler?, subsystem: Subsystem? = nil) {
        guard let logHandler = logHandler else {
            return nil
        }
        self.logHandler = logHandler
        self.systemNames = ["assetTracking"] + [subsystem?.name].compactMap { $0 }
    }
    
    public func logMessage(level: LogLevel, message: String, error: Error?) {
        let newMessage = "[\(systemNames.joined(separator: "."))] \(message)"
        logHandler.logMessage(level: level, message: newMessage, error: error)
    }
    
    public func addingSubsystem(_ subsystem: Subsystem) -> HierarchicalLogHandler {
        var newHandler = self
        newHandler.systemNames.append(subsystem.name)
        return newHandler
    }
}
