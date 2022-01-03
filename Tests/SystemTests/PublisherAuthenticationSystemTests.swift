import XCTest
import AblyAssetTrackingCore
import AblyAssetTrackingPublisher
import AblyAssetTrackingInternal
import CoreLocation
import Ably

class PublisherAuthenticationSystemTests: XCTestCase {

    private let publisherDelegate = PublisherTestDelegate()
    private let logConfiguration = LogConfiguration()
    private let clientId: String = {
        "Test-Publisher_\(UUID().uuidString)"
    }()

    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}
    
    func testPublisherConnectsWithApiKey() throws {
        // When a user connects using basic authentication/ API key
        let connectionConfiguration = ConnectionConfiguration(apiKey: Secrets.ablyApiKey, clientId: clientId)
        
        testPublisherTrack(configuration: connectionConfiguration)
    }

    func testPublisherConnectsWithTokenRequest() throws {
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

        testPublisherTrack(configuration: connectionConfiguration)
    }
    
    func testPublisherConnectsWithTokenDetails() throws {
        let keyTokens = Secrets.ablyApiKey.split(separator: ":")
        let keyName = String(keyTokens[0])
        
        let fetchedTokenDetails = AuthHelper().requestToken(
            options: RestHelper.clientOptions(true, key: Secrets.ablyApiKey),
            clientId: keyName
        )
        
        let connectionConfiguration = ConnectionConfiguration(clientId: keyName, authCallback: { tokenParams, resultHandler in
            guard let tokenDetails = fetchedTokenDetails else {
                XCTFail("TokenDetails doesn't exist")
                return
            }
            
            resultHandler(.success(.tokenDetails(tokenDetails)))
        })
        
        testPublisherTrack(configuration: connectionConfiguration)
    }
    
    func testPublisherConnectsWithTokenString() throws {
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
        
        testPublisherTrack(configuration: connectionConfiguration)
    }
    
    func testPublisherConnectsWithJWT() throws {
        guard let jwtToken = JWTHelper().getToken() else {
            XCTFail("Create JWT failed")
            return
        }
        
        let connectionConfiguration = ConnectionConfiguration { tokenParams, resultHandler in
            resultHandler(.success(.jwt(jwtToken)))
        }
        
        testPublisherTrack(configuration: connectionConfiguration)
    }
    
    private func testPublisherTrack(configuration: ConnectionConfiguration) {
        let resolution = Resolution(accuracy: .balanced, desiredInterval: 5000, minimumDisplacement: 100)
        let publisher = try! PublisherFactory.publishers()
            .connection(configuration)
            .mapboxConfiguration(MapboxConfiguration(mapboxKey: Secrets.mapboxAccessToken))
            .log(logConfiguration)
            .locationSource(LocationSource(locationSource: [CLLocation(latitude: 0.0, longitude: 0.0), CLLocation(latitude: 1.0, longitude: 1.0)]))
            .routingProfile(.driving)
            .delegate(publisherDelegate)
            .resolutionPolicyFactory(DefaultResolutionPolicyFactory(defaultResolution: resolution))
            .start() // Doesn't start publishing, its just a `build()` publisher call.

        // TODO check that connection is made/ Await successfully connection callback with an expectation
        // Here, I am creating a trackable instead of just checking the connection, because there doesn't
        // seem to be a way to check that the client is connected to Ably.
        let expectation = self.expectation(description: "Publisher.track completes")
        let trackable = Trackable(id: "Trackable ID")
        publisher.track(trackable: trackable) { _ in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10)

        let stopExpectation = self.expectation(description: "Publisher stops")
        publisher.stop { result in
            switch result {
            case .success:
                stopExpectation.fulfill()
            case .failure(let error):
                XCTFail("Publisher failed to stop, error: \(error)")
            }
        }

        waitForExpectations(timeout: 10)
    }
}

private class PublisherTestDelegate: PublisherDelegate {
    func publisher(sender: Publisher, didFailWithError error: ErrorInformation) {
        return
    }
    
    func publisher(sender: Publisher, didUpdateEnhancedLocation location: CLLocation) {
        return
    }
    
    func publisher(sender: Publisher, didChangeConnectionState state: ConnectionState, forTrackable trackable: Trackable) {
        return
    }
    
    func publisher(sender: Publisher, didUpdateResolution resolution: Resolution) {
        return
    }
}
