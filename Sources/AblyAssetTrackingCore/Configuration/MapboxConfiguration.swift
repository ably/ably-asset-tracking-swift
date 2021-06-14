import Foundation

public class MapboxConfiguration: NSObject {
    public let mapboxKey: String

    @objc
    public init(mapboxKey: String) {
        self.mapboxKey = mapboxKey
    }
}
