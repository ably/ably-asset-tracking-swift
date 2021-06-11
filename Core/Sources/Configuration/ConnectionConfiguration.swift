import Ably

public enum AuthResult {
    case jwt(String)
    case tokenRequest(TokenRequest)
    case tokenDetails(TokenDetails)
}

public typealias Token = String
public typealias AuthCallback = (TokenParams, @escaping (Result<AuthResult, Error>) -> Void) -> Void

public class ConnectionConfiguration: NSObject {
    private let apiKey: String?
    private let clientId: String?
    private let authCallback: AuthCallback?

    /**
     Connect to Ably using basic authentication (API Key)
     - Parameters:
       - apiKey: API key string obtained from application dashboard.
       - clientId: Optional identifier to be assigned to this client.
         - authCallback:
     */
    private init(apiKey: String?,
                clientId: String?,
                authCallback: AuthCallback?) {
        self.apiKey = apiKey
        self.clientId = clientId
        self.authCallback = authCallback
    }

    // TODO make clientId optional [RSA7b2], and use the clientId provided in the auth callback. Pending ably-cocoa: https://github.com/ably/ably-cocoa/issues/1126
    /**
     Connect to Ably with authCallback authentication, where the authCallback is passed a [TokenRequest]

     - Parameters:
       - authCallbackExpectingTokenRequest: A closure which generates a token request, token details or token string when
        given token parameters.
       - clientId: Optional identifier to be assigned to this client.
     */
    public convenience init(clientId: String? = nil, authCallback: @escaping AuthCallback) {
        self.init(apiKey: nil,
                  clientId: clientId,
                  authCallback: authCallback)
    }

    public convenience init(apiKey: String, clientId: String? = nil) {
        self.init(apiKey: apiKey,
                  clientId: clientId,
                  authCallback: nil)
    }

    func getClientOptions() -> ARTClientOptions {
        let clientOptions = ARTClientOptions()
        if let clientId = clientId {
            clientOptions.clientId = clientId
        }

        if let authCallback = authCallback {
            clientOptions.authCallback = createAuthCallbackTranslator(authCallback)
            return clientOptions
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
    private func createAuthCallbackTranslator(_ authCallback: @escaping AuthCallback) -> (ARTTokenParams, @escaping (ARTTokenDetailsCompatible?, NSError?) -> ()?) -> () {
        func authCallbackTranslator(artTokenParams: ARTTokenParams, callback: @escaping (ARTTokenDetailsCompatible?, NSError?) -> Void?) -> Void {
            let tokenParams = artTokenParams.toTokenParams()
            // TODO use a Result<Success, CustomError> type instead
            authCallback(tokenParams, { (result: Result<AuthResult, Error>) -> Void in
                switch result {
                case .success(.jwt(let jwt)):
                    callback(NSString(utf8String: jwt), nil)
                    return
                case .success(.tokenRequest(let tokenRequest)):
                    callback(tokenRequest.toARTTokenRequest(), nil)
                    return
                case .success(.tokenDetails(let tokenDetails)):
                    callback(tokenDetails.toARTTokenDetails(), nil)
                case .failure(let error as NSError):
                    callback(nil, error)
                    return
                }
            })
        }

        return authCallbackTranslator
    }
}
