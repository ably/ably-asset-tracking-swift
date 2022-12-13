import AblyAssetTrackingCore
import AblyAssetTrackingInternal

public class MockHierarchicalLogHandler: HierarchicalLogHandler {
    public init() {}
    
    public func addingSubsystem(_ subsystem: Subsystem) -> AblyAssetTrackingInternal.HierarchicalLogHandler {
        return self
    }
    
    public func logMessage(level: LogLevel, message: String, error: Error?) {}
}
