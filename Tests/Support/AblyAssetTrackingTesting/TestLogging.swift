import Foundation
import AblyAssetTrackingCore
import AblyAssetTrackingInternal

/// Provides shared logger instances for use by tests.
public enum TestLogging {
    /// A shared implementation of ``LogHandler``, which logs using ``NSLog``.
    public static let sharedLogHandler: LogHandler = TestLogHandler()

    /// A shared implementation of ``InternalLogHandler``, which wraps ``sharedLogHandler``.
    public static let sharedInternalLogHandler: InternalLogHandler = DefaultInternalLogHandler(logHandler: sharedLogHandler)!
}

/// An implementation of ``LogHandler``, which logs using ``NSLog``.
///
/// By default, it does not write any log messages, to avoid leaking sensitive information (such as Ably API keys) in a CI environment. If you’re running the tests on your development machine, enable logging by setting the `ABLY_ASSET_TRACKING_TESTS_ENABLE_LOGGING` environment variable to 1.
private class TestLogHandler: AblyAssetTrackingCore.LogHandler {
    private let isLoggingEnabled: Bool = {
        let isEnabled = ProcessInfo.processInfo.environment["ABLY_ASSET_TRACKING_TESTS_ENABLE_LOGGING"] == "1"

        if !isEnabled {
            NSLog("Ably Asset Tracking SDK logging is disabled by default when testing, to avoid leaking sensitive information in a CI environment. If you’re running the tests on your development machine, enable logging by setting the ABLY_ASSET_TRACKING_TESTS_ENABLE_LOGGING environment variable to 1.")
        }

        return isEnabled
    }()

    public func logMessage(level: LogLevel, message: String, error: Error?) {
        guard isLoggingEnabled else {
            return
        }

        let suffix: String
        if let error {
            suffix = " (error: \(error.localizedDescription))"
        } else {
            suffix = ""
        }

        NSLog("\(level): \(message)\(suffix)")
    }
}
