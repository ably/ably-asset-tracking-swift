import XCTest
@testable import Core

// GeoJSONMessage test also GeoJSONGeometry and GeoJSONProperties
class GeoJSONMessageTests: XCTestCase {
    private func jsonWithCoordinates(_ coordinates: String) -> String {
        return """
        {
            "type": "Feature",
            "geometry": {
                "type": "Point",
                "coordinates": \(coordinates)
            },
            "properties": {
                "accuracyHorizontal": 1.2,
                "accuracyVertical": 2.3,
                "bearing": 4.3,
                "speed": 5.3,
                "time": 1607365170.0,
                "floor": 2,
                "accuracySpeed": 6.2,
                "accuracyBearing": 7.3,
            }
        }
        """
    }

    func testEncodedJSON() throws {
        // Instead of comparing JSON strings, try to:
        // Decode original message => Encode decoded message => Re-decode encoded message => Compare original and re-decoded messages

        let json = jsonWithCoordinates("[1.0, 2.0, 3.0]")
        let data = json.data(using: .utf8)!
        let message =  try! JSONDecoder().decode(GeoJSONMessage.self, from: data)

        let encodedData = try! JSONEncoder().encode(message)
        let encodedString = String(data: encodedData, encoding: .utf8)!

        let decodedData = encodedString.data(using: .utf8)!
        let decodedMessage =  try! JSONDecoder().decode(GeoJSONMessage.self, from: decodedData)

        XCTAssertEqual(message.geometry.longitude, decodedMessage.geometry.longitude, accuracy: .ulpOfOne)
        XCTAssertEqual(message.geometry.latitude, decodedMessage.geometry.latitude, accuracy: .ulpOfOne)
        XCTAssertEqual(message.geometry.altitude, decodedMessage.geometry.altitude, accuracy: .ulpOfOne)
        XCTAssertEqual(message.type, decodedMessage.type)
        XCTAssertEqual(message.geometry.type, decodedMessage.geometry.type)
        XCTAssertEqual(message.properties.accuracyHorizontal, decodedMessage.properties.accuracyHorizontal, accuracy: .ulpOfOne)
        XCTAssertEqual(message.properties.accuracyVertical!, decodedMessage.properties.accuracyVertical!, accuracy: .ulpOfOne)
        XCTAssertEqual(message.properties.bearing!, decodedMessage.properties.bearing!, accuracy: .ulpOfOne)
        XCTAssertEqual(message.properties.speed!, decodedMessage.properties.speed!, accuracy: .ulpOfOne)
        XCTAssertEqual(message.properties.time, decodedMessage.properties.time, accuracy: .ulpOfOne)
        XCTAssertEqual(message.properties.floor, decodedMessage.properties.floor)
        XCTAssertEqual(message.properties.accuracySpeed!, decodedMessage.properties.accuracySpeed!, accuracy: .ulpOfOne)
        XCTAssertEqual(message.properties.accuracyBearing!, decodedMessage.properties.accuracyBearing!, accuracy: .ulpOfOne)
    }

    func testValidJSON() throws {
        let json = jsonWithCoordinates("[1.0, 2.0, 3.0]")
        let data = json.data(using: .utf8)!
        let message =  try! JSONDecoder().decode(GeoJSONMessage.self, from: data)
        XCTAssertEqual(message.geometry.longitude, 1.0, accuracy: .ulpOfOne)
        XCTAssertEqual(message.geometry.latitude, 2.0, accuracy: .ulpOfOne)
        XCTAssertEqual(message.geometry.altitude, 3.0, accuracy: .ulpOfOne)
        XCTAssertEqual(message.type, .feature)
        XCTAssertEqual(message.geometry.type, .point)
        XCTAssertEqual(message.properties.accuracyHorizontal, 1.2, accuracy: .ulpOfOne)
        XCTAssertEqual(message.properties.accuracyVertical!, 2.3, accuracy: .ulpOfOne)
        XCTAssertEqual(message.properties.bearing!, 4.3, accuracy: .ulpOfOne)
        XCTAssertEqual(message.properties.speed!, 5.3, accuracy: .ulpOfOne)
        XCTAssertEqual(message.properties.time, 1607365170, accuracy: .ulpOfOne)
        XCTAssertEqual(message.properties.floor, 2)
        XCTAssertEqual(message.properties.accuracySpeed!, 6.2, accuracy: .ulpOfOne)
        XCTAssertEqual(message.properties.accuracyBearing!, 7.3, accuracy: .ulpOfOne)
    }

    func testInvalidJSON_NoCoordinates() throws {
        let json = jsonWithCoordinates("[]")
        let data = json.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(GeoJSONMessage.self, from: data))
    }

    func testInvalidJSON_TooMuchCoordinates() throws {
        let json = jsonWithCoordinates("[1.0, 2.0, 3.0, 4.0, 5.0]")
        let data = json.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(GeoJSONMessage.self, from: data))
    }

    func testInvalidJSON_OutOfRange_Lon_Above() throws {
        let json = jsonWithCoordinates("[181.0, 1.0]")
        let data = json.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(GeoJSONMessage.self, from: data))
    }

    func testInvalidJSON_OutOfRange_Lon_Below() throws {
        let json = jsonWithCoordinates("[-181.0, 1.0]")
        let data = json.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(GeoJSONMessage.self, from: data))
    }

    func testInvalidJSON_OutOfRange_Lat_Above() throws {
        let json = jsonWithCoordinates("[1.0, 90.5]")
        let data = json.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(GeoJSONMessage.self, from: data))
    }

    func testInvalidJSON_OutOfRange_Lat_Below() throws {
        let json = jsonWithCoordinates("[10, -90.5]")
        let data = json.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(GeoJSONMessage.self, from: data))
    }
}
