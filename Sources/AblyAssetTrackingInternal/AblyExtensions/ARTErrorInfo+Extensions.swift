import Ably
import AblyAssetTrackingCore

/**
 Wrapper for ARTErrorInfo, as we don't want to pass it to our clients
 */
extension ARTErrorInfo {
    public func toErrorInformation() -> ErrorInformation {
        return ErrorInformation(
            code: self.code,
            statusCode: self.statusCode,
            message: self.message,
            cause: nil,
            href: self.href)
    }
}
