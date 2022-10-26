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
    
    @available(*, deprecated, message: "To use the device’s location, either do not call PublisherBuilder.locationSource(_:), or pass nil to it.")
    public init() {
        self.type = .default
        self.locationSource = nil
    }
}
