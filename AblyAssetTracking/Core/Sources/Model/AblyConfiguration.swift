//
//  AblyConfiguration.swift
//  Core
//
//  Created by Michal Miedlarz on 02/12/2020.
//  Copyright © 2020 Ably. All rights reserved.
//

import UIKit

public class AblyConfiguration: NSObject {
    let apiKey: String
    let clientId: String
    
    init(apiKey: String, clientId: String) {
        self.apiKey = apiKey
        self.clientId = clientId
    }
}
