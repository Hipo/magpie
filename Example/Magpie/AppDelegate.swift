//
//  AppDelegate.swift
//  Magpie
//
//  Created by eraydiler on 09/10/2018.
//  Copyright (c) 2018 eraydiler. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private lazy var api = MOMAPI(base: "https://staging.moment.com")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        window?.rootViewController = ViewController(api: api)
        window?.makeKeyAndVisible()
        
        return true
    }
}

