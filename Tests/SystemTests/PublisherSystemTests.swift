import XCTest
import AblyAssetTrackingPublisher

final class PublisherSystemTests: XCTestCase {

    func test_addTrackable_thenRemoveIt_thenAddAnotherTrackableWithSameId() throws {
        let connectionConfiguration = ConnectionConfiguration(apiKey: Secrets.ablyApiKey, clientId: UUID().uuidString)
        let resolution = Resolution(accuracy: .balanced, desiredInterval: 5000, minimumDisplacement: 100)
        
        let publisher = try PublisherFactory.publishers()
            .connection(connectionConfiguration)
            .mapboxConfiguration(MapboxConfiguration(mapboxKey: Secrets.mapboxAccessToken))
            .resolutionPolicyFactory(DefaultResolutionPolicyFactory(defaultResolution: resolution))
            .start()
        
        let trackable = Trackable(id: UUID().uuidString)
        
        let firstAddExpectation = expectation(description: "First add trackable call succeeds")
        publisher.add(trackable: trackable) { result in
            switch result {
            case .success:
                firstAddExpectation.fulfill()
            case .failure(let error):
                XCTFail("First add trackable call failed: \(error)")
            }
        }
        
        waitForExpectations(timeout: 10)
        
        let removeExpectation = expectation(description: "Remove trackable call succeeds")
        publisher.remove(trackable: trackable) { result in
            switch result {
            case .success:
                removeExpectation.fulfill()
            case .failure(let error):
                XCTFail("Remove trackable call failed: \(error)")
            }
        }
        
        waitForExpectations(timeout: 10)
        
        let secondAddExpectation = expectation(description: "Second add trackable call succeeds")
        publisher.add(trackable: trackable) { result in
            switch result {
            case .success:
                secondAddExpectation.fulfill()
            case .failure(let error):
                XCTFail("Second add trackable call failed: \(error)")
            }
        }
        
        waitForExpectations(timeout: 10)
    }
}
