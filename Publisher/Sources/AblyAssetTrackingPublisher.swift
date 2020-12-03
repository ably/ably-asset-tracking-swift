//
//  AblyAssetTrackingPublisher.swift
//  Publisher
//
//  Created by Michal Miedlarz on 01/12/2020.
//  Copyright © 2020 Ably. All rights reserved.
//

import UIKit

public class AblyAssetTrackingPublisher {
    public init(configuration: AblyConfiguration) {}
        
    func testCoreDependency() {
        // Temporary function to test if we can use Core classes here
        let _ = AblyClient()
    }
}
