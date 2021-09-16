//
//  Created by Łukasz Szyszkowski on 30/08/2021.
//

import Foundation
import AblyAssetTrackingCore

class TrackableState: TrackableStateable {
    
    let maxRetryCount: Int
    private var retryCounter: [String: Int] = [:]
    private var pendingMessages: Set<String> = []
    private var waitingLocationUpdates: [String: [EnhancedLocationUpdate]] = [:]
    
    init(maxRetryCount: Int = 1) {
        self.maxRetryCount = maxRetryCount
    }
    
    func shouldRetry(trackableId: String) -> Bool {
        addIfNeeded(trackableId: trackableId)
        
        return getCounter(for: trackableId) < maxRetryCount
    }
    
    func resetCounter(for trackableId: String) {
        guard retryCounter[trackableId] != nil else {
            return
        }
        
        retryCounter[trackableId] = .zero
    }
    
    func incrementCounter(for trackableId: String) {
        retryCounter[trackableId] = getCounter(for: trackableId) + 1
    }
    
    func getCounter(for trackableId: String) -> Int {
        retryCounter[trackableId] ?? .zero
    }
    
    private func addIfNeeded(trackableId: String) {
        guard retryCounter[trackableId] == nil else {
            return
        }
        
        retryCounter[trackableId] = .zero
    }
    
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
    
    func addToWaiting(locationUpdate: EnhancedLocationUpdate, for trackableId: String) {
        var locations = waitingLocationUpdates[trackableId] ?? []
        locations.append(locationUpdate)
        waitingLocationUpdates[trackableId] = locations
    }
    
    func nextWaiting(for trackableId: String) -> EnhancedLocationUpdate? {
        guard var enhancedLocationUpdates = waitingLocationUpdates[trackableId], !enhancedLocationUpdates.isEmpty else {
            return nil
        }
        
        let location = enhancedLocationUpdates.removeFirst()
        waitingLocationUpdates[trackableId] = enhancedLocationUpdates
        
        return location
    }
    
    func remove(trackableId: String) {
        retryCounter.removeValue(forKey: trackableId)
        pendingMessages.remove(trackableId)
        waitingLocationUpdates.removeValue(forKey: trackableId)
    }
    
    func removeAll() {
        retryCounter.removeAll()
        pendingMessages.removeAll()
        waitingLocationUpdates.removeAll()
    }
}
