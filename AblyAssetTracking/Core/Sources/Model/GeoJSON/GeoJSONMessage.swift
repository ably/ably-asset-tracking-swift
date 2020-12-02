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
}

