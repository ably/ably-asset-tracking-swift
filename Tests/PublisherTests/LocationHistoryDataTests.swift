import XCTest
import AblyAssetTrackingPublisher

final class LocationHistoryDataTests: XCTestCase {
    func testVersion() {
        let locationHistoryData = LocationHistoryData(events: [])
        
        XCTAssertEqual(locationHistoryData.version, 1)
    }
    
    func testDecodable_decodesTestResource_version1_validAndroid() throws {
        let jsonFileUrl = try XCTUnwrap(CommonResources.url(forGeoTestDataJson: "valid-android", subdirectory: "location-history-data/version-1"))
        let jsonData = try Data(contentsOf: jsonFileUrl)
        
        let decoder = JSONDecoder()
        let _ = try decoder.decode(LocationHistoryData.self, from: jsonData)
    }
}
