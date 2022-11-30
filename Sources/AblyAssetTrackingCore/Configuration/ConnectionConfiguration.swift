import Foundation

/// A container for specific types of ``AuthCallback`` results
public enum AuthResult {
    /// Json Web Token
    case jwt(String)
    /// ``TokenRequest``
    case tokenRequest(TokenRequest)
    /// ``TokenDetails``
    case tokenDetails(TokenDetails)
}

public typealias Token = String
public typealias AuthCallback = (TokenParams, @escaping (Result<AuthResult, Error>) -> Void) -> Void

/// A container for connection configuration data used when connecting to Ably
public class ConnectionConfiguration {
    public let apiKey: String?
    public let clientId: String?
    public let remainPresentForMilliseconds: Int?
    public let authCallback: AuthCallback?
    /**
     * For development or non-default production environments.
     * Allows a non-default Ably environment to be used such as 'sandbox'.
     */
    public var environment: String?
    
    /**
     Connect to Ably using basic authentication (API Key)
     
     - Parameters:
        - apiKey: API key string obtained from application dashboard.
        - clientId: Optional identifier to be assigned to this client.
        - authCallback: A callback that will be used to authenticate with Ably, including at initial connection and for renewing an expired token.
        - remainPresentForMilliseconds: Specifies for how long should the SDK remain present in a channel when the connection is gone. For more details please see https://ably.com/docs/realtime/presence#unstable-connections
     */
    private init(apiKey: String?,
                 clientId: String?,
                 authCallback: AuthCallback?,
                 remainPresentForMilliseconds: Int?) {
        self.apiKey = apiKey
        self.clientId = clientId
        self.authCallback = authCallback
        self.remainPresentForMilliseconds = remainPresentForMilliseconds
    }
    
    // TODO make clientId optional [RSA7b2], and use the clientId provided in the auth callback. Pending ably-cocoa: https://github.com/ably/ably-cocoa/issues/1126
    /**
     Connect to Ably with authCallback authentication, where the authCallback is passed a [TokenRequest]
     
     - Parameters:
        - authCallbackExpectingTokenRequest: A closure which generates a token request, token details or token string when
        given token parameters.
        - clientId: Optional identifier to be assigned to this client.
     */
    @available(*, deprecated,
                message: "The ability to specify a client ID when using token-based authentication has been deprecated. You should use init(authCallback:) instead, which will use the client ID contained in the fetched token.",
                renamed: "init(authCallback:)")
    public convenience init(clientId: String,
                            authCallback: @escaping AuthCallback,
                            remainPresentForMilliseconds: Int? = nil) {
        self.init(apiKey: nil,
                  clientId: clientId,
                  authCallback: authCallback,
                  remainPresentForMilliseconds: remainPresentForMilliseconds)
    }
    
    public convenience init(
                            authCallback: @escaping AuthCallback,
                            remainPresentForMilliseconds: Int? = nil) {
        self.init(apiKey: nil,
                  clientId: nil,
                  authCallback: authCallback,
                  remainPresentForMilliseconds: remainPresentForMilliseconds)
    }
    
    public convenience init(apiKey: String,
                            clientId: String? = nil,
                            remainPresentForMilliseconds: Int? = nil) {
        self.init(apiKey: apiKey,
                  clientId: clientId,
                  authCallback: nil,
                  remainPresentForMilliseconds: remainPresentForMilliseconds)
    }
}
