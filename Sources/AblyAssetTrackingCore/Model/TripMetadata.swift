//
//  Created by Łukasz Szyszkowski on 01/09/2021.
//

import Foundation
import CoreLocation

public struct TripMetadata {
    public let trackableId: String
    public let timestamp: Int
    public let originLocation: CLLocation
    public let destinationLocation: CLLocation?
    
    public init(
        trackableId: String,
        timestamp: Int,
        originLocation: CLLocation,
        destinationLocation: CLLocation? = nil
    ) {
        self.trackableId = trackableId
        self.timestamp = timestamp
        self.originLocation = originLocation
        self.destinationLocation = destinationLocation
    }
}
