import Ably
import AblyAssetTrackingCore

extension ConnectionConfiguration {

    /**
     Create ClientOptions for Ably SDK, to be passed to Ably Client
     */
    public func getClientOptions() -> ARTClientOptions {
        let clientOptions = ARTClientOptions()
        if let clientId = clientId {
            clientOptions.clientId = clientId
        }

        if let authCallback = authCallback {
            clientOptions.authCallback = createAuthCallbackWrapper(authCallback)
            return clientOptions
        } else if let authCallback = objcAuthCallback {
            clientOptions.authCallback = createObjCAuthCallbackWrapper(authCallback)
            return clientOptions
        } else {
            clientOptions.key = apiKey
        }
        return clientOptions
    }

    /**
     Wraps the ARTAuthCallback into a AuthCallback without dependency on Ably-cocoa, by
      receiving Ably types and converting it into Ably Asset Tracking Types,
       and finally converting the output of the callback back into ART types to pass back into Ably-cocoa.
     */
    // being a ARTAuthCallback (it receives ART types, and outputs ART types (in the callback)).
    private func createAuthCallbackWrapper(_ authCallback: @escaping AuthCallback) -> (ARTTokenParams, @escaping (ARTTokenDetailsCompatible?, NSError?) -> ()?) -> () {
        func authCallbackWrapper(artTokenParams: ARTTokenParams, callback: @escaping (ARTTokenDetailsCompatible?, NSError?) -> Void?) -> Void {
            let tokenParams = artTokenParams.toTokenParams()
            authCallback(tokenParams, { result in
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

        return authCallbackWrapper
    }
    
    private func createObjCAuthCallbackWrapper(_ authCallback: @escaping ObjCAuthCallback) -> (ARTTokenParams, @escaping (ARTTokenDetailsCompatible?, NSError?) -> ()?) -> () {
        func authCallbackWrapper(artTokenParams: ARTTokenParams, callback: @escaping (ARTTokenDetailsCompatible?, NSError?) -> Void?) -> Void {
            let tokenParams = artTokenParams.toTokenParams()
            authCallback(tokenParams, { authResult, error in
                if let error = error {
                    callback(nil, error as NSError)
                } else if let result = authResult {
                    switch result {
                    case let jwtResult as ObjcAuthResultJWT:
                        callback(NSString(utf8String: jwtResult.value), nil)
                    case let tokenRequestResult as ObjcAuthResultTokenRequest:
                        callback(tokenRequestResult.value.toARTTokenRequest(), nil)
                    case let tokenDetailsResult as ObjcAuthResultTokenDetails:
                        callback(tokenDetailsResult.value.toARTTokenDetails(), nil)
                    default:
                        fatalError("Unknown type")
                    }
                } else {
                    fatalError("The result callback must return one of the value: error or authResult.")
                }
            })
        }

        return authCallbackWrapper
    }

}
