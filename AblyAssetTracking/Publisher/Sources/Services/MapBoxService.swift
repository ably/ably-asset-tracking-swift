//
//  MapBoxService.swift
//  Publisher
//
//  Created by Michal Miedlarz on 02/12/2020.
//  Copyright © 2020 Ably. All rights reserved.
//

import MapboxCoreNavigation

class MapBoxService {
    private let locationManager: NavigationLocationManager
    
    public init() {
        self.locationManager = NavigationLocationManager()        
    }
}
