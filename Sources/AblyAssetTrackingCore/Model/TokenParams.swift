import Foundation

/**
 Details of the current parameters of the token, which users can use to generate a new ``TokenRequest`` (simpler/ preferable) or ``TokenDetails`` server-side when using Token Authentication.
 */
public struct TokenParams: Codable {
    public let ttl: Int?
    public let capability: String?
    public let clientId: String?
    public let timestamp: Date?
    public let nonce: String?
    
    /// Create a ``TokenParams``. This is called by the Ably Client to generate and passed in ``AuthCallback``, but users can also create a new ``TokenParams`` and send this to their token authentication server if desired.
    /// - Parameters:
    ///   - ttl: Requested time to live for the [Ably Token](https://ably.com/documentation/core-features/authentication#ably-tokens) being created in milliseconds
    ///   - capability: <#capability description#>
    ///   - clientId: A client ID, used for identifying this client when publishing messages or for presence purposes. The clientId can be any non-empty string.
    ///   - timestamp: The timestamp (in milliseconds since the epoch) of this request. timestamp, in conjunction with the ``nonce``, is used to prevent requests for Ably Token from being replayed.
    ///   - nonce: An optional opaque nonce string of at least 16 characters to ensure uniqueness of this request. Any subsequent request using the same nonce will be rejected.
    public init(ttl: Int?,
                capability: String?,
                clientId: String?,
                timestamp: Date?,
                nonce: String?) {
        self.ttl = ttl
        self.capability = capability
        self.clientId = clientId
        self.timestamp = timestamp
        self.nonce = nonce
    }
}
