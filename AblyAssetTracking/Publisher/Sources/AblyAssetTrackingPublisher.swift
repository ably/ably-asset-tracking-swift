//
//  AblyAssetTrackingPublisher.swift
//  Publisher
//
//  Created by Michal Miedlarz on 01/12/2020.
//  Copyright © 2020 Ably. All rights reserved.
//

import UIKit
import Core

public class AblyAssetTrackingPublisher {
    public init() {}
        
    func testCoreDependency() {
        // Temporary function to test if we can use Core classes here
        let _ = AblyClient()
    }
}
