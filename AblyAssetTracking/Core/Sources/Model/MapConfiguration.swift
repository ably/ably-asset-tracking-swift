//
//  MapConfiguration.swift
//  Core
//
//  Created by Michal Miedlarz on 02/12/2020.
//  Copyright © 2020 Ably. All rights reserved.
//

import UIKit

public class MapConfiguration: NSObject {
    let apiKey: String
    
    public init(apiKey: String) {
        self.apiKey = apiKey
    }
}
