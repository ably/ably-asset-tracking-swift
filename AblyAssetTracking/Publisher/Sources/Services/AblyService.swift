//
//  AblyService.swift
//  Publisher
//
//  Created by Michal Miedlarz on 02/12/2020.
//  Copyright © 2020 Ably. All rights reserved.
//

import UIKit
import Ably

public class AblyService {
    private let client: ARTRealtime
    
    init(apiKey: String) {
        self.client = ARTRealtime(key: apiKey)
    }
}
