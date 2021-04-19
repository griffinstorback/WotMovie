//
//  DataResetPresenter.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-04-14.
//

import Foundation

protocol DataResetPresenterProtocol {
    func setViewDelegate(_ delegate: DataResetViewDelegate?)
    func getNumberOfSections() -> Int
    func getTextForHeaderInSection(_ section: Int) -> String
    func getNumberOfItemsInSection(_ section: Int) -> Int
    func getTypeForItemAt(_ indexPath: IndexPath) -> DataResetRowType
    func didSelectItemAt(_ indexPath: IndexPath)
    
    func didConfirmResetFor(_ type: DataResetRowType)
    func didConfirmResetAllTwice()
}


enum DataResetRowType: String {
    case resetMovies = "Reset Movies"
    case resetTVShows = "Reset TV Shows"
    case resetPeople = "Reset People"
    
    case resetWatchlist = "Clear all from watchlist"
    case resetFavorites = "Clear all from favorites"
    
    case resetAll = "Reset all app data"
}
class DataResetPresenter: DataResetPresenterProtocol {
    private let coreDataManager: CoreDataManager
    weak var dataResetViewDelegate: DataResetViewDelegate?
    
    // static cell data
    let sections: [[DataResetRowType]] = [
        [.resetMovies, .resetTVShows, .resetPeople],
        [.resetWatchlist, .resetFavorites],
        [.resetAll]
    ]
    let sectionTitles: [String] = [
        "Note: If the People category hasn't been unlocked yet, resetting Movie/TV Show data will affect progress",
        "",
        ""
    ]
    
    init(coreDataManager: CoreDataManager = CoreDataManager.shared) {
        self.coreDataManager = coreDataManager
    }
    
    func setViewDelegate(_ delegate: DataResetViewDelegate?) {
        dataResetViewDelegate = delegate
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
    
    func getTypeForItemAt(_ indexPath: IndexPath) -> DataResetRowType {
        let section = indexPath.section
        guard section < sections.count else { return .resetMovies }
        
        let row = indexPath.row
        guard row < sections[section].count else { return .resetMovies }
        
        return sections[section][row]
    }
    
    func didSelectItemAt(_ indexPath: IndexPath) {
        let section = indexPath.section
        guard section < sections.count else { return }
        
        let row = indexPath.row
        guard row < sections[section].count else { return }
        
        let selectedRow = sections[section][row]
        
        dataResetViewDelegate?.presentConfirmationFor(selectedRow, isSecondConfirmation: false)
    }
    
    func didConfirmResetFor(_ type: DataResetRowType) {
        switch type {
        case .resetMovies:
            coreDataManager.resetMovieData()
        case .resetTVShows:
            coreDataManager.resetTVShowData()
        case .resetPeople:
            coreDataManager.resetPersonData()
        case .resetWatchlist:
            coreDataManager.resetWatchlistData()
        case .resetFavorites:
            coreDataManager.resetFavoritesData()
        case .resetAll:
            // present second confirmation, because this resets all
            dataResetViewDelegate?.presentConfirmationFor(.resetAll, isSecondConfirmation: true)
        }
    }
    
    func didConfirmResetAllTwice() {
        coreDataManager.resetAllData()
    }
}
