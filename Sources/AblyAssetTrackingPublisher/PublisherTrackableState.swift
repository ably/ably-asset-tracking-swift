//
//  File.swift
//  
//
//  Created by Łukasz Szyszkowski on 25/08/2021.
//

import Foundation

struct PublisherTrackableState {
    
    private enum Constants {
        static let maxRetryCount = 1
    }
    
    private var retryCounter: [String: Int] = [:]
    
    mutating func shouldRetry(trackableId: String) -> Bool {
        addIfNeeded(trackableId: trackableId)
        
        return getCounter(for: trackableId) < Constants.maxRetryCount
    }
    
    mutating func resetCounter(for trackableId: String) {
        guard retryCounter[trackableId] != nil else {
            return
        }
        
        retryCounter[trackableId] = .zero
    }
    
    mutating func incrementCounter(for trackableId: String) {
        retryCounter[trackableId] = getCounter(for: trackableId) + 1
    }
    
    func getCounter(for trackableId: String) -> Int {
        retryCounter[trackableId] ?? .zero
    }
    
    private mutating func addIfNeeded(trackableId: String) {
        guard retryCounter[trackableId] == nil else {
            return
        }
        
        retryCounter[trackableId] = .zero
    }
}
