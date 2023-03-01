import Foundation
import AblyAssetTrackingCore

class TrackableState<T: LocationUpdate> {
    
    let maxRetryCount: Int
    let maxSkippedLocationsSize: Int
    
    private var retryCounter: [String: Int] = [:]
    private var pendingMessages: Set<String> = []
    private var waitingLocationUpdates: [String: [T]] = [:]
    private var skippedLocations: [String: [T]] = [:]
    
    init(maxRetryCount: Int = 1, maxSkippedLocationsSize: Int = 60) {
        self.maxRetryCount = maxRetryCount
        self.maxSkippedLocationsSize = maxSkippedLocationsSize
    }
}

// MARK: - StateRetryable
extension TrackableState: StateRetryable {
    func shouldRetry(trackableID: String) -> Bool {
        addIfNeeded(trackableID: trackableID)
        
        return getRetryCounter(for: trackableID) < maxRetryCount
    }
    
    func resetRetryCounter(for trackableID: String) {
        guard retryCounter[trackableID] != nil else {
            return
        }
        
        retryCounter[trackableID] = .zero
    }
    
    func incrementRetryCounter(for trackableID: String) {
        retryCounter[trackableID] = getRetryCounter(for: trackableID) + 1
    }
    
    func getRetryCounter(for trackableID: String) -> Int {
        retryCounter[trackableID] ?? .zero
    }
    
    private func addIfNeeded(trackableID: String) {
        guard retryCounter[trackableID] == nil else {
            return
        }
        
        retryCounter[trackableID] = .zero
    }
}

// MARK: - StatePendable
extension TrackableState: StatePendable {
    func markMessageAsPending(for trackableID: String) {
        pendingMessages.insert(trackableID)
    }
    
    func unmarkMessageAsPending(for trackableID: String) {
        pendingMessages.remove(trackableID)
        retryCounter.removeValue(forKey: trackableID)
    }
    
    func hasPendingMessage(for trackableID: String) -> Bool {
        pendingMessages.contains(trackableID)
    }
}

// MARK: - StateWaitable
extension TrackableState: StateWaitable {
    func addToWaiting(locationUpdate: T, for trackableID: String) {
        var locations = waitingLocationUpdates[trackableID] ?? []
        locations.append(locationUpdate)
        waitingLocationUpdates[trackableID] = locations
    }
    
    func nextWaitingLocation(for trackableID: String) -> T? {
        guard var enhancedLocationUpdates = waitingLocationUpdates[trackableID], !enhancedLocationUpdates.isEmpty else {
            return nil
        }
        
        let location = enhancedLocationUpdates.removeFirst()
        waitingLocationUpdates[trackableID] = enhancedLocationUpdates
        
        return location
    }
}

// MARK: - StateSkippable
extension TrackableState: StateSkippable {
    func addLocation(for trackableID: String, location: T) {
        var locations = skippedLocations[trackableID] ?? []
        locations.append(location)
        locations.sort { $0.location.timestamp < $1.location.timestamp }
        if locations.count > maxSkippedLocationsSize {
            locations.remove(at: .zero)
        }
        skippedLocations[trackableID] = locations
    }
    
    func clearLocation(for trackableID: String) {
        skippedLocations[trackableID]?.removeAll()
    }
    
    func locationsList(for trackableID: String) -> [T] {
        skippedLocations[trackableID] ?? []
    }
}

// MARK: - StateRemovable
extension TrackableState: StateRemovable {
    func remove(trackableID: String) {
        retryCounter.removeValue(forKey: trackableID)
        pendingMessages.remove(trackableID)
        waitingLocationUpdates.removeValue(forKey: trackableID)
    }
    
    func removeAll() {
        retryCounter.removeAll()
        pendingMessages.removeAll()
        waitingLocationUpdates.removeAll()
        skippedLocations.removeAll()
    }
}
