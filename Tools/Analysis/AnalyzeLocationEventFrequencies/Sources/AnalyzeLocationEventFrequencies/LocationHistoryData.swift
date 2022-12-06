/// A subset of AblyAssetTrackingCore’s same type.
struct LocationHistoryData: Codable {
    var events: [GeoJSONMessage]
    
    struct GeoJSONMessage: Codable {
        var properties: GeoJSONProperties
        
        struct GeoJSONProperties: Codable {
            /**
             Timestamp from a moment when measurment was done (in seconds since 1st of January 1970)
             */
            let time: Double
        }
    }
}
