//
//  GeoJSONMessage.swift
//  Core
//
//  Created by Michal Miedlarz on 02/12/2020.
//  Copyright © 2020 Ably. All rights reserved.
//

import CoreLocation

class GeoJSONMessage: Codable {
    let type: GeoJSONType
    let geometry: GeoJSONGeometry
    let properties: GeoJSONProperties
    
    init(location: CLLocation) {
        type = .feature
        geometry = GeoJSONGeometry(location: location)
        properties = GeoJSONProperties(location: location)
    }
    
    func toCoreLocation() -> CLLocation? {
        guard let longitude = geometry.coordinates.first,
              let latitude = geometry.coordinates.last
        else { return nil }
        
        return CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            altitude: properties.altitude,
            horizontalAccuracy: properties.accuracyHorizontal,
            verticalAccuracy: -1,
            course: properties.bearing,
            speed: properties.speed,
            timestamp: Date(timeIntervalSince1970: properties.time))
    }
}

