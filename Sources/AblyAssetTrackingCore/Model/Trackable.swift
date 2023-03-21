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
     Asset destination. Used to increase accuracy of GPS map matching feature
     */
    public let destination: LocationCoordinate?

    /**
    Optional constraints used to determine suitable Resolution
     */
    public let constraints: ResolutionConstraints?

    public init(id: String,
                destination: LocationCoordinate? = nil,
                constraints: ResolutionConstraints? = nil) {
        self.id = id
        self.destination = destination
        self.constraints = constraints
    }

    public init(id: String,
                metadata: String? = nil,
                destination: LocationCoordinate,
                constraints: ResolutionConstraints? = nil) {
        self.id = id
        self.destination = (destination.latitude == 0 && destination.longitude == 0) ? nil : destination
        self.constraints = constraints
    }
}

extension Trackable: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: Trackable, rhs: Trackable) -> Bool {
        lhs.id == rhs.id
    }
}
