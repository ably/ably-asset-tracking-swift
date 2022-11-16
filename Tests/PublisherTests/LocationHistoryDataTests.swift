import XCTest
import AblyAssetTrackingPublisher
import Foundation

final class LocationHistoryDataTests: XCTestCase {
    @available(*, deprecated, message: "Testing deprecated LocationHistoryData.version property")
    func testVersionAlwaysReturns1() {
        let locationHistoryData = LocationHistoryData(events: [])
        
        XCTAssertEqual(locationHistoryData.version, 1)
    }
    
    // MARK: Decodable
    
    func testDecodable_decodesTestResource_version1_validAndroid() throws {
        let jsonFileUrl = try XCTUnwrap(CommonResources.url(forGeoTestDataJson: "valid-android", subdirectory: "location-history-data/version-1"))
        let jsonData = try Data(contentsOf: jsonFileUrl)
        
        let decoder = JSONDecoder()
        let _ = try decoder.decode(LocationHistoryData.self, from: jsonData)
    }
    
    func testDecodable_decodesTestResource_version2_valid2_0_0() throws {
        let jsonFileUrl = try XCTUnwrap(CommonResources.url(forGeoTestDataJson: "valid-2.0.0", subdirectory: "location-history-data/version-2"))
        let jsonData = try Data(contentsOf: jsonFileUrl)
        
        let decoder = JSONDecoder()
        let _ = try decoder.decode(LocationHistoryData.self, from: jsonData)
    }
    
    func testDecodable_withMajorVersionGreaterThan2_throwsUnsupportedVersionError() throws {
        let jsonData = try JSONSerialization.data(withJSONObject: ["version": "3.0.0"])
        
        let decoder = JSONDecoder()
        XCTAssertThrowsError(try decoder.decode(LocationHistoryData.self, from: jsonData)) { error in
            guard case LocationHistoryData.DecodingError.unsupportedVersion(version: "3.0.0") = error else {
                XCTFail("Expected to get .decodingError(version: 3.0.0), got \(error)")
                return
            }
        }
    }
    
    // MARK: Encodable
    
    func testEncodable_encodesVersionAsSemanticVersionString() throws {
        let locationHistoryData = LocationHistoryData(events: [])
        
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(locationHistoryData)
        
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData)
        let dictionary = try XCTUnwrap(jsonObject as? [String: Any])
        
        XCTAssertEqual(dictionary["version"] as? String, "2.0.0-wip")
    }
}
