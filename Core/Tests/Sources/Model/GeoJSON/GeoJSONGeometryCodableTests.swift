import XCTest
@testable import Core

class GeoJSONGeometryCodableTests: XCTestCase {
    private func geometryJsonForCoordinates(_ coordinates: String) -> String {
        return """
            {
                "type": "Point",
                "coordinates": \(coordinates)
            }
        """
    }
    
    // MARK: Geometry Encoding and Decoding
    
    func testGeoJsonGeometryCoding() throws {
        let json = geometryJsonForCoordinates("[1.0, 2.0, 3.0]")
        
        let data = json.data(using: .utf8)!
        let geometry = try JSONDecoder().decode(GeoJSONGeometry.self, from: data)
        
        let encodedGeometry = try JSONEncoder().encode(geometry)
        let encodedJson = String(data: encodedGeometry, encoding: .utf8)!
        
        let decodedData = encodedJson.data(using: .utf8)!
        let decodedGeometry = try JSONDecoder().decode(GeoJSONGeometry.self, from: decodedData)
        
        XCTAssertEqual(geometry.latitude, decodedGeometry.latitude)
        XCTAssertEqual(geometry.longitude, decodedGeometry.longitude)
        XCTAssertEqual(geometry.altitude, decodedGeometry.altitude)
    }
    
    // MARK: Coordinates count
    
    func testGeoJsonGeometryFromJson_InvalidCoordinatesCount_EmptyArray() throws {
        let json = geometryJsonForCoordinates("[]")
        let data = json.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(GeoJSONGeometry.self, from: data))
    }
    
    func testGeoJsonGeometryFromJson_InvalidCoordinatesCount_TooMuch() throws {
        let json = geometryJsonForCoordinates("[1.0, 2.0, 3.0, 4.0]")
        let data = json.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(GeoJSONGeometry.self, from: data))
    }
    
    func testGeoJsonGeometryFromJson_InvalidCoordinatesCount_ToLittle() throws {
        let json = geometryJsonForCoordinates("[1.0, 2.0]")
        let data = json.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(GeoJSONGeometry.self, from: data))
    }
    
    func testGeoJsonGeometryFromJson_ValidCoordinatesCount() throws {
        let json = geometryJsonForCoordinates("[1.0, 2.0, 3.0]")
        let data = json.data(using: .utf8)!
        XCTAssertNoThrow(try JSONDecoder().decode(GeoJSONGeometry.self, from: data))
    }
    
    // MARK: Longitude
    
    func testGeoJsonGeometryFromJson_InvalidLongitude_AboveRange() throws {
        let json = geometryJsonForCoordinates("[181.0, 1.0, 1.0]")
        let data = json.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(GeoJSONGeometry.self, from: data))
    }
    
    func testGeoJsonGeometryFromJson_InvalidLongitude_BelowRange() throws {
        let json = geometryJsonForCoordinates("[-181.0, 1.0, 1.0]")
        let data = json.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(GeoJSONGeometry.self, from: data))
    }
    
    func testGeoJsonGeometryFromJson_ValidLongitude() throws {
        let json = geometryJsonForCoordinates("[100.0, 1.0, 1.0]")
        let data = json.data(using: .utf8)!
        XCTAssertNoThrow(try JSONDecoder().decode(GeoJSONGeometry.self, from: data))
    }
    
    // MARK: Latitude
    
    func testGeoJsonGeometryFromJson_InvalidLatitude_AboveRange() throws {
        let json = geometryJsonForCoordinates("[1.0, 91.0, 1.0]")
        let data = json.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(GeoJSONGeometry.self, from: data))
    }
    
    func testGeoJsonGeometryFromJson_InvalidLatitude_BelowRange() throws {
        let json = geometryJsonForCoordinates("[1.0, -91.0, 1.0]")
        let data = json.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(GeoJSONGeometry.self, from: data))
    }
    
    func testGeoJsonGeometryFromJson_ValidLatitude() throws {
        let json = geometryJsonForCoordinates("[1.0, 1.0, 1.0]")
        let data = json.data(using: .utf8)!
        XCTAssertNoThrow(try JSONDecoder().decode(GeoJSONGeometry.self, from: data))
    }
}
