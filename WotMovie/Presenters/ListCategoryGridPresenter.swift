//
//  ListCategoryGridPresenter.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-01-26.
//

import Foundation
import UIKit

enum ListCategoryDisplayTypes: String {
    case movies = "Movies"
    case tvShows = "TV Shows"
    case people = "People"
    case all = "All types"
    case moviesAndTVShows = "Movies & TV"
}

protocol ListCategoryGridPresenterProtocol {
    var listCategoryType: ListCategoryType { get }
    var itemsCount: Int { get }
    
    func loadItems()
    func setViewDelegate(_ listCategoryGridViewDelegate: ListCategoryGridViewDelegate?)
    func itemFor(index: Int) -> Entity
    func getTypesAvailableToDisplay() -> [(String,ListCategoryDisplayTypes)]
    func setTypesToDisplay(listCategoryDisplayTypes: ListCategoryDisplayTypes)
    func loadImageFor(index: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void)
}

// TODO: Should make all presenters conform to a BasePresenter class, which should contain
//       methods all presenters (or most) use like loadImageFor(index).
class ListCategoryGridPresenter: ListCategoryGridPresenterProtocol {
    private let imageDownloadManager: ImageDownloadManagerProtocol
    private let coreDataManager: CoreDataManager
    weak var listCategoryGridViewDelegate: ListCategoryGridViewDelegate?
    
    let listCategoryType: ListCategoryType
    var typesDisplayed: ListCategoryDisplayTypes {
        didSet {
            updateFilter()
        }
    }
    var searchString: String = "" {
        didSet {
            updateFilter()
        }
    }
    private func updateFilter() {
        var filteredResults = allItems
        
        switch typesDisplayed {
        case .all:
            break
        case .moviesAndTVShows:
            break // could filter for only movies & tv shows, but this option only replaces "all" for watchlist section
        case .movies:
            filteredResults = filteredResults.filter { $0.type == .movie }
        case .tvShows:
            filteredResults = filteredResults.filter { $0.type == .tvShow }
        case .people:
            filteredResults = filteredResults.filter { $0.type == .person }
        }
        
        if !searchString.isEmpty {
            filteredResults = filteredResults.filter { $0.name.lowercased().contains(searchString.lowercased()) }
        }
        
        //
        // SORT!
        //
        
        items = filteredResults
    }
    
    // contains all items retrieved for this ListCategoryType. filter from this and assign to 'items'
    private var allItems: [Entity] = [] {
        didSet {
            updateFilter()
        }
    }
    
    // the items currently being displayed
    private var items: [Entity] = [] {
        didSet {
            DispatchQueue.main.async {
                self.listCategoryGridViewDelegate?.reloadData()
            }
        }
    }
    var itemsCount: Int {
        return items.count
    }
    
    init(imageDownloadManager: ImageDownloadManagerProtocol = ImageDownloadManager.shared,
         coreDataManager: CoreDataManager = CoreDataManager.shared,
         listCategoryType: ListCategoryType) {
        self.imageDownloadManager = imageDownloadManager
        self.coreDataManager = coreDataManager
        
        self.listCategoryType = listCategoryType
        
        switch listCategoryType {
        case .allGuessed, .allRevealed:
            typesDisplayed = .all
        case .movieOrTvShowWatchlist:
            typesDisplayed = .moviesAndTVShows
        case .personFavorites:
            // person favorites list only shows people, so this should never change.
            typesDisplayed = .people
        }
    }
    
    func loadItems() {
        getNextPageFromCoreData()
    }
    
    func setViewDelegate(_ listCategoryGridViewDelegate: ListCategoryGridViewDelegate?) {
        self.listCategoryGridViewDelegate = listCategoryGridViewDelegate
    }
    
    func itemFor(index: Int) -> Entity {
        return items[index]
    }
    
    // types to display in drop down menu at top right (right bar item)
    func getTypesAvailableToDisplay() -> [(String,ListCategoryDisplayTypes)] {
        
        switch listCategoryType {
        case .allGuessed, .allRevealed:
            return [
                (ListCategoryDisplayTypes.all.rawValue, .all),
                (ListCategoryDisplayTypes.movies.rawValue, .movies),
                (ListCategoryDisplayTypes.tvShows.rawValue, .tvShows),
                (ListCategoryDisplayTypes.people.rawValue, .people)
            ]
        case .movieOrTvShowWatchlist:
            return [
                (ListCategoryDisplayTypes.moviesAndTVShows.rawValue, .moviesAndTVShows),
                (ListCategoryDisplayTypes.movies.rawValue, .movies),
                (ListCategoryDisplayTypes.tvShows.rawValue, .tvShows)
            ]
        case .personFavorites:
            return []
        }
    }
    
    func setTypesToDisplay(listCategoryDisplayTypes: ListCategoryDisplayTypes) {
        guard listCategoryType != .personFavorites else { return } // person favorites has only people type.
        
        typesDisplayed = listCategoryDisplayTypes
    }
    
    func loadImageFor(index: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void) {
        let item = items[index]
        
        if let posterPath = item.posterPath {
            imageDownloadManager.downloadImage(path: posterPath) { image, error in
                if let error = error {
                    print(error)
                    DispatchQueue.main.async {
                        completion(nil, nil)
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    completion(image, posterPath)
                }
            }
        } else {
            DispatchQueue.main.async {
                completion(nil, nil)
            }
        }
    }
    
    private func getNextPageFromCoreData() {
        switch listCategoryType {
        case .movieOrTvShowWatchlist:
            let items = coreDataManager.fetchWatchlist(genreID: -1)
            allItems += items
        case .personFavorites:
            let items = coreDataManager.fetchFavoritePeople()
            allItems += items
        case .allGuessed:
            let items = coreDataManager.fetchGuessedEntities()
            allItems += items
        case .allRevealed:
            let items = coreDataManager.fetchRevealedEntities()
            allItems += items
        }
    }
}
