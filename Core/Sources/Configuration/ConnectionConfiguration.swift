import Ably

/**
 params:
 - ARTTokenParams: use these to generate an object to be passed to the callback
 - AuthCallbackAuthCallback: callback you should call to provide Ably with Token Request, Token Details, Token string
 */
//public typealias AuthCallback = (TokenParams) -> TokenRequest
//private typealias ARTAuthCallback = (ARTTokenParams, (ARTTokenDetailsCompatible, NSError) -> Void) -> Void

@objc
public class AuthCallback: NSObject {
    typealias TokenRequestHandler = (TokenRequest?, NSError?) -> Void
    let callback:  (TokenParams, @escaping TokenRequestHandler) -> Void

    public init(callback: @escaping (TokenParams, @escaping (TokenRequest?, NSError?) -> Void) -> Void) {
        self.callback = callback
    }
}

public class ConnectionConfiguration: NSObject {
    private let apiKey: String?
    private let clientId: String?
    private let authCallback: AuthCallback?
//    private let authURL: String?

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
//        authURL = nil
    }

    /**
     Connect to Ably with authCallback authentication

     - Parameters:
       - authCallback: A closure which generates a token request, token details or token string when
        given token parameters.
       - clientId: Optional identifier to be assigned to this client.
     */
    @objc
    public init(clientId: String? = nil, authCallback: AuthCallback?) {
        apiKey = nil
        self.clientId = clientId
        self.authCallback = authCallback
//        authURL = nil
    }

//    /**
//    Connect to Ably with authURL authentication
//
//     - Parameters:
//       - authURL: A URL that the library may use to obtain a fresh token, one of: an Ably Token string (in plain text
//        format); a signed TokenRequest ; a TokenDetails (in JSON format); an Ably JWT. For example, this can be
//          used by a client to obtain signed Ably TokenRequests from an application server.
//       - clientId: Optional identifier to be assigned to this client.
//     */
//    @objc
//    public init(authURL: String, clientId: String? = nil) {
//        apiKey = nil
//        self.clientId = clientId
//        authCallback = nil
//        self.authURL = authURL
//    }

    func getClientOptions() -> ARTClientOptions {
        let clientOptions = ARTClientOptions()
        if let clientId = clientId {
            clientOptions.clientId = clientId
        }

        if let authCallback = authCallback {
            // being a ARTAuthCallback:
            func authCallbackTranslator(artTokenParams: ARTTokenParams, callback: @escaping (ARTTokenDetailsCompatible?, NSError?) -> Void?) -> Void {
                // when ARTAuthCallback from Ably comes in, convert it into AuthCallback
                let tokenParams = artTokenParams.toTokenParams()
                do {
                    try authCallback.callback(tokenParams, { (tokenRequest: TokenRequest?, error: NSError?) -> Void in
                        guard error != nil else {
                            callback(nil, error)
                            return
                        }
                        // changing the first argument of the callback to something the SDK can use
                        callback(tokenRequest?.toARTTokenRequest(), nil)
                    })
                } catch {
                    callback(nil, error as NSError)
                }
            }

            clientOptions.authCallback = authCallbackTranslator
            return clientOptions
        } else {
            clientOptions.key = apiKey
        }
        return clientOptions
    }

//    // Allows public API to be TokenDetailsCompatible, but internally converts that to ARTTokenDetailsCompatible
//    private func authCallbackCallbackTranslator(_ callback: @escaping (ARTTokenDetailsCompatible, NSError) -> Void) -> (TokenDetailsCompatible, NSError) -> Void {
//        func translated(tokenDetailsCompatible: TokenDetailsCompatible, error: NSError) -> Void {
//            let artTokenDetailsCompatible = tokenDetailsCompatible.toARTTokenDetails()
//            callback(artTokenDetailsCompatible, error)
//        }
//
//        return translated
//    }
}
