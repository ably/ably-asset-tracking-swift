//
//  Created by Łukasz Szyszkowski on 01/09/2021.
//

import AblyAssetTrackingCore

public struct TripMetadataMessage: Codable {
    let trackingId: String
    let timestamp: Int
    let tripData: TripDataMessage
    
    public struct TripDataMessage: Codable {
        let originLocation: GeoJSONMessage
        let destinationLocation: GeoJSONMessage?
    }
    
    public init(with metadata: TripMetadata) throws {
        self.trackingId = metadata.trackableId
        self.timestamp = metadata.timestamp
        
        var destinationLocation: GeoJSONMessage?
        
        if let tripDestinationLocation = metadata.destinationLocation {
            destinationLocation = try GeoJSONMessage(location: tripDestinationLocation)
        }
        
        self.tripData = TripDataMessage(
            originLocation: try GeoJSONMessage(location: metadata.originLocation),
            destinationLocation: destinationLocation
        )
    }
}
