import XCTest
@testable import Core

class PresenceDataTests: XCTestCase {
    func testSerializationPublisher() throws {
        let data = PresenceData(type: .publisher)
        let jsonString = try data.toJSONString()
        XCTAssertNotNil(jsonString)
    }

    func testDeserializationPublisher() throws {
        let jsonString = "{\"type\":\"PUBLISHER\"}"
        let data: PresenceData = try PresenceData.fromJSONString(jsonString)
        XCTAssertEqual(data.type, .publisher)
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
