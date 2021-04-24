//
//  SettingsManager.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-04-13.
//

import Foundation
import UIKit

enum SettingsKeys: String {
    case darkModeSetAutomatic = "DarkModeSetAutomatic"
    case isDarkMode = "IsDarkMode" // if darkModeSetAutomatic is true, set this value to mirror it. (true means dark mode, false light mode)
    
    case userHasSeenIntroPages = "UserHasSeenIntroPages" // set to true as soon as user has swiped through intro pages (first time launching app)
}

class SettingsManager {
    static let shared = SettingsManager()
    private init() {
        
        
        UserDefaults.standard.register(defaults: [
            SettingsKeys.darkModeSetAutomatic.rawValue: true
        ])
    }
    
    var mainSceneDelegate: SceneDelegate?
    
    var isDarkMode: Bool {
        get {
            return UserDefaults.standard.bool(forKey: SettingsKeys.isDarkMode.rawValue)
        }
        set {
            // set the user's choice
            UserDefaults.standard.set(newValue, forKey: SettingsKeys.isDarkMode.rawValue)
            
            // since the user has made a choice, turn off darkModeSetAutomatic (if its on)
            darkModeSetAutomatic = false
            
            // finally, make the change to the window object (in SceneDelegate)
            mainSceneDelegate?.setDarkModeTo(darkMode: newValue)
        }
    }
    
    var darkModeSetAutomatic: Bool {
        get {
            return UserDefaults.standard.bool(forKey: SettingsKeys.darkModeSetAutomatic.rawValue)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: SettingsKeys.darkModeSetAutomatic.rawValue)
            
            // if, by setting this value, dark mode is enabled/disabled, reload in scene delegate.
            mainSceneDelegate?.setDarkModeToReflectDeviceSettings()
            
            // if setAutomatic is being turned on, depending on what device dark mode is set to, make isDarkMode reflect it
            if newValue == true {
                UserDefaults.standard.set(isDeviceDarkModeSet(), forKey: SettingsKeys.isDarkMode.rawValue)
            }
        }
    }
    
    // returns true if dark mode is set in the devices system settings
    func isDeviceDarkModeSet() -> Bool {
        switch UIScreen.main.traitCollection.userInterfaceStyle {
        case .light:
            return false
        case .dark:
            return true
        case .unspecified:
            return false
        @unknown default:
            return false
        }
    }
    
    func makeSureIsDarkModeReflectsCurrentSetting() {
        if darkModeSetAutomatic {
            UserDefaults.standard.set(isDeviceDarkModeSet(), forKey: SettingsKeys.isDarkMode.rawValue)
        }
    }
    
    var useHasSeenIntroPages: Bool {
        get {
            return UserDefaults.standard.bool(forKey: SettingsKeys.userHasSeenIntroPages.rawValue)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: SettingsKeys.userHasSeenIntroPages.rawValue)
        }
    }
}
