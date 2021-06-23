import Foundation
import XCTest
import AblyAssetTrackingCore
import AblyAssetTrackingSubscriber
import CoreLocation

class SubscriberAuthenticationSystemTests: XCTestCase {
    

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testPublisherConnectsWithApiKey() throws {
        
    }

    func testPublisherConnectsWithTokenRequest() throws {
        
    }
    
    func testPublisherConnectsWithTokenDetails() throws {
        
    }
    
    func testPublisherConnectsWithTokenString() throws {
        
    }
    
    func testPublisherConnectsWithJWT() throws {
        // TODO build a JWT here using the API key, and pass the JWT to ably-client.
    }
}

private class SubscriberTestDelegate: SubscriberDelegate {
    func subscriber(sender: Subscriber, didFailWithError error: ErrorInformation) {
        
    }
    
    func subscriber(sender: Subscriber, didUpdateEnhancedLocation location: CLLocation) {
        
    }
    
    func subscriber(sender: Subscriber, didChangeAssetConnectionStatus status: ConnectionState) {
        
    }
}
