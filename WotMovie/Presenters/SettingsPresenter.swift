//
//  SettingsPresenter.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-02-13.
//

import Foundation

protocol SettingsPresenterProtocol {
    func setViewDelegate(_ settingsViewDelegate: SettingsViewDelegate?)
    func getNumberOfSections() -> Int
    func getTextForHeaderInSection(_ section: Int) -> String
    func getNumberOfItemsInSection(_ section: Int) -> Int
    func getTextForItemAt(_ indexPath: IndexPath) -> String
    func didSelectItemAt(_ indexPath: IndexPath)
}

class SettingsPresenter: SettingsPresenterProtocol {
    let coreDataManager: CoreDataManagerProtocol
    weak var settingsViewDelegate: SettingsViewDelegate?
    
    // static cell data
    let sections: [[String]] = [
        ["Stats"],
        ["Appearance", "Remove ads", "Restore purchases"],
        ["Delete all app data"]
    ]
    
    init(coreDataManager: CoreDataManagerProtocol = CoreDataManager.shared) {
        self.coreDataManager = coreDataManager
    }
    
    func setViewDelegate(_ settingsViewDelegate: SettingsViewDelegate?) {
        self.settingsViewDelegate = settingsViewDelegate
    }
    
    func getNumberOfSections() -> Int {
        return sections.count
    }
    
    func getTextForHeaderInSection(_ section: Int) -> String {
        guard section < sections.count else { return "" }
        
        return ""
    }
    
    func getNumberOfItemsInSection(_ section: Int) -> Int {
        guard section < sections.count else { return 0 }
        
        return sections[section].count
    }
    
    func getTextForItemAt(_ indexPath: IndexPath) -> String {
        let section = indexPath.section
        guard section < sections.count else { return "" }
        
        let row = indexPath.row
        guard row < sections[section].count else { return "" }
        
        return sections[section][row]
    }
    
    func didSelectItemAt(_ indexPath: IndexPath) {
        let section = indexPath.section
        guard section < sections.count else { return }
        
        let row = indexPath.row
        guard row < sections[section].count else { return }
        
        print("*** SELECTED \(sections[section][row])")
        
        if sections[section][row] == "Stats" {
            let statsViewController = StatsViewController()
            settingsViewDelegate?.presentDetailViewController(statsViewController)
        }
    }
}
