import CoreLocation

@available(*, deprecated, message: "No longer used.")
public enum LocationSourceType: Int {
    case `default`
    case raw
}

public class LocationSource {
    let locationSource: [CLLocation]?
    
    public init(locationSource: [CLLocation]?) {
        self.locationSource = locationSource
    }
    
    @available(*, deprecated, message: "To use the device’s location, either do not call PublisherBuilder.locationSource(_:), or pass nil to it.")
    public init() {
        self.locationSource = nil
    }
}
