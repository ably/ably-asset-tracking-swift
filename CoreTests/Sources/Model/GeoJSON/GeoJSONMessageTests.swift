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
                "altitude": 3.2,
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
        
        let json = jsonWithCoordinates("[1.0, 2.0]")
        let data = json.data(using: .utf8)!
        let message =  try! JSONDecoder().decode(GeoJSONMessage.self, from: data)
        
        let encodedData = try! JSONEncoder().encode(message)
        let encodedString = String(data: encodedData, encoding: .utf8)!
        
        let decodedData = encodedString.data(using: .utf8)!
        let decodedMessage =  try! JSONDecoder().decode(GeoJSONMessage.self, from: decodedData)
        
        XCTAssertEqual(message.geometry.longitude, decodedMessage.geometry.longitude)
        XCTAssertEqual(message.geometry.latitude, decodedMessage.geometry.latitude)
        XCTAssertEqual(message.type, decodedMessage.type)
        XCTAssertEqual(message.geometry.type, decodedMessage.geometry.type)
        XCTAssertEqual(message.properties.accuracyHorizontal, decodedMessage.properties.accuracyHorizontal)
        XCTAssertEqual(message.properties.accuracyVertical, decodedMessage.properties.accuracyVertical)
        XCTAssertEqual(message.properties.altitude, decodedMessage.properties.altitude)
        XCTAssertEqual(message.properties.bearing, decodedMessage.properties.bearing)
        XCTAssertEqual(message.properties.speed, decodedMessage.properties.speed)
        XCTAssertEqual(message.properties.time, decodedMessage.properties.time)
        XCTAssertEqual(message.properties.floor, decodedMessage.properties.floor)
        XCTAssertEqual(message.properties.accuracySpeed, decodedMessage.properties.accuracySpeed)
        XCTAssertEqual(message.properties.accuracyBearing, decodedMessage.properties.accuracyBearing)
    }
    
    func testValidJSON() throws {
        let json = jsonWithCoordinates("[1.0, 2.0]")
        let data = json.data(using: .utf8)!
        let message =  try! JSONDecoder().decode(GeoJSONMessage.self, from: data)
        XCTAssertEqual(message.geometry.longitude, 1.0)
        XCTAssertEqual(message.geometry.latitude, 2.0)
        XCTAssertEqual(message.type, .feature)
        XCTAssertEqual(message.geometry.type, .point)
        XCTAssertEqual(message.properties.accuracyHorizontal, 1.2)
        XCTAssertEqual(message.properties.accuracyVertical, 2.3)
        XCTAssertEqual(message.properties.altitude, 3.2)
        XCTAssertEqual(message.properties.bearing, 4.3)
        XCTAssertEqual(message.properties.speed, 5.3)
        XCTAssertEqual(message.properties.time, 1607365170)
        XCTAssertEqual(message.properties.floor, 2)
        XCTAssertEqual(message.properties.accuracySpeed, 6.2)
        XCTAssertEqual(message.properties.accuracyBearing, 7.3)
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
