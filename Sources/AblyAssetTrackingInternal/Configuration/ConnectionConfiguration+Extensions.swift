import Ably
import AblyAssetTrackingCore

extension ConnectionConfiguration {
    
    /**
     Create ClientOptions for Ably SDK, to be passed to Ably Client
     */
    public func getClientOptions(logHandler: InternalARTLogHandler, remainPresentForMilliseconds: Int?, host: Host?) -> ARTClientOptions {
        let clientOptions = ARTClientOptions()
        if let clientId {
            clientOptions.clientId = clientId
        }
        
        if let authCallback {
            clientOptions.authCallback = createAuthCallback(authCallback)
        } else {
            clientOptions.key = apiKey
        }
        clientOptions.logLevel = .verbose
        clientOptions.logHandler = logHandler
        
        clientOptions.agents = Agents.libraryAgents.ablyCocoaAgentsDictionary
        
        if let environment {
            clientOptions.environment = environment
        }
        
        if let remainPresentForMilliseconds {
            let remainPresentForStringifiable = ARTStringifiable.withNumber(remainPresentForMilliseconds as NSNumber)
            clientOptions.transportParams = ["remainPresentFor": remainPresentForStringifiable]
        }

        if let host {
            clientOptions.realtimeHost = host.realtimeHost
            clientOptions.port = host.port
            clientOptions.tls = host.tls
        }

        return clientOptions
    }
    
    /**
     Wraps the ARTAuthCallback into a AuthCallback without dependency on Ably-cocoa, by
     receiving Ably types and converting it into Ably Asset Tracking Types,
     and finally converting the output of the callback back into ART types to pass back into Ably-cocoa.
     */
    private func createAuthCallback(_ authCallback: @escaping AuthCallback) -> (ARTTokenParams, @escaping (ARTTokenDetailsCompatible?, NSError?) -> Void?) -> Void {
        func authCallbackWrapper(artTokenParams: ARTTokenParams, callback: @escaping (ARTTokenDetailsCompatible?, NSError?) -> Void?) {
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
}
