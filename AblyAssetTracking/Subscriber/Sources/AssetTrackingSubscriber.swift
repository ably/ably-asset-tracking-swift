//
//  AssetTrackingSubscriber.swift
//  Subscriber
//
//  Created by Michal Miedlarz on 03/12/2020.
//  Copyright © 2020 Ably. All rights reserved.
//

import UIKit
import CoreLocation

public enum AssetTrackingConnectionStatus {
    case online
    case offline
}

public protocol AssetTrackingSubscriberDelegate {
    func assetTrackingSubscriber(sender: AssetTrackingSubscriber, didUpdateRawLocation location: CLLocation)
    func assetTrackingSubscriber(sender: AssetTrackingSubscriber, didUpdateEnhancedLocation location: CLLocation)
    func assetTrackingSubscriber(sender: AssetTrackingSubscriber, didChangeConnectionStatus status: AssetTrackingConnectionStatus)
}

public protocol AssetTrackingSubscriber {
    /**
     Delegate object to receive events from `AssetTrackingSubscriber`.
     It holds a weak reference so make sure to keep your delegate object in memory.
     */
    var delegate: AssetTrackingSubscriberDelegate? { get set }
}
