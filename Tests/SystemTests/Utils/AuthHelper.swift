//
//  File.swift
//  
//
//  Created by Łukasz Szyszkowski on 16/08/2021.
//

import Foundation
import AblyAssetTrackingCore
import Ably
import XCTest

class AuthHelper {
    func requestToken(options: ARTClientOptions, clientId: String? = nil) -> TokenDetails? {
        var requestCompleted = false
        var fetchedTokenDetails: TokenDetails?
        let client = ARTRest(options: options)
        let tokenParams = ARTTokenParams(clientId: clientId)
        
        client.auth.requestToken(tokenParams, with: nil) { tokenDetails, error in
            if let error = error {
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
