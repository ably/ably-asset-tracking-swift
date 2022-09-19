import Foundation
import AblyAssetTrackingCore

class MockLogHandler: LogHandler {
    func logMessage(level: LogLevel, message: String, error: Error?) {}
}
