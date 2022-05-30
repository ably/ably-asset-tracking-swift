import Foundation

/**
 Mapbox configuration class
 */
public class MapboxConfiguration {
    /**
     The Mapbox key
     */
    public let mapboxKey: String

    /**
     - Parameter mapboxKey:     The Mapbox key
     */
    public init(mapboxKey: String) {
        self.mapboxKey = mapboxKey
    }
}
