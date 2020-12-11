import CoreLocation

/**
 Main protocol used to track assets in SDK. There is a basic implementation of it done in the `DefaultTrackable` class.
 */
public protocol Trackable {
    /**
     Trackable identifier
     */
    var id: String { get }

    /**
     Metadata sent together with asset (TBD)
     */
    var metadata: String? { get }

    /**
     Asset destination. Used to increase accuracy of GPS map matching feature
     */
    var destination: CLLocationCoordinate2D { get }
}

/**
 The default implementation for `Trackable` protocol to use in communication with SDK.
 */
public class DefaultTrackable: Trackable {
    public let id: String
    public let metadata: String?
    public let destination: CLLocationCoordinate2D

    public init(id: String, metadata: String, latitude: Double, longitude: Double) {
        self.id = id
        self.metadata = metadata
        self.destination = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
