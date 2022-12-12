import AblyAssetTrackingCore
import AblyAssetTrackingInternal

public class MockInternalLogHandler: InternalLogHandler {
    public init() {}
    
    public func addingSubsystem(_ subsystem: Subsystem) -> AblyAssetTrackingInternal.InternalLogHandler {
        return self
    }
    
    public func logMessage(level: LogLevel, message: String, error: Error?) {}
}
