import Foundation
import AblyAssetTrackingCore

class MockAblyLogHandler: AblyLogHandler {
    func logMessage(level: LogLevel, message: String, error: Error?) {}
}
