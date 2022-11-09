import XCTest
import AblyAssetTrackingPublisher

final class LocationHistoryDataTests: XCTestCase {
    func testVersion() {
        let locationHistoryData = LocationHistoryData(events: [])
        
        XCTAssertEqual(locationHistoryData.version, 1)
    }
    
    func testDecodable_decodesTestResource_validAndroid() throws {
        let jsonFileUrl = try XCTUnwrap(CommonResources.url(forTestResourceJson: "valid-android", subdirectory: "geo/location-history-data"))
        let jsonData = try Data(contentsOf: jsonFileUrl)
        
        let decoder = JSONDecoder()
        let _ = try decoder.decode(LocationHistoryData.self, from: jsonData)
    }
}
