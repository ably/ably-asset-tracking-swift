import CoreLocation

// swiftlint:disable missing_docs

@available(*, deprecated, message: "No longer used.")
public enum LocationSourceType: Int {
    case `default`
    case raw
}

public class LocationSource {
    let locations: [CLLocation]?

    @available(*, deprecated, message: "To create a location source which overrides the device’s location, use init(locations:) instead.")
    public init(locationSource: [CLLocation]?) {
        self.locations = locationSource
    }

    public init(locations: [CLLocation]) {
        self.locations = locations
    }

    public init(locationHistoryData: LocationHistoryData) {
        self.locations = locationHistoryData.events.map { $0.toCoreLocation() }
    }

    @available(*, deprecated, message: "To use the device’s location, either do not call PublisherBuilder.locationSource(_:), or pass nil to it.")
    public init() {
        self.locations = nil
    }
}
