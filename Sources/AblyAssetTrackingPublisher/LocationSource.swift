import CoreLocation

public enum LocationSourceType: Int {
    case `default`
    case raw
}

public class LocationSource {
    let type: LocationSourceType
    let locationSource: [CLLocation]?
    
    public init(locationSource: [CLLocation]?) {
        self.type = locationSource != nil ? .raw : .default
        self.locationSource = locationSource
    }
    
    public init() {
        self.type = .default
        self.locationSource = nil
    }
}
