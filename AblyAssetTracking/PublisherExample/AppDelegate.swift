//
//  AppDelegate.swift
//  PublisherExample
//
//  Created by Michal Miedlarz on 01/12/2020.
//  Copyright © 2020 Ably. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateInitialViewController()
    
        window?.rootViewController = initialViewController
        window?.makeKeyAndVisible()
        
        return true
    }
}

