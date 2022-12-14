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

/// A pointer to a line within a source code file.
public struct CodeLocation: Equatable {
    /// A path to the source code file. May be absolute or relative. If relative, no assumptions will be made about the base path.
    public var file: String
    /// The line number in the source code file.
    public var line: Int
    
    public init(file: String, line: Int) {
        self.file = file
        self.line = line
    }
}

/// A log handler to be used by components of the Asset Tracking SDKs. It provides SDK components with functionality for augmenting the log output.
///
/// It stores a hierarchy of subsystems of increasing granularity, for example ["asset-tracking", "publisher", "DefaultPublisher"]. It is expected that it will use this information to output some sort of information about these subsystems in the log messages that it outputs, for example by adding a string "[asset-tracking.publisher.DefaultPublisher]".
//sourcery: AutoMockable
public protocol InternalLogHandler {
    /// Logs a message.
    /// - Parameters:
    ///   - level: The log level of the message.
    ///   - message: The message to log.
    ///   - error: An optional related error to log alongside the message.
    ///   - codeLocation: The location in the code where the message was emitted.
    func logMessage(level: LogLevel, message: String, error: Error?, codeLocation: CodeLocation?)

    /// Adds another subsystem to the log handler’s list.
    /// - Parameter subsystem: The subsystem to add. This will be added at a higher level of granularity then the subsystems currently in the log handler’s list.
    /// - Returns: A new log handler.
    func addingSubsystem(_ subsystem: Subsystem) -> InternalLogHandler
}

extension InternalLogHandler {
    /// A convenience method for adding a Swift type to the log handler’s list.
    /// - Parameter type: The Swift type to add, for example `DefaultPublisher.self`.
    /// - Returns: A new log handler.
    public func addingSubsystem(_ type: Any.Type) -> InternalLogHandler {
        return addingSubsystem(.typed(type))
    }
    
    /// A convenience logging method that uses the call site’s #file and #line values.
    public func logMessage(level: LogLevel, message: String, error: Error?, file: String? = #file, line: Int? = #line) {
        let codeLocation: CodeLocation?
        if let file = file, let line = line {
            codeLocation = CodeLocation(file: file, line: line)
        } else {
            codeLocation = nil
        }
        logMessage(level: level, message: message, error: error, codeLocation: codeLocation)
    }
}