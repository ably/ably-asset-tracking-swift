import Foundation
import AblyAssetTrackingCore

protocol StateRetryable {
    var maxRetryCount: Int { get }
    mutating func resetRetryCounter(for trackableId: String)
    mutating func incrementRetryCounter(for trackableId: String)
    mutating func shouldRetry(trackableId: String) -> Bool
    func getRetryCounter(for trackableId: String) -> Int
}

protocol StatePendable {
    mutating func markMessageAsPending(for trackableId: String)
    mutating func unmarkMessageAsPending(for trackableId: String)
    func hasPendingMessage(for trackableId: String) -> Bool
}

protocol StateWaitable {
    associatedtype LocationType: LocationUpdate

    mutating func addToWaiting(locationUpdate: LocationType, for trackableId: String)
    mutating func nextWaitingLocation(for trackableId: String) -> LocationType?
}

protocol StateRemovable {
    mutating func remove(trackableId: String)
    mutating func removeAll()
}

protocol StateSkippable {
    associatedtype LocationType: LocationUpdate

    func addLocation(for trackableId: String, location: LocationType)
    func clearLocation(for trackableId: String)
    func locationsList(for trackableId: String) -> [LocationType]
}
