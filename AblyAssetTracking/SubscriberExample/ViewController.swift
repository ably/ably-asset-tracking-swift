//
//  ViewController.swift
//  SubscriberExample
//
//  Created by Michal Miedlarz on 01/12/2020.
//  Copyright © 2020 Ably. All rights reserved.
//

import UIKit
import Subscriber

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Temporary test to validate if we have acess to Subscriber framework
        let _ = AblyAssetTrackingSubscriber()
    }


}

