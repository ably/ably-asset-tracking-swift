import AblyAssetTrackingCore

public struct RawLocationUpdateMessage: Codable {
    public let location: GeoJSONMessage
    public let skippedLocations: [GeoJSONMessage]
    
    init(location: Location, skippedLocations: [Location]) throws {
        self.location = try GeoJSONMessage(location: location)
        self.skippedLocations = try skippedLocations.map(GeoJSONMessage.init)
    }
}
