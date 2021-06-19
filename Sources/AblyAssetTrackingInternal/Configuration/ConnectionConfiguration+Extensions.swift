import Ably
import AblyAssetTrackingCore

extension ConnectionConfiguration {

    public func getClientOptions() -> ARTClientOptions {
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
