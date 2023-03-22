import Foundation

public struct LocationCoordinate: Equatable {
    /**
     Latitude of the location in degrees.
     */
    public let latitude: Double

    /**
     Longitude of the location in degrees.
     */
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
