//
//  TruckAnnotation.swift
//  SubscriberExample
//
//  Created by Michal Miedlarz on 09/12/2020.
//  Copyright © 2020 Ably. All rights reserved.
//

import UIKit
import MapKit

enum TruckAnnotationType {
    case raw
    case enhanced
}

class TruckAnnotation: MKPointAnnotation {
    var bearing: Double = 0
    var type: TruckAnnotationType = .raw
}
