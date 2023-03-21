import AblyAssetTrackingInternal
import AblyAssetTrackingCore

/// A mock for the ``InternalLogHandler`` type. We don't use Sourcery to generate this since this mock is frequently used from multiple threads, which causes crashes due to concurrent mutation of shared state (see CONTRIBUTING.md).
///
/// Favour using this type over ``InternalLogHandlerMock`` if you need a mock instance of ``InternalLogHandler`` and don't need to make any assertions about logged messages.
public struct InternalLogHandlerMockThreadSafe: InternalLogHandler {
    public init() {}

    public func logMessage(level: AblyAssetTrackingCore.LogLevel, message: String, error: Error?, codeLocation: AblyAssetTrackingInternal.CodeLocation?) {
        // no-op
    }

    public func tagMessage(_ message: String) -> String {
        message
    }

    public func addingSubsystem(_ subsystem: AblyAssetTrackingInternal.Subsystem) -> AblyAssetTrackingInternal.InternalLogHandler {
        InternalLogHandlerMockThreadSafe()
    }
}
