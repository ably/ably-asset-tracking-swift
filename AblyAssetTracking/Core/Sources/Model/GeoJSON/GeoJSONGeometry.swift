//
//  GeoJSONGeometry.swift
//  AblyAssetTracking
//
//  Created by Michal Miedlarz on 02/12/2020.
//  Copyright © 2020 Ably. All rights reserved.
//

import CoreLocation

class GeoJSONGeometry: Codable {
    let type: GeoJSONType
    let coordinates: Array<Double> // Array of two elements: [Lon, Lat]
    
    init(location: CLLocation) {
        type = .point
        coordinates = [location.coordinate.longitude, location.coordinate.latitude]
    }
}
