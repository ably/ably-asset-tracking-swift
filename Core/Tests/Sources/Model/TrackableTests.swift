import XCTest
import CoreLocation
@testable import Core

class TrackableTests: XCTestCase {
    private var trackables: Set<Trackable> = []
    
    override func setUpWithError() throws {
        trackables = []
        
        let trackable1 = Trackable(id: "1", destination: CLLocationCoordinate2D(latitude: 1, longitude: 1))
        let trackable2 = Trackable(id: "2", destination: CLLocationCoordinate2D(latitude: 2, longitude: 2))
        let trackable3 = Trackable(id: "3", destination: CLLocationCoordinate2D(latitude: 3, longitude: 3))
        
        trackables.insert(trackable1)
        trackables.insert(trackable2)
        trackables.insert(trackable3)
    }
    
    func test_TrackableComparision_ShouldBeEqual() {
        let givenTrackable = Trackable(id: "1")
        let trackableToCompare = trackables.first(where: { $0.id == "1"})
        
        XCTAssertNil(givenTrackable.destination)
        XCTAssertNotNil(trackableToCompare?.destination)
        
        XCTAssertTrue(givenTrackable.isEqual(trackableToCompare))
    }
    
    func test_TrackablesContainsTrackable_ShouldContain() {
        let givenTrackable = Trackable(id: "1")
        XCTAssertTrue(trackables.contains(givenTrackable))
    }
    
    func test_TrackablesContainsTrackable_ShouldNotContain() {
        let givenTrackable = Trackable(id: "Unknown id")
        XCTAssertFalse(trackables.contains(givenTrackable))
    }
}
