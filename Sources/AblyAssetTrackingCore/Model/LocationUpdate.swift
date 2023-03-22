import Foundation

// swiftlint:disable missing_docs

public protocol LocationUpdate {
    var location: Location { get }
    var skippedLocations: [Location] { get set }
}
