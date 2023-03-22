import AblyAssetTrackingCore

public struct RawLocationUpdateMessage: Codable {
    public let location: GeoJSONMessage
    public let skippedLocations: [GeoJSONMessage]

    init(locationUpdate: RawLocationUpdate) throws {
        self.location = try GeoJSONMessage(location: locationUpdate.location)
        self.skippedLocations = try locationUpdate.skippedLocations.map(GeoJSONMessage.init)
    }
}
