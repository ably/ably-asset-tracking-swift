//
//  AblyAssetTrackingPublisher.swift
//  Publisher
//
//  Created by Michal Miedlarz on 01/12/2020.
//  Copyright © 2020 Ably. All rights reserved.
//

import UIKit
import CoreLocation

public protocol AblyAssetTrackingPublisherDelegate: class {
    func ablyAssetTrackingPublisher(sender: AblyAssetTrackingPublisher, didFailWithError error: Error)
    func ablyAssetTrackingPublisher(sender: AblyAssetTrackingPublisher, didUpdateLocation location: CLLocation)
}

public class AblyAssetTrackingPublisher {
    private let configuration: AblyConfiguration
    private let locationSerice: LocationService
    
    public weak var delegate: AblyAssetTrackingPublisherDelegate?
    
    public init(configuration: AblyConfiguration) {
        self.configuration = configuration
        self.locationSerice = LocationService()
    }
    
    public func start() {
        locationSerice.startUpdatingLocation()
    }
    
    public func stop() {
        locationSerice.stopUpdatingLocation()
    }
    
    // TODO - Clarify if we need those methods.
    public func requestAlwaysAuthorization() {
        locationSerice.requestAlwaysAuthorization()
    }
    
    public func requestWhenInUseAuthorization() {
        locationSerice.requestWhenInUseAuthorization()
    }
}

extension AblyAssetTrackingPublisher: LocationServiceDelegate {
    func locationService(sender: LocationService, didFailWithError error: Error) {
        delegate?.ablyAssetTrackingPublisher(sender: self, didFailWithError: error)
    }
    
    func locationService(sender: LocationService, didUpdateLocation location: CLLocation) {
        delegate?.ablyAssetTrackingPublisher(sender: self, didUpdateLocation: location)
        // TOOD - convert CLLocation to GeoJSON and pass to AblyService.
    }
}
