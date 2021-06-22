import AblyAssetTrackingCore

public class EnhancedLocationUpdateMessage: Codable {
    public let location: GeoJSONMessage
    public let intermediateLocations: [GeoJSONMessage]
    public let type: LocationUpdateType

    public init(locationUpdate: EnhancedLocationUpdate) throws {
        self.location = try GeoJSONMessage(location: locationUpdate.location)
        self.intermediateLocations = []
        self.type = locationUpdate.type
    }
}
