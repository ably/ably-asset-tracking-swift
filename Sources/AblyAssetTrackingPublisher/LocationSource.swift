import CoreLocation

@objc
public enum LocationSourceType: Int {
    case `default`
    case raw
}

@objc
public class LocationSource: NSObject {
    @objc let type: LocationSourceType
    @objc let locationSource: [CLLocation]?
    
    @objc
    public init(locationSource: [CLLocation]?) {
        self.type = locationSource != nil ? .raw : .default
        self.locationSource = locationSource
    }
    
    @objc
    public override init() {
        self.type = .default
        self.locationSource = nil
    }
}
