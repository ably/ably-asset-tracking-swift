import Foundation
import CoreLocation
import XCTest
@testable import Core

class EnhancedLocationUpdateTests: XCTestCase {

    func testEnhancedLocationUpdateMessageDecodesNullBatteryLevel() throws {
        let location = CLLocation(latitude: 0.0, longitude: 0.0)
        let expected = try! EnhancedLocationUpdateMessage(locationUpdate: EnhancedLocationUpdate(location: location), batteryLevel: nil)
        
        let jsonString = try! expected.toJSONString()
        let actual: EnhancedLocationUpdateMessage = try! EnhancedLocationUpdateMessage.fromJSONString(jsonString)
        
        XCTAssertEqual(expected.batteryLevel, actual.batteryLevel)
        XCTAssertEqual(expected.type, actual.type)
        
// There are more things to XCTAssertEqual but you'll need to implement Equatable or start using Structs instead of classes.
//        XCTAssertEqual(expected.location, actual.location)
//        XCTAssertEqual(expected.intermediateLocations, expected.intermediateLocations)
    }
}
