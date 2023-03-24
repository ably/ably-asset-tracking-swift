import Ably
import AblyAssetTrackingCore

/**
 Wrapper for ARTErrorInfo, as we don't want to pass it to our clients
 */
extension ARTErrorInfo {
    // swiftlint:disable:next missing_docs
    public func toErrorInformation() -> ErrorInformation {
        ErrorInformation(
            code: self.code,
            statusCode: self.statusCode,
            message: self.message,
            cause: nil,
            href: self.href
        )
    }
}
