import CoreLocation

/**
 Main class used to track assets in SDK
 */
@objc
public class Trackable: NSObject {
    /**
     Trackable identifier
     */
    public let id: String

    /**
     Asset destination. Used to increase accuracy of GPS map matching feature
     */
    public let destination: CLLocationCoordinate2D?

    /**
    Optional constraints used to determine suitable Resolution
     */
    public let constraints: ResolutionConstraints?

    public init(id: String,
                destination: CLLocationCoordinate2D? = nil,
                constraints: ResolutionConstraints? = nil) {
        self.id = id
        self.destination = destination
        self.constraints = constraints
        super.init()
    }
    
    @objc
    public init(id: String,
                metadata: String? = nil,
                destination: CLLocationCoordinate2D,
                constraints: ResolutionConstraints? = nil) {
        self.id = id
        self.destination = (destination.latitude == 0 && destination.longitude == 0) ? nil : destination
        self.constraints = constraints
        super.init()
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(id)
        return hasher.finalize()
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let otherObject = object as? Trackable else {
            return false
        }
        
        return otherObject.id == self.id
    }
}
