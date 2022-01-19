import XCTest
@testable import AblyAssetTrackingCore

class GeoJSONGeometryCLLocationTests: XCTestCase {
    
    func testGeoJsonGeometryFromLocation_CheckValues() throws {
        let latitude = 1.0
        let longitude = 2.0
        let altitude = 3.0
        
        let coordinate = LocationCoordinate(latitude: latitude, longitude: longitude)
        let location = Location(
            coordinate: coordinate,
            altitude: altitude,
            ellipsoidalAltitude: .zero,
            horizontalAccuracy: 1.0,
            verticalAccuracy: 1.0,
            course: .zero,
            courseAccuracy: .zero,
            speed: .zero,
            speedAccuracy: .zero,
            floorLevel: nil,
            timestamp: Date().timeIntervalSince1970
        )
        
        let geometry = try GeoJSONGeometry(location: location)
        
        XCTAssertEqual(geometry.latitude, latitude)
        XCTAssertEqual(geometry.longitude, longitude)
        XCTAssertEqual(geometry.altitude, altitude)
    }
    
    // MARK: Longitude
    func testGeoJsonGeometryFromLocation_Longitude_OutOfRange_Below() throws {
        let location = Location(
            coordinate: LocationCoordinate(
                latitude: 10.0,
                longitude: -181.0
            )
        )
        XCTAssertThrowsError(try GeoJSONGeometry(location: location))
    }

    func testGeoJsonGeometryFromLocation_Longitude_OutOfRange_Above() throws {
        let location = Location(
            coordinate:  LocationCoordinate(
                latitude: 10.0,
                longitude: 181.0
            )
        )
        XCTAssertThrowsError(try GeoJSONGeometry(location: location))
    }

    func testGeoJsonGeometryFromLocation_Longitude_InRange() throws {
        let location = Location(
            coordinate: LocationCoordinate(
                latitude: 10.0,
                longitude: 100.0
            )
        )
        XCTAssertNoThrow(try GeoJSONGeometry(location: location))
    }

    // MARK: Latitude
    func testGeoJsonGeometryFromLocation_Latitude_OutOfRange_Below() throws {
        let location = Location(
            coordinate: LocationCoordinate(
                latitude: -95.0,
                longitude: 100.0
            )
        )
        XCTAssertThrowsError(try GeoJSONGeometry(location: location))
    }

    func testGeoJsonGeometryFromLocation_Latitude_OutOfRange_Above() throws {
        let location = Location(
            coordinate: LocationCoordinate(
                latitude: -95.0,
                longitude: 100.0
            )
        )
        XCTAssertThrowsError(try GeoJSONGeometry(location: location))
    }

    func testGeoJsonGeometryFromLocation_Latitude_InRange() throws {
        let location = Location(
            coordinate: LocationCoordinate(
                latitude: 10.0,
                longitude: 100.0
            )
        )
        XCTAssertNoThrow(try GeoJSONGeometry(location: location))
    }
}
