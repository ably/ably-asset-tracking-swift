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
    mutating func addToWaiting(locationUpdate: EnhancedLocationUpdate, for trackableId: String)
    mutating func nextWaiting(for trackableId: String) -> EnhancedLocationUpdate?
}

protocol StateRemovable {
    mutating func remove(trackableId: String)
    mutating func removeAll()
}

protocol StateSkippable {
    func skippedLocationsAdd(for trackableId: String, location: EnhancedLocationUpdate)
    func skippedLocationsClear(for trackableId: String)
    func skippedLocationsList(for trackableId: String) -> [EnhancedLocationUpdate]
}
