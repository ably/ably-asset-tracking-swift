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

extension RawLocationUpdate: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "{ location: \(String(reflecting: location)), skippedLocations: \(String(reflecting: skippedLocations)) }"
    }
}
