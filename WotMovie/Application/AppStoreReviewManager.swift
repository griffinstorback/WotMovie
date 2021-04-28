//
//  AppStoreReviewManager.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-04-27.
//

import Foundation
import StoreKit

enum AppStoreReviewManager {
        
    // update counter in UserDefaults for number of bottles opened - if it is above threshold, request appstore review from user
    static func requestReviewIfAppropriate() {
        let settingsManager = SettingsManager.shared
        let coreDataManager = CoreDataManager.shared
        
        let bundle = Bundle.main
        
        let bundleVersionKey = kCFBundleVersionKey as String
        let currentVersion = bundle.object(forInfoDictionaryKey: bundleVersionKey) as? String
        let lastVersion = settingsManager.lastReviewRequestAppVersion
        
        if lastVersion == nil || lastVersion != currentVersion {
            print("****************** lastVersion was found to be \(lastVersion)")
            if coreDataManager.userHasUsedAppEnoughToWarrantAskingForReview() {
                print("****************** core data manager says its ok to ask for review")
                SKStoreReviewController.requestReview()
                settingsManager.lastReviewRequestAppVersion = currentVersion
            }
        }
    }
}
