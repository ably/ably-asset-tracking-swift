//
//  File.swift
//  
//
//  Created by Łukasz Szyszkowski on 25/08/2021.
//

import Foundation

protocol PublisherTrackableState {
    var maxRetryCount: Int { get }
    mutating func resetCounter(for trackableId: String)
    mutating func incrementCounter(for trackableId: String)
    mutating func shouldRetry(trackableId: String) -> Bool
    func getCounter(for trackableId: String) -> Int
}
