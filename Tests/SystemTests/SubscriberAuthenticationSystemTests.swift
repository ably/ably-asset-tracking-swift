import Foundation
import XCTest
import AblyAssetTrackingCore
import AblyAssetTrackingSubscriber
import CoreLocation

class SubscriberAuthenticationSystemTests: XCTestCase {
    
    private let logConfiguration = LogConfiguration()
    private let clientId: String = {
        "Test-Subscriber_\(UUID().uuidString)"
    }()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
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
            print("HMAC is \(hmac)\nKey: \(keySecret)")

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
            clientId: clientId
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
            clientId: keyName
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
    
    private func testSubscriberConnection(configuration: ConnectionConfiguration) {
        let subscriberDelegate = SubscriberTestDelegate()
        var resolution = Resolution(accuracy: .balanced, desiredInterval: 5000, minimumDisplacement: 100)
        let subscriberStartExpectation = self.expectation(description: "Subscriber start expectation")
        let subscriber = SubscriberFactory.subscribers()
            .connection(configuration)
            .resolution(resolution)
            .delegate(subscriberDelegate)
            .trackingId("Trackable ID")
            .log(logConfiguration)
            .start { result in
                switch result.enumUnwrap {
                case .success: ()
                case .failure(let error):
                    XCTFail("Subscriber start failed with error: \(error)")
                }
                subscriberStartExpectation.fulfill()
            }
        waitForExpectations(timeout: 10.0)
    
        let resolutionCompletionExpectation = self.expectation(description: "Resolution completion expectation")
        resolution = Resolution(accuracy: .balanced, desiredInterval: 1000, minimumDisplacement: 100)
        subscriber?.resolutionPreference(resolution: resolution, completion: { result in
            switch result.enumUnwrap {
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
    
    private class SubscriberTestDelegate: SubscriberDelegate {
        func subscriber(sender: Subscriber, didFailWithError error: ErrorInformation) {
            
        }
        
        func subscriber(sender: Subscriber, didUpdateEnhancedLocation location: CLLocation) {
            
        }
        
        func subscriber(sender: Subscriber, didChangeAssetConnectionStatus status: ConnectionState) {
            
        }
    }
}
