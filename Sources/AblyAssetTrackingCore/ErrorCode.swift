/**
 The range of `ErrorInformation.code` values that represent an error in the Ably Asset Tracking SDK. These codes are canonically defined by https://github.com/ably/ably-asset-tracking-common/tree/main/specification#error-codes.
 */
public enum ErrorCode: Int {
    /**
     The SDK received a message in an unexpected format. This is treated as a fatal protocol error and the transport will be closed with a failure.
     */
    case invalidMessage = 100001
}
