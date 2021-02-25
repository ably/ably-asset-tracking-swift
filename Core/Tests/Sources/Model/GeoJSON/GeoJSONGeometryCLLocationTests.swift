import XCTest
import CoreLocation
@testable import Core

class GeoJSONGeometryCLLocationTests: XCTestCase {
    
    func testGeoJsonGeometryFromLocation_CheckValues() throws {
        let latitude = 1.0
        let longitude = 2.0
        let altitude = 3.0
        
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let location = CLLocation(coordinate: coordinate, altitude: altitude, horizontalAccuracy: 1.0, verticalAccuracy: 1.0, timestamp: Date())
        
        let geometry = try GeoJSONGeometry(location: location)
        
        XCTAssertEqual(geometry.latitude, latitude)
        XCTAssertEqual(geometry.longitude, longitude)
        XCTAssertEqual(geometry.altitude, altitude)
    }
    
    // MARK: Longitude
    func testGeoJsonGeometryFromLocation_Longitude_OutOfRange_Below() throws {
        let location = CLLocation(latitude: 10.0, longitude: -181.0)
        XCTAssertThrowsError(try GeoJSONGeometry(location: location))
    }

    func testGeoJsonGeometryFromLocation_Longitude_OutOfRange_Above() throws {
        let location = CLLocation(latitude: 10.0, longitude: 181.0)
        XCTAssertThrowsError(try GeoJSONGeometry(location: location))
    }

    func testGeoJsonGeometryFromLocation_Longitude_InRange() throws {
        let location = CLLocation(latitude: 10.0, longitude: 100.0)
        XCTAssertNoThrow(try GeoJSONGeometry(location: location))
    }

    // MARK: Latitude
    func testGeoJsonGeometryFromLocation_Latitude_OutOfRange_Below() throws {
        let location = CLLocation(latitude: -95.0, longitude: 100.0)
        XCTAssertThrowsError(try GeoJSONGeometry(location: location))
    }

    func testGeoJsonGeometryFromLocation_Latitude_OutOfRange_Above() throws {
        let location = CLLocation(latitude: -95.0, longitude: 100.0)
        XCTAssertThrowsError(try GeoJSONGeometry(location: location))
    }

    func testGeoJsonGeometryFromLocation_Latitude_InRange() throws {
        let location = CLLocation(latitude: 10.0, longitude: 100.0)
        XCTAssertNoThrow(try GeoJSONGeometry(location: location))
    }
}
