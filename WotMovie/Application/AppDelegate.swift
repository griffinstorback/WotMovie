//
//  AppDelegate.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-06.
//

import UIKit
import CoreData
import Appodeal

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IAPManager.shared.startObserving()
        
        Appodeal.initialize(withApiKey: "b69e97c9e3951577965b129806e50a3026c74d5ea551fdd0", types: [.banner, .interstitial], hasConsent: false)
        Appodeal.setTestingEnabled(true)
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        IAPManager.shared.stopObserving()
    }
    

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

