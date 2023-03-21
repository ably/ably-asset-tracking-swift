import XCTest

@testable import AblyAssetTrackingCore

class GeoJSONPropertiesCodableTests: XCTestCase {
    private func propertiesJson(
        horizontalAccuracy: Double? = nil,
        accuracyVertical: Double? = nil,
        bearing: Double? = nil,
        accuracyBearing: Double? = nil,
        speed: Double? = nil,
        accuracySpeed: Double? = nil,
        timestamp: Date? = nil
    ) -> String {
        """
            {
                "accuracyHorizontal": \(horizontalAccuracy ?? 1.0),
                "accuracyVertical": \(accuracyVertical ?? 2.0),
                "bearing": \(bearing ?? 3.0),
                "accuracyBearing": \(accuracyBearing ?? 4.0),
                "speed": \(speed ?? 5.0),
                "accuracySpeed": \(accuracySpeed ?? 6.0),
                "floor": 7,
                "time": \(timestamp?.timeIntervalSince1970 ?? 1234567890.0)
            }
        """
    }

    // MARK: GeoJSONProperties Encoding and Decoding

    func testGeoJsonPropertiesFromJsonCoding() throws {
        let data = propertiesJson().data(using: .utf8)!
        let properties = try JSONDecoder().decode(GeoJSONProperties.self, from: data)

        let encodedProperties = try JSONEncoder().encode(properties)
        let encodedJson = String(data: encodedProperties, encoding: .utf8)!

        let decodedData = encodedJson.data(using: .utf8)!
        let decodedProperties = try JSONDecoder().decode(GeoJSONProperties.self, from: decodedData)

        XCTAssertEqual(properties.accuracyHorizontal, decodedProperties.accuracyHorizontal)
        XCTAssertEqual(properties.accuracyVertical, decodedProperties.accuracyVertical)
        XCTAssertEqual(properties.bearing, decodedProperties.bearing)
        XCTAssertEqual(properties.accuracyBearing, decodedProperties.accuracyBearing)
        XCTAssertEqual(properties.speed, decodedProperties.speed)
        XCTAssertEqual(properties.accuracySpeed, decodedProperties.accuracySpeed)
        XCTAssertEqual(properties.time, decodedProperties.time)
        XCTAssertEqual(properties.floor, decodedProperties.floor)
    }

    // MARK: - Horizontal accuracy

    func testGeoJsonPropertiesFromJson_InvalidHorizontalAccuracy_LessThanZero() throws {
        let data = propertiesJson(horizontalAccuracy: -1.0).data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(GeoJSONProperties.self, from: data))
    }

    func testGeoJsonPropertiesFromJson_ValidHorizontalAccuracy_EqualZero() throws {
        let data = propertiesJson(horizontalAccuracy: 0.0).data(using: .utf8)!
        XCTAssertNoThrow(try JSONDecoder().decode(GeoJSONProperties.self, from: data))
    }

    func testGeoJsonPropertiesFromJson_ValidHorizontalAccuracy_MoreThanZero() throws {
        let data = propertiesJson(horizontalAccuracy: 10.0).data(using: .utf8)!
        XCTAssertNoThrow(try JSONDecoder().decode(GeoJSONProperties.self, from: data))
    }

    // MARK: - Vertical accuracy

    func testGeoJsonPropertiesFromJson_InvalidVerticalAccuracy_LessThanZero() throws {
        let data = propertiesJson(accuracyVertical: -1.0).data(using: .utf8)!
        let properties = try JSONDecoder().decode(GeoJSONProperties.self, from: data)
        XCTAssertNil(properties.accuracyVertical)
    }

    func testGeoJsonPropertiesFromJson_ValidVerticalAccuracy() throws {
        let accuracyVertical = 1.0
        let data = propertiesJson(accuracyVertical: accuracyVertical).data(using: .utf8)!
        let properties = try JSONDecoder().decode(GeoJSONProperties.self, from: data)
        XCTAssertEqual(properties.accuracyVertical, accuracyVertical)
    }

    // MARK: - Bearing accuracy

    func testGeoJsonPropertiesFromJson_InvalidBearingAccuracy_LessThanZero() throws {
        let data = propertiesJson(accuracyBearing: -1.0).data(using: .utf8)!
        let properties = try JSONDecoder().decode(GeoJSONProperties.self, from: data)
        XCTAssertNil(properties.accuracyBearing)
    }

    func testGeoJsonPropertiesFromJson_ValidBearingAccuracy() throws {
        let accuracyBearing = 1.0
        let data = propertiesJson(accuracyBearing: accuracyBearing).data(using: .utf8)!
        let properties = try JSONDecoder().decode(GeoJSONProperties.self, from: data)
        XCTAssertEqual(properties.accuracyBearing, accuracyBearing)
    }

    // MARK: - Speed accuracy

    func testGeoJsonPropertiesFromJson_InvalidSpeedAccuracy_LessThanZero() throws {
        let data = propertiesJson(accuracySpeed: -1.0).data(using: .utf8)!
        let properties = try JSONDecoder().decode(GeoJSONProperties.self, from: data)
        XCTAssertNil(properties.accuracySpeed)
    }

    func testGeoJsonPropertiesFromJson_ValidSpeedAccuracy() throws {
        let accuracySpeed = 1.0
        let data = propertiesJson(accuracySpeed: accuracySpeed).data(using: .utf8)!
        let properties = try JSONDecoder().decode(GeoJSONProperties.self, from: data)
        XCTAssertEqual(properties.accuracySpeed, accuracySpeed)
    }

    // MARK: - Bearing

    func testGeoJsonPropertiesFromJson_InvalidBearing_LessThanZero() throws {
        let data = propertiesJson(bearing: -1.0).data(using: .utf8)!
        let properties = try JSONDecoder().decode(GeoJSONProperties.self, from: data)
        XCTAssertNil(properties.bearing)
    }

    func testGeoJsonPropertiesFromJson_ValidBearing() throws {
        let bearing = 1.0
        let data = propertiesJson(bearing: bearing).data(using: .utf8)!
        let properties = try JSONDecoder().decode(GeoJSONProperties.self, from: data)
        XCTAssertEqual(properties.bearing, bearing)
    }

    // MARK: - Speed

    func testGeoJsonPropertiesFromJson_InvalidSpeed_LessThanZero() throws {
        let data = propertiesJson(speed: -1.0).data(using: .utf8)!
        let properties = try JSONDecoder().decode(GeoJSONProperties.self, from: data)
        XCTAssertNil(properties.speed)
    }

    func testGeoJsonPropertiesFromJson_ValidSpeed() throws {
        let speed = 1.0
        let data = propertiesJson(speed: speed).data(using: .utf8)!
        let properties = try JSONDecoder().decode(GeoJSONProperties.self, from: data)
        XCTAssertEqual(properties.speed, speed)
    }

    // MARK: - Timestamp

    func testGeoJsonPropertiesFromJson_Timestamp() throws {
        let timestamp = Date()
        let data = propertiesJson(timestamp: timestamp).data(using: .utf8)!
        let properties = try JSONDecoder().decode(GeoJSONProperties.self, from: data)
        XCTAssertEqual(properties.time, timestamp.timeIntervalSince1970)
    }
}
