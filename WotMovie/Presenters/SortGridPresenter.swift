//
//  SortGridPresenter.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-02-09.
//

import Foundation

protocol SortGridPresenterProtocol {
    func setViewDelegate(_ sortGridViewDelegate: SortGridViewDelegate?)
    func getSortParameters() -> SortParameters
    
    func getNumberOfSections() -> Int
    func getTextForHeaderInSection(_ section: Int) -> String
    func getNumberOfItemsInSection(_ section: Int) -> Int
    func getTextForItemAt(_ indexPath: IndexPath) -> String
    func itemIsSelected(at indexPath: IndexPath) -> Bool
    func didSelectItemAt(_ indexPath: IndexPath)
}

class SortGridPresenter: SortGridPresenterProtocol {
    
    weak var sortGridViewDelegate: SortGridViewDelegate?
    
    var sortParameters: SortParameters {
        didSet {
            DispatchQueue.main.async {
                self.sortGridViewDelegate?.reloadData()
            }
        }
    }
    
    init(sortParameters: SortParameters) {
        self.sortParameters = sortParameters
    }
    
    func setViewDelegate(_ sortGridViewDelegate: SortGridViewDelegate?) {
        self.sortGridViewDelegate = sortGridViewDelegate
    }
    
    func getSortParameters() -> SortParameters {
        return sortParameters
    }
    
    func getNumberOfSections() -> Int {
        return 1
    }
    
    func getTextForHeaderInSection(_ section: Int) -> String {
        if section == 0 {
            return "Sort by"
        }
        
        return ""
    }
    
    func getNumberOfItemsInSection(_ section: Int) -> Int {
        if section == 0 {
            return SortBy.allCases.count
        }
        return 0
    }
    
    func getTextForItemAt(_ indexPath: IndexPath) -> String {
        if indexPath.section == 0 {
            return SortBy.allCases[indexPath.row].rawValue
        }
        
        return ""
    }
    
    func itemIsSelected(at indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            // true if this item is the selected "SortBy" state
            return SortBy.allCases[indexPath.row] == sortParameters.sortBy
        }
        
        return false
    }
    
    func didSelectItemAt(_ indexPath: IndexPath) {
        if indexPath.section == 0 {
            sortParameters.sortBy = SortBy.allCases[indexPath.row]
        }
    }
}
