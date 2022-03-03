import XCTest
//import Ably
import UIKit
@testable import AblyAssetTrackingInternal

class PresenceDataTests: XCTestCase {
    func testSerializationPublisher() throws {
        var data = PresenceData(type: .publisher, rawLocations: true)
        var jsonString = try data.toJSONString()
        XCTAssertEqual(jsonString, "{\"type\":\"PUBLISHER\",\"rawLocations\":true}")
        
        data = PresenceData(type: .publisher, rawLocations: false)
        jsonString = try data.toJSONString()
        XCTAssertEqual(jsonString, "{\"type\":\"PUBLISHER\",\"rawLocations\":false}")
        
        data = PresenceData(type: .publisher, rawLocations: nil)
        jsonString = try data.toJSONString()
        XCTAssertEqual(jsonString, "{\"type\":\"PUBLISHER\"}")
    }

    func testDeserializationPublisher() throws {
        var jsonString = "{\"type\":\"PUBLISHER\"}"
        var data: PresenceData = try PresenceData.fromJSONString(jsonString)
        XCTAssertEqual(data.type, .publisher)
        
        jsonString = "{\"type\":\"PUBLISHER\",\"rawLocations\":true}"
        data = try PresenceData.fromJSONString(jsonString)
        XCTAssertEqual(data.type, .publisher)
        XCTAssertEqual(data.rawLocations, true)
        
        jsonString = "{\"type\":\"PUBLISHER\",\"rawLocations\":false}"
        data = try PresenceData.fromJSONString(jsonString)
        XCTAssertEqual(data.type, .publisher)
        XCTAssertEqual(data.rawLocations, false)
    }

    func testDeserializationFailure() {
        // Unknown client type
        XCTAssertThrowsError(try buildPresenceData(from: "{\"type\":\"unknown\"}"))

        // Incorrect JSON
        XCTAssertThrowsError(try buildPresenceData(from: ""))
        XCTAssertThrowsError(try buildPresenceData(from: "Test123"))
    }

    private func buildPresenceData(from json: String) throws {
        let _: PresenceData = try PresenceData.fromJSONString(json)
    }

    func testSerializationSubscriber() throws {
        let data = PresenceData(type: .subscriber)
        let jsonString = try data.toJSONString()
        XCTAssertNotNil(jsonString)
    }

    func testDeserializationSubscriber() throws {
        let jsonString = "{\"type\":\"SUBSCRIBER\"}"
        let data: PresenceData = try PresenceData.fromJSONString(jsonString)
        XCTAssertEqual(data.type, .subscriber)
    }
}
