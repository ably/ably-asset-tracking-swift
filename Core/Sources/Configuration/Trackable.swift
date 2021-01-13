import CoreLocation

/**
 Main class used to track assets in SDK
 */
public class Trackable: NSObject {
    /**
     Trackable identifier
     */
    public let id: String

    /**
     Metadata sent together with asset (TBD)
     */
    public let metadata: String?

    /**
     Asset destination. Used to increase accuracy of GPS map matching feature
     */
    public let destination: CLLocationCoordinate2D?

    /**
    Optional constraints used to determine suitable Resolution
     */
    public let constraints: ResolutionConstraints?

    public init(id: String,
                metadata: String? = nil,
                destination: CLLocationCoordinate2D? = nil,
                constraints: ResolutionConstraints? = nil) {
        self.id = id
        self.metadata = metadata
        self.destination = destination
        self.constraints = constraints
        super.init()
    }
}
