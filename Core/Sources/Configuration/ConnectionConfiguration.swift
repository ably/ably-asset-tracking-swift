import Ably

/**
 params:
 - ARTTokenParams: use these to generate an object to be passed to the callback
 - AuthCallbackAuthCallback: callback you should call to provide Ably with Token Request, Token Details, Token string
 */
//public typealias AuthCallback = (TokenParams) -> TokenRequest
//private typealias ARTAuthCallback = (ARTTokenParams, (ARTTokenDetailsCompatible, NSError) -> Void) -> Void

public class AuthCallback: NSObject {
    typealias TokenRequestHandler = (TokenRequest?, NSError?) -> Void
    let callback: (TokenParams, @escaping TokenRequestHandler) -> Void

    public init(callback: @escaping (TokenParams, @escaping (TokenRequest?, NSError?) -> Void) -> Void) {
        self.callback = callback
    }
}

public class ConnectionConfiguration: NSObject {
    private let apiKey: String?
    private let clientId: String?
    private let authCallback: AuthCallback?
//    private let authUrl: AuthURLConfiguration?

    /**
     Connect to Ably using basic authentication (API Key)
     - Parameters:
       - apiKey: API key string obtained from application dashboard.
       - clientId: Optional identifier to be assigned to this client.
     */
    @objc
    public init(apiKey: String, clientId: String) {
        self.apiKey = apiKey
        self.clientId = clientId
        authCallback = nil
//        authUrl = nil
    }

    /**
     Connect to Ably with authCallback authentication

     - Parameters:
       - authCallback: A closure which generates a token request, token details or token string when
        given token parameters.
       - clientId: Optional identifier to be assigned to this client.
     */
    @objc
    // TODO make clientId optional [RSA7b2], and use the clientId provided in the auth callback.
    // It looks like ably-cocoa doesn't support this.
    public init(clientId: String? = nil, authCallback: AuthCallback?) {
        apiKey = nil
        self.clientId = clientId
        self.authCallback = authCallback
//        authUrl = nil
    }

//    /**
//    Connect to Ably with authURL authentication
//
//     - Parameters:
//       - authUrl: A URL that the library may use to obtain a fresh token, one of: an Ably Token string (in plain text
//        format); a signed TokenRequest ; a TokenDetails (in JSON format); an Ably JWT. For example, this can be
//          used by a client to obtain signed Ably TokenRequests from an application server.
//       - clientId: Optional identifier to be assigned to this client.
//     */
//    @objc
//    // TODO implement AuthURLConfiguration, which can take the relevant authentication client options
//    public init(authUrl: AuthURLConfiguration, clientId: String? = nil) {
//        apiKey = nil
//        self.clientId = clientId
//        authCallback = nil
//        self.authUrl = authUrl
//    }

    func getClientOptions() -> ARTClientOptions {
        let clientOptions = ARTClientOptions()
        if let clientId = clientId {
            clientOptions.clientId = clientId
        }

        if let authCallback = authCallback {
            clientOptions.authCallback = createAuthCallbackTranslator(authCallback)
            return clientOptions
//        } else if let authUrl = authUrl {
//            clientOptions.authUrl = authUrl
//            return clientOptions
        } else {
            clientOptions.key = apiKey
        }
        return clientOptions
    }

    /**
     Translates the ARTAuthCallback into a AuthCallback without dependency on Ably-cocoa, by
      receiving ART (Ably Realtime namespace) types and converting it into Ably Asset Tracking Types,
       and finally converting the output of the callback back into ART types to pass back into Ably-cocoa.
     */
    // being a ARTAuthCallback (it receives ART types, and outputs ART types (in the callback)).
    private func createAuthCallbackTranslator(_ authCallback: AuthCallback) -> (ARTTokenParams, @escaping (ARTTokenDetailsCompatible?, NSError?) -> ()?) -> () {
        func authCallbackTranslator(artTokenParams: ARTTokenParams, callback: @escaping (ARTTokenDetailsCompatible?, NSError?) -> Void?) -> Void {
            let tokenParams = artTokenParams.toTokenParams()
            // TODO use a Result<Success, CustomError> type instead
            authCallback.callback(tokenParams, { (tokenRequest: TokenRequest?, error: NSError?) -> Void in
                guard let tokenRequest = tokenRequest else {
                    callback(nil, error)
                    return
                }
                callback(tokenRequest.toARTTokenRequest(), nil)
            })
        }

        return authCallbackTranslator
    }
}
