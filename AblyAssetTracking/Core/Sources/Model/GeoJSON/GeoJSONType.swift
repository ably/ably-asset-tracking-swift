//
//  GeoJSONType.swift
//  AblyAssetTracking
//
//  Created by Michal Miedlarz on 02/12/2020.
//  Copyright © 2020 Ably. All rights reserved.
//

import Foundation

enum GeoJSONType: String, Codable {
    case feature = "Feature"
    case point = "Point"
}
