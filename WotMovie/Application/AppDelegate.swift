//
//  AppDelegate.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-06.
//

import UIKit
import Appodeal

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IAPManager.shared.startObserving()
        
        Appodeal.initialize(withApiKey: "b69e97c9e3951577965b129806e50a3026c74d5ea551fdd0", types: [.banner], hasConsent: false)
                
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
    
    
    /*
    
     
     
     
    Tracking not used at all right now. TODO
 
    should move these functions to scene delegate, as well
    
    
     
     

    private struct AppodealConstants {
        static let key: String = ""
        static let adTypes: AppodealAdType = .banner
        static let logLevel: APDLogLevel = .debug
    }
    
    private func requestTrackingAuthorization() {
            #if canImport(AppTrackingTransparency)
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { _ in
                    DispatchQueue.main.async { [weak self] in
                        self?.synchroniseConsent()
                    }
                }
            } else {
                synchroniseConsent()
            }
            #else
            synchroniseConsent()
            #endif
        }
        
        // MARK: Appodeal Initialization
        private func initializeAppodealSDK() {
            /// Custom settings
            // Appodeal.setFramework(.native, version: "1.0.0")
            // Appodeal.setTriggerPrecacheCallbacks(true)
            // Appodeal.setLocationTracking(true)
            
            /// User Data
            // Appodeal.setUserId("userID")
            // Appodeal.setUserAge(25)
            // Appodeal.setUserGender(.male)
            Appodeal.setLogLevel(AppodealConstants.logLevel)
            Appodeal.setAutocache(true, types: AppodealConstants.adTypes)
            
            // Initialise Appodeal SDK with consent report
            if let consent = STKConsentManager.shared().consent {
                Appodeal.initialize(
                    withApiKey: AppodealConstants.key,
                    types: AppodealConstants.adTypes,
                    consentReport: consent
                )
            } else {
                Appodeal.initialize(
                    withApiKey: AppodealConstants.key,
                    types: AppodealConstants.adTypes
                )
            }
        }
    
    // MARK: Consent manager
    private func synchroniseConsent() {
        STKConsentManager.shared().synchronize(withAppKey: AppodealConstants.key) { error in
            error.map { print("Error while synchronising consent manager: \($0)") }
            guard STKConsentManager.shared().shouldShowConsentDialog == .true else {
                self.initializeAppodealSDK()
                return
            }
            
            STKConsentManager.shared().loadConsentDialog { [unowned self] error in
                error.map { print("Error while loading consent dialog: \($0)") }
                guard let controller = self.window?.rootViewController, STKConsentManager.shared().isConsentDialogReady else {
                    self.initializeAppodealSDK()
                    return
                }
                
                STKConsentManager.shared().showConsentDialog(fromRootViewController: controller, delegate: self)
            }
        }
    }*/
}

