import CoreLocation

/**
 Main class used to track assets in SDK
 */
public class Trackable {
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

    public init(id: String, metadata: String? = nil, destination: CLLocationCoordinate2D? = nil) {
        self.id = id
        self.metadata = metadata
        self.destination = destination
    }
}
