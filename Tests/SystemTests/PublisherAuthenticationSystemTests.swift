import Foundation
import XCTest
import AblyAssetTrackingCore
import AblyAssetTrackingPublisher
import CoreLocation

class PublisherAuthenticationSystemTests: XCTestCase {
    
//    private let ABLY_API_KEY = Bundle.main.infoDictionary!["ABLY_API_KEY"] as! String
//    private let ABLY_API_KEY = ProcessInfo.processInfo.environment["ABLY_API_KEY"]!
//    private let MAPBOX_ACCESS_TOKEN = Bundle.main.infoDictionary!["MAPBOX_ACCESS_TOKEN"] as! String
//    private let MAPBOX_ACCESS_TOKEN = ProcessInfo.processInfo.environment["MAPBOX_ACCESS_TOKEN"]!

    override func setUpWithError() throws {
//        let dic = ProcessInfo.processInfo.environment
//        print("Ably environment var is: \(Secrets.ablyApiKey)")
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testPublisherConnectsWithApiKey() throws {
        let expectation = self.expectation(description: "Publisher.track completes")
        
        // When a user connects using basic authentication/ API key
        let connectionConfiguration = ConnectionConfiguration(apiKey: Secrets.ablyApiKey, clientId: "Test Publisher")
        
        let resolution = Resolution(accuracy: .balanced, desiredInterval: 5000, minimumDisplacement: 100)
        let publisher = try! PublisherFactory.publishers()
            .connection(connectionConfiguration)
            .mapboxConfiguration(MapboxConfiguration(mapboxKey: Secrets.mapboxAccessToken))
            .log(LogConfiguration())
            .locationSource(LocationSource(locationSource: [CLLocation(latitude: 0.0, longitude: 0.0)]))
            .routingProfile(.driving)
            .delegate(PublisherTestDelegate())
            .resolutionPolicyFactory(DefaultResolutionPolicyFactory(defaultResolution: resolution))
            .start() // Doesn't start publishing, its just a `build()` publisher call.

        // TODO check that connection is made/ Await successfully connection callback with an expectation
        // Here, I am creating a trackable instead of just checking the connection, because there doesn't
        // seem to be a way to check that the client is connected to Ably.
        let trackable = Trackable(id: "Trackable ID")
        publisher.track(trackable: trackable) { result in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5) { error in
            guard error == nil else {
                XCTFail("Error \(error.debugDescription)")
                return
            }
        }
            
        let stopExpectation = self.expectation(description: "Publisher stops")
        publisher.stop { result in
            switch result {
            case .success:
                stopExpectation.fulfill()
            case .failure(let error):
                XCTFail("Publisher failed to stop, error: \(error)")
            }
        }
        waitForExpectations(timeout: 5)
    }

//    func testPublisherConnectsWithTokenRequest() throws {
//        // Expectations
//        let authCallbackCalledExpectation = self.expectation(description: "AuthCallback is called")
//        let stopExpectation = self.expectation(description: "Publisher stops")
//
//        // When a user configures an AuthCallback
//        let connectionConfiguration = ConnectionConfiguration(clientId: "My client id") { tokenParams, authResultHandler in
//            // Here, users should make a network request to their auth servers, where their servers create the tokenRequest.
//            // To emulate this, we use the api key to create a tokenRequest on the client side.
//            let keyTokens = Secrets.ablyApiKey.split(separator: ":")
//            let keyName = String(keyTokens[0])
//            let keySecret = String(keyTokens[1])
//            let timestampEpochInMilliseconds = Int(tokenParams.timestamp!.timeIntervalSince1970 * 1000)
//            var hmacComponents = [keyName,
//                        tokenParams.ttl != nil ? String(tokenParams.ttl!) : "",
//                        tokenParams.capability ?? "",
//                        tokenParams.clientId ?? "",
//                        String(timestampEpochInMilliseconds),
//                        "Random nonce"
//            ].joined(separator: "\n")
//            hmacComponents.append("\n")
//
//            // https://ably.com/documentation/rest-api/token-request-spec#hmac
//            // perform hmac-sha-256 on hmacComponents, then base64 encode it.
//            let hmac = base64encode(hmacComponents) // This function doesn't exist yet
//            print("HMAC is \(hmac)")
//
//            let tokenRequest = TokenRequest(keyName: keyName,
//                         clientId: tokenParams.clientId,
//                         capability: tokenParams.capability,
//                         timestamp: timestampEpochInMilliseconds,
//                         nonce: "Random nonce",
//                         mac: hmac
//            )
//            authCallbackCalledExpectation.fulfill()
//            authResultHandler(.success(.tokenRequest(tokenRequest)))
//        }
//
//        let resolution = Resolution(accuracy: .balanced, desiredInterval: 5000, minimumDisplacement: 100)
//        let publisher = try! PublisherFactory.publishers()
//            .connection(connectionConfiguration)
//            .mapboxConfiguration(MapboxConfiguration(mapboxKey: Secrets.mapboxAccessToken))
//            .log(LogConfiguration())
//            .locationSource(LocationSource(locationSource: [CLLocation(latitude: 0.0, longitude: 0.0)]))
//            .routingProfile(.driving)
//            .delegate(PublisherTestDelegate())
//            .resolutionPolicyFactory(DefaultResolutionPolicyFactory(defaultResolution: resolution))
//            .start() // Doesn't start publishing, its just a `build()` publisher call.
//
//        // Then the user is able to connect to Ably
//        waitForExpectations(timeout: 5)
//        // TODO check that connection is made/ Await successfully connection callback with an expectation
//        // Here, I am creating a trackable instead of just checking the connection, because there doesn't
//        // seem to be a way to check that the client is connected to Ably.
//        let trackable = Trackable(id: "Trackable ID")
//        publisher.track(trackable: trackable) { _ in }
//
//        waitForExpectations(timeout: 5) { error in
//            guard error == nil else {
//                XCTFail("Error \(error.debugDescription)")
//                return
//            }
//        }
//
//        publisher.stop { result in
//            switch result {
//            case .success:
//                stopExpectation.fulfill()
//            case .failure(let error):
//                XCTFail("Publisher failed to stop, error: \(error)")
//            }
//        }
//        waitForExpectations(timeout: 5)
//    }
    
    func testPublisherConnectsWithTokenDetails() throws {
        
    }
    
    func testPublisherConnectsWithTokenString() throws {
        
    }
    
    func testPublisherConnectsWithJWT() throws {
        // TODO build a JWT here using the API key, and pass the JWT to ably-client.
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
