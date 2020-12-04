//
//  GeoJSONProperties.swift
//  AblyAssetTracking
//
//  Created by Michal Miedlarz on 02/12/2020.
//  Copyright © 2020 Ably. All rights reserved.
//

import CoreLocation

/**
 Part of DTO used in `GeoJSONMessage`, used to map GeoJSON properties field (as defined in https://geojson.org ).
 */
class GeoJSONProperties: Codable {
    let accuracyHorizontal: Double
    let altitude: Double
    let bearing: Double
    
    /*
     * Object speed in meters per second
     */
    let speed: Double
    
    /*
     * Timestamp from a moment when measurment was done (in seconds since 1st of January 1970)
     */
    let time: Double
    
    init(location: CLLocation) {
        accuracyHorizontal = location.horizontalAccuracy
        altitude = location.altitude
        bearing = location.course
        speed = location.speed
        time = location.timestamp.timeIntervalSince1970
    }
}
