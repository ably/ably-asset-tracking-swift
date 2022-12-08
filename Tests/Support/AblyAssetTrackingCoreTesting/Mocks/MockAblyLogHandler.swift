import Foundation
import AblyAssetTrackingCore

public class MockLogHandler: LogHandler {
    public init() {}
    
    public func logMessage(level: LogLevel, message: String, error: Error?) {}
}
