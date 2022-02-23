/**
 Model used to handle raw location updates.
 */
public class RawLocationUpdate: LocationUpdate {
    public let location: Location
    public var skippedLocations: [Location] = []
    
    public init(location: Location) {
        self.location = location
    }
}
