import XCTest
import CoreLocation

@testable import Core

class GeoJSONPropertiesCLLocationTests: XCTestCase {
    private func getLocation(horizontalAccuracy: Double? = nil, accuracyVertical: Double? = nil, bearing: Double? = nil, accuracyBearing: Double? = nil, speed: Double? = nil, accuracySpeed: Double? = nil, timestamp: Date? = nil) -> CLLocation {
        let coordinate = CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0)
        
        if #available(iOS 13.4, *) {
            return CLLocation(coordinate: coordinate,
                              altitude: 1.0,
                              horizontalAccuracy: horizontalAccuracy ?? 2.0,
                              verticalAccuracy: accuracyVertical ?? 3.0,
                              course: bearing ?? 4.0,
                              courseAccuracy: accuracyBearing ?? 5.0,
                              speed: speed ?? 6.0,
                              speedAccuracy: accuracySpeed ?? 7.0,
                              timestamp: timestamp ?? Date())
        } else {
            return CLLocation(coordinate: coordinate,
                              altitude: 1.0,
                              horizontalAccuracy: horizontalAccuracy ?? 2.0,
                              verticalAccuracy: accuracyVertical ?? 3.0,
                              course: bearing ?? 4.0,
                              speed: speed ?? 5.0,
                              timestamp: timestamp ?? Date())
        }
    }
    
    // MARK: Horizontal accuracy
    
    func testGeoJsonPropertiesFromCLLocation_InvalidHorizontalAccuracy_LessThanZero() throws {
        let location = getLocation(horizontalAccuracy: -1.0)
        XCTAssertThrowsError(try GeoJSONProperties(location: location))
    }
    
    func testGeoJsonPropertiesFromCLLocation_ValidHorizontalAccuracy_EqualZero() throws {
        let location = getLocation(horizontalAccuracy: 0.0)
        XCTAssertNoThrow(try GeoJSONProperties(location: location))
    }
    
    func testGeoJsonPropertiesFromCLLocation_ValidHorizontalAccuracy() throws {
        let location = getLocation(horizontalAccuracy: 10.0)
        XCTAssertNoThrow(try GeoJSONProperties(location: location))
    }
    
    func testGeoJsonPropertiesFromCLLocation_ValidHorizontalAccuracy_CheckValue() throws {
        let horizontalAccuracy = 10.0
        let location = getLocation(horizontalAccuracy: horizontalAccuracy)
        let properties = try GeoJSONProperties(location: location)
        XCTAssertEqual(properties.accuracyHorizontal, horizontalAccuracy)
    }
    
    // MARK: Vertical accuracy
    
    func testGeoJsonPropertiesFromCLLocation_InvalidVerticalAccuracy() throws {
        let location = getLocation(accuracyVertical: -1.0)
        let properties = try GeoJSONProperties(location: location)
        XCTAssertNil(properties.accuracyVertical)
    }
    
    func testGeoJsonPropertiesFromCLLocation_ValidVerticalAccuracy() throws {
        let accuracyVertical = 10.0
        let location = getLocation(accuracyVertical: accuracyVertical)
        let properties = try GeoJSONProperties(location: location)
        XCTAssertEqual(properties.accuracyVertical, accuracyVertical)
    }
    
    // MARK: Bearing accuracy
    
    func testGeoJsonPropertiesFromCLLocation_InvalidBearingAccuracy() throws {
        let location = getLocation(accuracyBearing: -1.0)
        let properties = try GeoJSONProperties(location: location)
        XCTAssertNil(properties.accuracyBearing)
    }
    
    func testGeoJsonPropertiesFromCLLocation_ValidBearingAccuracy() throws {
        let accuracyBearing = 10.0
        let location = getLocation(accuracyBearing: accuracyBearing)
        let properties = try GeoJSONProperties(location: location)
        XCTAssertEqual(properties.accuracyBearing, accuracyBearing)
    }
    
    // MARK: Speed accuracy
    
    func testGeoJsonPropertiesFromCLLocation_InvalidSpeedAccuracy() throws {
        let location = getLocation(accuracySpeed: -1.0)
        let properties = try GeoJSONProperties(location: location)
        XCTAssertNil(properties.accuracySpeed)
    }
    
    func testGeoJsonPropertiesFromCLLocation_ValidSpeedAccuracy() throws {
        let accuracySpeed = 10.0
        let location = getLocation(accuracySpeed: accuracySpeed)
        let properties = try GeoJSONProperties(location: location)
        XCTAssertEqual(properties.accuracySpeed, accuracySpeed)
    }
    
    // MARK: Bearing
    
    func testGeoJsonPropertiesFromCLLocation_InvalidBearing() throws {
        let location = getLocation(bearing: -1.0)
        let properties = try GeoJSONProperties(location: location)
        XCTAssertNil(properties.bearing)
    }
    
    func testGeoJsonPropertiesFromCLLocation_ValidBearing() throws {
        let bearing = 10.0
        let location = getLocation(bearing: bearing)
        let properties = try GeoJSONProperties(location: location)
        XCTAssertEqual(properties.bearing, bearing)
    }
    
    // MARK: Speed
    
    func testGeoJsonPropertiesFromCLLocation_InvalidSpeed() throws {
        let location = getLocation(speed: -1.0)
        let properties = try GeoJSONProperties(location: location)
        XCTAssertNil(properties.speed)
    }
    
    func testGeoJsonPropertiesFromCLLocation_ValidSpeed() throws {
        let speed = 10.0
        let location = getLocation(speed: speed)
        let properties = try GeoJSONProperties(location: location)
        XCTAssertEqual(properties.speed, speed)
    }
    
    // MARK: Timestamp

    func testGeoJsonPropertiesFromCLLocation_Timestamp() throws {
        let timestamp = Date()
        let location = getLocation(timestamp: timestamp)
        let properties = try GeoJSONProperties(location: location)
        XCTAssertEqual(properties.time, timestamp.timeIntervalSince1970)
    }
}
