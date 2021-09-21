import AblyAssetTrackingCore

public class EnhancedLocationUpdateMessage: Codable {
    public let location: GeoJSONMessage
    public let skippedLocations: [GeoJSONMessage]
    public let intermediateLocations: [GeoJSONMessage]
    public let type: LocationUpdateType

    public init(locationUpdate: EnhancedLocationUpdate) throws {
        self.location = try GeoJSONMessage(location: locationUpdate.location)
        self.skippedLocations = try locationUpdate.skippedLocations.map(GeoJSONMessage.init)
        self.intermediateLocations = []
        self.type = locationUpdate.type
    }
}
