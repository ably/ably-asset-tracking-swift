import Foundation

public struct LocationHistoryData: Codable {
    public let events: [GeoJSONMessage]
    public let version: Int
    
    public init(events: [GeoJSONMessage]) {
        self.events = events
        self.version = 1
    }
}
