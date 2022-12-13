import AblyAssetTrackingCore

/// A description of some component of the SDK which wishes to identify itself in a log message.
public enum Subsystem {
    /// An arbitrary component with a name.
    case named(String)
    /// A component that is a Swift type.
    case typed(Any.Type)
    
    /// The text that will be used to identify this component in a log message.
    var name: String {
        switch self {
        case .named(let name):
            return name
        case .typed(let type):
            return String(describing: type)
        }
    }
}

/// A log handler that stores a hierarchy of subsystems of increasing granularity, for example ["asset-tracking", "publisher", "DefaultPublisher"]. It is expected that it will use this information to output some sort of information about these subsystems in the log messages that it outputs, for example by adding a string "[asset-tracking.publisher.DefaultPublisher]".
public protocol HierarchicalLogHandler: LogHandler {
    /// Adds another subsystem to the log handler’s list.
    /// - Parameter subsystem: The subsystem to add. This will be added at a higher level of granularity then the subsystems currently in the log handler’s list.
    /// - Returns: A new log handler.
    func addingSubsystem(_ subsystem: Subsystem) -> HierarchicalLogHandler
}

extension HierarchicalLogHandler {
    /// A convenience method for adding a Swift type to the log handler’s list.
    /// - Parameter type: The Swift type to add, for example `DefaultPublisher.self`.
    /// - Returns: A new log handler.
    public func addingSubsystem(_ type: Any.Type) -> HierarchicalLogHandler {
        return addingSubsystem(.typed(type))
    }
}
