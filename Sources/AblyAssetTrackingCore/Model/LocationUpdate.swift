import Foundation

public protocol LocationUpdate {
    var location: Location { get }
    var skippedLocations: [Location] { get set }
}

