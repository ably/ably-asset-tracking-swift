//
//  File.swift
//  
//
//  Created by Łukasz Szyszkowski on 25/08/2021.
//

import Foundation
import AblyAssetTrackingCore

protocol StateRetryable {
    var maxRetryCount: Int { get }
    mutating func resetCounter(for trackableId: String)
    mutating func incrementCounter(for trackableId: String)
    mutating func shouldRetry(trackableId: String) -> Bool
    func getCounter(for trackableId: String) -> Int
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

typealias TrackableStateable = StateWaitable & StatePendable & StateRemovable & StateRetryable
