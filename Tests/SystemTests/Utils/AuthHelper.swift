import Foundation
import AblyAssetTrackingCore
import Ably
import XCTest

class AuthHelper {
    func requestToken(options: ARTClientOptions, tokenParams: ARTTokenParams = ARTTokenParams(clientId: nil)) -> TokenDetails? {
        var requestCompleted = false
        var fetchedTokenDetails: TokenDetails?
        let client = ARTRest(options: options)
        
        client.auth.requestToken(tokenParams, with: nil) { tokenDetails, error in
            if let error {
                XCTFail("TokenDetails request failed with error: \(error)")
            } else {
                fetchedTokenDetails = tokenDetails?.asTokenDetails()
            }
          
            requestCompleted = true
        }
        
        while !requestCompleted {
            CFRunLoopRunInMode(CFRunLoopMode.defaultMode, CFTimeInterval(0.1), false)
        }
        
        return fetchedTokenDetails
    }
}
