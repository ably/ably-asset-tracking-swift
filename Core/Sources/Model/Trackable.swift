import CoreLocation

/**
 Main protocol used to track assets in SDK. There is a basic implementation of it done in the `DefaultTrackable` class.
 */
public protocol Trackable {
    var id: String { get }
    var metadata: String? { get }
    var destination: CLLocationCoordinate2D? { get }
}

/**
 The default implementation for `Trackable` protocol to use in communication with SDK.
 */
public class DefaultTrackable: Trackable {
    public let id: String
    public let metadata: String?
    public let destination: CLLocationCoordinate2D?

    public init(id: String, metadata: String? = nil, destination: CLLocationCoordinate2D? = nil) {
        self.id = id
        self.metadata = metadata
        self.destination = destination
    }
}
