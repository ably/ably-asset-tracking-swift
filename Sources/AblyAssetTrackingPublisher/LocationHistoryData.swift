import Foundation

public struct LocationHistoryData: Codable {
    let events: [GeoJSONMessage]
    let version: Int
    
    public init(events: [GeoJSONMessage], version: Int) {
        self.events = events
        self.version = version
    }
}
