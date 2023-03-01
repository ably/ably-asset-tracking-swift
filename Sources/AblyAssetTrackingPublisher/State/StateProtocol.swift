import Foundation
import AblyAssetTrackingCore

protocol StateRetryable {
    var maxRetryCount: Int { get }
    mutating func resetRetryCounter(for trackableID: String)
    mutating func incrementRetryCounter(for trackableID: String)
    mutating func shouldRetry(trackableID: String) -> Bool
    func getRetryCounter(for trackableID: String) -> Int
}

protocol StatePendable {
    mutating func markMessageAsPending(for trackableID: String)
    mutating func unmarkMessageAsPending(for trackableID: String)
    func hasPendingMessage(for trackableID: String) -> Bool
}

protocol StateWaitable {
    associatedtype LocationType: LocationUpdate
    
    mutating func addToWaiting(locationUpdate: LocationType, for trackableID: String)
    mutating func nextWaitingLocation(for trackableID: String) -> LocationType?
}

protocol StateRemovable {
    mutating func remove(trackableID: String)
    mutating func removeAll()
}

protocol StateSkippable {
    associatedtype LocationType: LocationUpdate
    
    func addLocation(for trackableID: String, location: LocationType)
    func clearLocation(for trackableID: String)
    func locationsList(for trackableID: String) -> [LocationType]
}
