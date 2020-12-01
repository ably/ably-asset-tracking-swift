//
//  ViewController.swift
//  PublisherExample
//
//  Created by Michal Miedlarz on 01/12/2020.
//  Copyright © 2020 Ably. All rights reserved.
//

import UIKit
import Publisher

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Temporary test to validate if we have access to Publisher data
        let _ = AblyAssetTrackingPublisher()
    }
}
