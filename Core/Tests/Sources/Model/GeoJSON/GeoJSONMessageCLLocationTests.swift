import CoreLocation
import XCTest

@testable import Core

class GeoJsonMessageCLLocationTests: XCTestCase {
    private func getLocation(isValid: Bool? = nil, timestamp: Date? = nil) -> CLLocation {
        let coordinate = CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0)
        
        if #available(iOS 13.4, *) {
            return CLLocation(coordinate: coordinate,
                              altitude: 1.0,
                              horizontalAccuracy: isValid ?? true ? 2.0 : -2.0,
                              verticalAccuracy: 3.0,
                              course: 4.0,
                              courseAccuracy: 5.0,
                              speed: 6.0,
                              speedAccuracy: 7.0,
                              timestamp: timestamp ?? Date())
        } else {
            return CLLocation(coordinate: coordinate,
                              altitude: 1.0,
                              horizontalAccuracy: isValid ?? true ? 2.0 : -2.0,
                              verticalAccuracy: 3.0,
                              course: 4.0,
                              speed: 6.0,
                              timestamp: timestamp ?? Date())
        }
    }
    
    func testGeoJsonMessageFromCLLocation_InvalidLocation() {
        let location = getLocation(isValid: false)
        XCTAssertThrowsError(try GeoJSONMessage(location: location))
    }
    
    func testGeoJsonMessageFromCLLocation_ValidLocation() {
        let location = getLocation(isValid: true)
        XCTAssertNoThrow(try GeoJSONMessage(location: location))
    }
    
    func testGeoJsonMessageFromCLLocation_CheckValues() throws {
        let timestamp = Date()
        let location = getLocation(isValid: true, timestamp: timestamp)
        let message = try GeoJSONMessage(location: location)
        
        XCTAssertEqual(message.type, .feature)
        
        XCTAssertEqual(message.geometry.longitude, 1.0)
        XCTAssertEqual(message.geometry.latitude, 1.0)
        XCTAssertEqual(message.geometry.altitude, 1.0)
        
        XCTAssertEqual(message.properties.accuracyVertical, 3.0)
        XCTAssertEqual(message.properties.accuracyHorizontal, 2.0)
        XCTAssertEqual(message.properties.speed, 6.0)
        XCTAssertEqual(message.properties.time, timestamp.timeIntervalSince1970)
        
        if #available(iOS 13.4, *) {
            XCTAssertEqual(message.properties.accuracySpeed, 7.0)
            XCTAssertEqual(message.properties.accuracyBearing, 5.0)
            XCTAssertEqual(message.properties.bearing, 4.0)
        } else {
            XCTAssertNil(message.properties.accuracySpeed)
            XCTAssertNil(message.properties.accuracyBearing)
            XCTAssertNil(message.properties.bearing)
        }
    }
}
