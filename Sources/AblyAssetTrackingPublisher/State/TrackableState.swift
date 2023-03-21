import AblyAssetTrackingCore
import Foundation

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
    func shouldRetry(trackableId: String) -> Bool {
        addIfNeeded(trackableId: trackableId)

        return getRetryCounter(for: trackableId) < maxRetryCount
    }

    func resetRetryCounter(for trackableId: String) {
        guard retryCounter[trackableId] != nil else {
            return
        }

        retryCounter[trackableId] = .zero
    }

    func incrementRetryCounter(for trackableId: String) {
        retryCounter[trackableId] = getRetryCounter(for: trackableId) + 1
    }

    func getRetryCounter(for trackableId: String) -> Int {
        retryCounter[trackableId] ?? .zero
    }

    private func addIfNeeded(trackableId: String) {
        guard retryCounter[trackableId] == nil else {
            return
        }

        retryCounter[trackableId] = .zero
    }
}

// MARK: - StatePendable
extension TrackableState: StatePendable {
    func markMessageAsPending(for trackableId: String) {
        pendingMessages.insert(trackableId)
    }

    func unmarkMessageAsPending(for trackableId: String) {
        pendingMessages.remove(trackableId)
        retryCounter.removeValue(forKey: trackableId)
    }

    func hasPendingMessage(for trackableId: String) -> Bool {
        pendingMessages.contains(trackableId)
    }
}

// MARK: - StateWaitable
extension TrackableState: StateWaitable {
    func addToWaiting(locationUpdate: T, for trackableId: String) {
        var locations = waitingLocationUpdates[trackableId] ?? []
        locations.append(locationUpdate)
        waitingLocationUpdates[trackableId] = locations
    }

    func nextWaitingLocation(for trackableId: String) -> T? {
        guard var enhancedLocationUpdates = waitingLocationUpdates[trackableId], !enhancedLocationUpdates.isEmpty else {
            return nil
        }

        let location = enhancedLocationUpdates.removeFirst()
        waitingLocationUpdates[trackableId] = enhancedLocationUpdates

        return location
    }
}

// MARK: - StateSkippable
extension TrackableState: StateSkippable {
    func addLocation(for trackableId: String, location: T) {
        var locations = skippedLocations[trackableId] ?? []
        locations.append(location)
        locations.sort { $0.location.timestamp < $1.location.timestamp }
        if locations.count > maxSkippedLocationsSize {
            locations.remove(at: .zero)
        }
        skippedLocations[trackableId] = locations
    }

    func clearLocation(for trackableId: String) {
        skippedLocations[trackableId]?.removeAll()
    }

    func locationsList(for trackableId: String) -> [T] {
        skippedLocations[trackableId] ?? []
    }
}

// MARK: - StateRemovable
extension TrackableState: StateRemovable {
    func remove(trackableId: String) {
        retryCounter.removeValue(forKey: trackableId)
        pendingMessages.remove(trackableId)
        waitingLocationUpdates.removeValue(forKey: trackableId)
    }

    func removeAll() {
        retryCounter.removeAll()
        pendingMessages.removeAll()
        waitingLocationUpdates.removeAll()
        skippedLocations.removeAll()
    }
}
