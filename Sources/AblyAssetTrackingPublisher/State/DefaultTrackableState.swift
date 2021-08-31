//
//  Created by Łukasz Szyszkowski on 30/08/2021.
//

import Foundation

class DefaultTrackableState: PublisherTrackableState {
    
    let maxRetryCount: Int
    private var retryCounter: [String: Int] = [:]
    
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
}
