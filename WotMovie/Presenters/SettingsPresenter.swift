//
//  SettingsPresenter.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-02-13.
//

import Foundation

protocol SettingsPresenterProtocol {
    func setViewDelegate(_ settingsViewDelegate: SettingsViewDelegate?)
    func isPersonCategoryLocked() -> Bool
    func isDarkModeOn() -> Bool
    func setDarkModeOn(_ isOn: Bool)
    func isDarkModeSetAutomaticallyOn() -> Bool
    func setDarkModeSetAutomaticallyOn(_ isOn: Bool)
    
    func getNumberOfSections() -> Int
    func getTextForHeaderInSection(_ section: Int) -> String
    func getNumberOfItemsInSection(_ section: Int) -> Int
    func getTypeForItemAt(_ indexPath: IndexPath) -> SettingsRowType
    func didSelectItemAt(_ indexPath: IndexPath)
}

// used to determine what to display in row, both text and accessory view
enum SettingsRowType: String {
    case about = "About"
    case stats = "Stats"
    case darkMode = "Dark mode"
    case darkModeSetAutomatically = "Use device's dark mode settings"
    case restorePurchases = "Restore purchases"
    case dataReset = "Data reset"
}

class SettingsPresenter: SettingsPresenterProtocol {
    let coreDataManager: CoreDataManager
    let iapManager: IAPManager
    let keychain: Keychain
    let settingsManager: SettingsManager
    weak var settingsViewDelegate: SettingsViewDelegate?
    
    // static cell data
    let sections: [[SettingsRowType]] = [
        [.about],
        [.stats],
        [.darkMode, .darkModeSetAutomatically],
        [.restorePurchases],
        [.dataReset]
    ]
    let sectionTitles: [String] = [
        "",
        "",
        "Appearance",
        "",
        ""
    ]
    
    init(coreDataManager: CoreDataManager = CoreDataManager.shared,
         iapManager: IAPManager = IAPManager.shared,
         keychain: Keychain = Keychain.shared,
         settingsManager: SettingsManager = SettingsManager.shared) {
        self.coreDataManager = coreDataManager
        self.iapManager = iapManager
        self.keychain = keychain
        self.settingsManager = settingsManager
        
        // listen for notification that user has upgraded
        NotificationCenter.default.addObserver(self, selector: #selector(upgradeStatusChanged), name: .WMUserDidUpgrade, object: nil)
    }
    
    @objc private func upgradeStatusChanged() {
        settingsViewDelegate?.reloadData()
    }
    
    func isPersonCategoryLocked() -> Bool {
        let userHasPurchasedUpgrade = keychain[Constants.KeychainStrings.personUpgradePurchasedKey] == Constants.KeychainStrings.personUpgradePurchasedValue
        return !userHasPurchasedUpgrade
    }
    
    func isDarkModeOn() -> Bool {
        return settingsManager.isDarkMode
    }
    
    func setDarkModeOn(_ isOn: Bool) {
        settingsManager.isDarkMode = isOn
        settingsViewDelegate?.reloadSwitchesState()
    }
    
    func isDarkModeSetAutomaticallyOn() -> Bool {
        return settingsManager.darkModeSetAutomatic
    }
    
    func setDarkModeSetAutomaticallyOn(_ isOn: Bool) {
        settingsManager.darkModeSetAutomatic = isOn
        settingsViewDelegate?.reloadSwitchesState()
    }
    
    func setViewDelegate(_ settingsViewDelegate: SettingsViewDelegate?) {
        self.settingsViewDelegate = settingsViewDelegate
    }
    
    func getNumberOfSections() -> Int {
        return sections.count
    }
    
    func getTextForHeaderInSection(_ section: Int) -> String {
        guard section < sectionTitles.count else { return "" }
        
        return sectionTitles[section]
    }
    
    func getNumberOfItemsInSection(_ section: Int) -> Int {
        guard section < sections.count else { return 0 }
        
        return sections[section].count
    }
    
    func getTypeForItemAt(_ indexPath: IndexPath) -> SettingsRowType {
        let section = indexPath.section
        guard section < sections.count else { return .about }
        
        let row = indexPath.row
        guard row < sections[section].count else { return .about }
        
        return sections[section][row]
    }
    
    func didSelectItemAt(_ indexPath: IndexPath) {
        let section = indexPath.section
        guard section < sections.count else { return }
        
        let row = indexPath.row
        guard row < sections[section].count else { return }
        
        let selectedRow = sections[section][row]
        
        switch selectedRow {
        case .about:
            let aboutViewController = AboutViewController()
            settingsViewDelegate?.presentDetailViewController(aboutViewController)
        case .stats:
            let statsViewController = StatsViewController()
            settingsViewDelegate?.presentDetailViewController(statsViewController)
        case .restorePurchases:
            iapManager.restorePurchases { result in
                switch result {
                case .success(let success):
                    if success {
                        // did finish restoring purchased products
                        self.settingsViewDelegate?.presentBriefAlert(title: "Products restored")
                    } else {
                        // did finish restoring purchases with 0 products
                        self.settingsViewDelegate?.presentBriefAlert(title: "No products found to restore")
                    }
                case .failure(let error):
                    print("** ERROR RESTORING PURCHASES: \(error)")
                }
            }
        case .dataReset:
            let dataResetViewController = DataResetViewController()
            settingsViewDelegate?.presentDetailViewController(dataResetViewController)
        case .darkMode, .darkModeSetAutomatically:
            // these rows shouldn't be tapped - they have switches inside them that call their own functions
            break
        }
    }
}
