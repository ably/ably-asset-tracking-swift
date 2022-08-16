import Foundation
import XCTest
import AblyAssetTrackingCore
import AblyAssetTrackingSubscriber
import CoreLocation
import Ably

class SubscriberAuthenticationSystemTests: XCTestCase {
    
    private let clientId: String = {
        "Test-Subscriber_\(UUID().uuidString)"
    }()

    func testSubscriberConnectsWithApiKey() throws {
        let connectionConfiguration = ConnectionConfiguration(apiKey: Secrets.ablyApiKey, clientId: clientId)
        
        testSubscriberConnection(configuration: connectionConfiguration)
    }

    func testSubscriberConnectsWithTokenRequest() throws {
        let authCallbackCalledExpectation = self.expectation(description: "Auth Callback complete")
        // When a user configures an AuthCallback
        let connectionConfiguration = ConnectionConfiguration(clientId: clientId, authCallback: { tokenParams, authResultHandler in
            // Here, users should make a network request to their auth servers, where their servers create the tokenRequest.
            // To emulate this, we use the api key to create a tokenRequest on the client side.
            let keyTokens = Secrets.ablyApiKey.split(separator: ":")
            let keyName = String(keyTokens[0])
            let keySecret = String(keyTokens[1])
            let currentTimestamp = tokenParams.timestamp ?? Date()
            let timestampEpochInMilliseconds = Int(currentTimestamp.timeIntervalSince1970 * 1000)
            var hmacComponents = [keyName,
                        tokenParams.ttl != nil ? String(tokenParams.ttl!) : "",
                        tokenParams.capability ?? "",
                        tokenParams.clientId ?? "",
                        String(timestampEpochInMilliseconds),
                        "Random nonce"
            ].joined(separator: "\n")
            hmacComponents.append("\n")

            let hmac = hmacComponents.hmac(key: keySecret)

            let tokenRequest = TokenRequest(keyName: keyName,
                         clientId: tokenParams.clientId,
                         capability: tokenParams.capability,
                         timestamp: timestampEpochInMilliseconds,
                         nonce: "Random nonce",
                         mac: hmac
            )
            authCallbackCalledExpectation.fulfill()
            authResultHandler(.success(.tokenRequest(tokenRequest)))
        })

        testSubscriberConnection(configuration: connectionConfiguration)
    }
    
    func testSubscriberConnectsWithTokenDetails() throws {
        let fetchedTokenDetails = AuthHelper().requestToken(
            options: RestHelper.clientOptions(true, key: Secrets.ablyApiKey),
            tokenParams: ARTTokenParams(clientId: clientId)
        )
        
        let connectionConfiguration = ConnectionConfiguration(clientId: clientId, authCallback: { tokenParams, resultHandler in
            guard let tokenDetails = fetchedTokenDetails else {
                XCTFail("TokenDetails doesn't exist")
                return
            }
            
            resultHandler(.success(.tokenDetails(tokenDetails)))
        })
        
        testSubscriberConnection(configuration: connectionConfiguration)
    }
    
    func testSubscriberConnectsWithTokenString() throws {
        let keyTokens = Secrets.ablyApiKey.split(separator: ":")
        let keyName = String(keyTokens[0])
        
        let fetchedTokenString = AuthHelper().requestToken(
            options: RestHelper.clientOptions(true, key: Secrets.ablyApiKey),
            tokenParams: ARTTokenParams(clientId: keyName)
        )?.token
                
        let connectionConfiguration = ConnectionConfiguration(clientId: keyName, authCallback: { tokenParams, resultHandler in
            guard let tokenString = fetchedTokenString else {
                XCTFail("TokenDetails doesn't exist")
                return
            }
            
            resultHandler(.success(.jwt(tokenString)))
        })
        
        testSubscriberConnection(configuration: connectionConfiguration)
    }
    
    func testSubscriberConnectsWithJWT() throws {
        guard let jwtToken = JWTHelper().getToken(clientId: clientId) else {
            XCTFail("Create JWT failed")
            return
        }
        
        let connectionConfiguration = ConnectionConfiguration(clientId: clientId) { tokenParams, resultHandler in
            resultHandler(.success(.jwt(jwtToken)))
        }
        
        testSubscriberConnection(configuration: connectionConfiguration)
    }
    
    private func createSubscriberBuilder(connectionConfiguration: ConnectionConfiguration) -> SubscriberBuilder {
        let resolution = Resolution(accuracy: .balanced, desiredInterval: 5000, minimumDisplacement: 100)
        return SubscriberFactory.subscribers()
            .connection(connectionConfiguration)
            .resolution(resolution)
            .trackingId("Trackable ID")
    }
    
    private func testSubscriberConnection(configuration: ConnectionConfiguration) {
        let subscriberStartExpectation = self.expectation(description: "Subscriber start expectation")
        let subscriber = createSubscriberBuilder(connectionConfiguration: configuration)
            .start { result in
                switch result {
                case .success: ()
                case .failure(let error):
                    XCTFail("Subscriber start failed with error: \(error)")
                }
                subscriberStartExpectation.fulfill()
            }
        waitForExpectations(timeout: 10.0)
    
        let resolutionCompletionExpectation = self.expectation(description: "Resolution completion expectation")
        let resolution = Resolution(accuracy: .balanced, desiredInterval: 1000, minimumDisplacement: 100)
        subscriber?.resolutionPreference(resolution: resolution, completion: { result in
            switch result {
            case .success: ()
            case .failure(let error):
                XCTFail("Resolution completion failed with error: \(error)")
            }
            resolutionCompletionExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 10.0)
        
        let subscriberStopExpectation = self.expectation(description: "Subscriber stop expectation")
        subscriber?.stop(completion: { result in
            subscriberStopExpectation.fulfill()
        })
        waitForExpectations(timeout: 10.0)
    }
}
