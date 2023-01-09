import XCTest
import CoreLocation
@testable import AblyAssetTrackingCore

// GeoJSONMessage test also GeoJSONGeometry and GeoJSONProperties
class GeoJSONMessageCodableTests: XCTestCase {
    private func jsonMessage(isValid: Bool? = true, type: GeoJSONType? = nil) -> String {
        return """
        {
            "type": "\(type?.rawValue ?? GeoJSONType.feature.rawValue)",
            "geometry": {
                "type": "Point",
                "coordinates": \(isValid ?? true ? [1.0, 2.0, 3.0] : [])
            },
            "properties": {
                "accuracyHorizontal": 1.0,
                "accuracyVertical": 2.0,
                "bearing": 3.0,
                "speed": 4.0,
                "time": 1234567890.0,
                "floor": 6,
                "accuracySpeed": 7.0,
                "accuracyBearing": 8.0
            }
        }
        """
    }

    func testEncodedJSON() throws {
        let json = jsonMessage(isValid: true)
        let data = json.data(using: .utf8)!
        let message = try! JSONDecoder().decode(GeoJSONMessage.self, from: data)

        let encodedData = try! JSONEncoder().encode(message)
        let encodedString = String(data: encodedData, encoding: .utf8)!

        let decodedData = encodedString.data(using: .utf8)!
        let decodedMessage =  try! JSONDecoder().decode(GeoJSONMessage.self, from: decodedData)
        
        XCTAssertEqual(message.type, decodedMessage.type)

        XCTAssertEqual(message.geometry.type, decodedMessage.geometry.type)
        XCTAssertEqual(message.geometry.longitude, decodedMessage.geometry.longitude, accuracy: .ulpOfOne)
        XCTAssertEqual(message.geometry.latitude, decodedMessage.geometry.latitude, accuracy: .ulpOfOne)
        XCTAssertEqual(message.geometry.altitude, decodedMessage.geometry.altitude, accuracy: .ulpOfOne)
    
        XCTAssertEqual(message.properties.accuracyHorizontal!, decodedMessage.properties.accuracyHorizontal!, accuracy: .ulpOfOne)
        XCTAssertEqual(message.properties.accuracyVertical!, decodedMessage.properties.accuracyVertical!, accuracy: .ulpOfOne)
        XCTAssertEqual(message.properties.bearing!, decodedMessage.properties.bearing!, accuracy: .ulpOfOne)
        XCTAssertEqual(message.properties.speed!, decodedMessage.properties.speed!, accuracy: .ulpOfOne)
        XCTAssertEqual(message.properties.time, decodedMessage.properties.time, accuracy: .ulpOfOne)
        XCTAssertEqual(message.properties.floor, decodedMessage.properties.floor)
        XCTAssertEqual(message.properties.accuracySpeed!, decodedMessage.properties.accuracySpeed!, accuracy: .ulpOfOne)
        XCTAssertEqual(message.properties.accuracyBearing!, decodedMessage.properties.accuracyBearing!, accuracy: .ulpOfOne)
    }
    
    func testGeoJsonMessageFromJson_InvalidJson() {
        let json = jsonMessage(isValid: false)
        let data = json.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(GeoJSONMessage.self, from: data))
    }
    
    func testGeoJsonMessageFromJson_ValidJson() {
        let json = jsonMessage(isValid: true)
        let data = json.data(using: .utf8)!
        XCTAssertNoThrow(try JSONDecoder().decode(GeoJSONMessage.self, from: data))
    }
    
    func testGeoJsonMessageFromJson_ValidJson_CheckValues() throws {
        let json = jsonMessage(isValid: true)
        let data = json.data(using: .utf8)!
        let message = try JSONDecoder().decode(GeoJSONMessage.self, from: data)
        
        XCTAssertEqual(message.type, .feature)
        
        XCTAssertEqual(message.geometry.longitude, 1.0)
        XCTAssertEqual(message.geometry.latitude, 2.0)
        XCTAssertEqual(message.geometry.altitude, 3.0)
        
        XCTAssertEqual(message.properties.accuracyHorizontal, 1.0)
        XCTAssertEqual(message.properties.accuracyVertical, 2.0)
        XCTAssertEqual(message.properties.bearing, 3.0)
        XCTAssertEqual(message.properties.speed, 4.0)
        XCTAssertEqual(message.properties.time, 1234567890.0)
        XCTAssertEqual(message.properties.floor, 6)
        XCTAssertEqual(message.properties.accuracySpeed, 7.0)
        XCTAssertEqual(message.properties.accuracyBearing, 8.0)
    }
    
    // MARK: Message type
    
    func testGeoJsonMessageFromJson_Type() throws {
        let type = GeoJSONType.point
        let json = jsonMessage(isValid: true, type: type)
        let data = json.data(using: .utf8)!
        let message = try JSONDecoder().decode(GeoJSONMessage.self, from: data)
        XCTAssertEqual(message.type, type)
    }
}
