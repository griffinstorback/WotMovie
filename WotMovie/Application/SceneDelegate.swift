//
//  SceneDelegate.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-06.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.windowScene = windowScene
        
        window?.tintColor = UIColor(named: "AccentColor") ?? Constants.Colors.defaultBlue
        
        // TODO: Check SettingsManager - if user hasn't seen intro pages, show intro pages view (swipe through) instead of RootTabView
        
        window?.rootViewController = RootTabViewController()
        
        // keep reference to the scene delegate in settings manager, so it can change user interface style.
        SettingsManager.shared.mainSceneDelegate = self
        
        window?.makeKeyAndVisible()
    }
    
    // check if user has set dark/light mode manually (i.e. doesn't want to reflect device setting)
    func setDarkMode() {
        if !SettingsManager.shared.darkModeSetAutomatic {
            setDarkModeTo(darkMode: SettingsManager.shared.isDarkMode)
        } else {
            setDarkModeToReflectDeviceSettings()
        }
    }
    
    // call when changes to dark mode settings are made (see SettingsManager)
    func setDarkModeToReflectDeviceSettings() {
        window?.overrideUserInterfaceStyle = UIScreen.main.traitCollection.userInterfaceStyle
        
        // in case dark mode pref was changed when app backgrounded, now that it is foregrounded, make sure isDarkMode reflects current interface appearance
        SettingsManager.shared.makeSureIsDarkModeReflectsCurrentSetting()
    }
    func setDarkModeTo(darkMode: Bool) {
        if darkMode {
            window?.overrideUserInterfaceStyle = .dark
        } else {
            window?.overrideUserInterfaceStyle = .light
        }
    }
    
    // (NOT USED ANYMORE) was used to set the root tab view controller after into/tutorial pages have been swiped through, now tutorial is modally presented
    func setRootViewController(_ vc: UIViewController) {
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        
        // update dark mode val in case user changed preferences while app was backgrounded
        setDarkMode()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        CoreDataStack.shared.saveContext()
    }


}

