//
//  ListCategoryGridPresenter.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-01-26.
//

import Foundation
import UIKit

enum CategoryDisplayTypes: String {
    case movies = "Movies"
    case tvShows = "TV Shows"
    case people = "People"
    case all = "All"
    case moviesAndTVShows = "Movies & TV"
}

protocol ListCategoryGridPresenterProtocol: TransitionPresenterProtocol {
    var itemsCount: Int { get }
    
    func loadItems()
    func setViewDelegate(_ listCategoryGridViewDelegate: ListCategoryGridViewDelegate?)
    func itemFor(index: Int) -> Entity
    func getTypesCurrentlyDisplaying() -> CategoryDisplayTypes
    func getTypesAvailableToDisplay() -> [(String,CategoryDisplayTypes)]
    func setTypesToDisplay(listCategoryDisplayTypes: CategoryDisplayTypes)
    func setSearchText(_ text: String?)
    func getSortParameters() -> SortParameters
    func setSortParameters(_ sortParameters: SortParameters)
    func loadImageFor(index: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void)
}

// TODO: Should make all presenters conform to a BasePresenter class, which should contain
//       methods all presenters (or most) use like loadImageFor(index).
class ListCategoryGridPresenter: NSObject, ListCategoryGridPresenterProtocol {
    private let imageDownloadManager: ImageDownloadManagerProtocol
    private let coreDataManager: CoreDataManager
    weak var listCategoryGridViewDelegate: ListCategoryGridViewDelegate?
    
    private var sortParameters: SortParameters {
        didSet {
            updateFilter()
        }
    }
    
    private var typesDisplayed: CategoryDisplayTypes {
        didSet {
            updateFilter()
        }
    }
    private var searchString: String = "" {
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
        
        switch sortParameters.sortBy {
        case .dateAdded:
            break
        case .alphabetical:
            filteredResults = filteredResults.sorted { $0.name.lowercased() < $1.name.lowercased() }
        case .releaseDate:
            break
        }
        
        items = filteredResults
        
        // tell view to reload
        DispatchQueue.main.async {
            self.listCategoryGridViewDelegate?.reloadData()
        }
    }
    
    // contains all items retrieved for this ListCategoryType. filter from this and assign to 'items'
    private var allItems: [Entity] = [] {
        didSet {
            updateFilter()
        }
    }
    
    // the items currently being displayed
    private var items: [Entity] = []
    var itemsCount: Int {
        return items.count
    }
    
    init(imageDownloadManager: ImageDownloadManagerProtocol = ImageDownloadManager.shared,
         coreDataManager: CoreDataManager = CoreDataManager.shared,
         listCategoryType: ListCategoryType) {
        self.imageDownloadManager = imageDownloadManager
        self.coreDataManager = coreDataManager
        
        self.sortParameters = SortParameters(categoryType: listCategoryType)
        
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
    
    func getTypesCurrentlyDisplaying() -> CategoryDisplayTypes {
        return typesDisplayed
    }
    
    // types to display in drop down menu at top right (right bar item)
    func getTypesAvailableToDisplay() -> [(String,CategoryDisplayTypes)] {
        
        switch sortParameters.listCategoryType {
        case .allGuessed, .allRevealed:
            return [
                (CategoryDisplayTypes.all.rawValue, .all),
                (CategoryDisplayTypes.movies.rawValue, .movies),
                (CategoryDisplayTypes.tvShows.rawValue, .tvShows),
                (CategoryDisplayTypes.people.rawValue, .people)
            ]
        case .movieOrTvShowWatchlist:
            return [
                (CategoryDisplayTypes.moviesAndTVShows.rawValue, .moviesAndTVShows),
                (CategoryDisplayTypes.movies.rawValue, .movies),
                (CategoryDisplayTypes.tvShows.rawValue, .tvShows)
            ]
        case .personFavorites:
            return []
        }
    }
    
    func setTypesToDisplay(listCategoryDisplayTypes: CategoryDisplayTypes) {
        guard sortParameters.listCategoryType != .personFavorites else { return } // person favorites has only people type.
        
        typesDisplayed = listCategoryDisplayTypes
    }
    
    func setSearchText(_ text: String?) {
        searchString = text ?? ""
    }
    
    func getSortParameters() -> SortParameters {
        return self.sortParameters
    }
    
    func setSortParameters(_ sortParameters: SortParameters) {
        self.sortParameters = sortParameters
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
        switch sortParameters.listCategoryType {
        case .movieOrTvShowWatchlist:
            let items = coreDataManager.fetchWatchlist(genreID: -1)
            allItems = items
        case .personFavorites:
            let items = coreDataManager.fetchFavoritePeople()
            allItems = items
        case .allGuessed:
            let items = coreDataManager.fetchGuessedEntities()
            allItems = items
        case .allRevealed:
            let items = coreDataManager.fetchRevealedEntities()
            allItems = items
        }
    }
}

// TransitionPresenterProtocol - called when dismissing modal detail (if item was revealed/added to watchlist while modal was up)
extension ListCategoryGridPresenter {
    // this shouldn't ever be called here - there shouldn't be any hidden itemy in any ListCategoryGridView
    func setEntityAsRevealed(id: Int, isCorrect: Bool) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            if isCorrect { // if entity was correctly guessed
                if !items[index].correctlyGuessed {
                    items[index].correctlyGuessed = true
                    DispatchQueue.main.async {
                        self.listCategoryGridViewDelegate?.revealCorrectlyGuessedEntities(at: [index])
                    }
                }
            } else { // if entity was revealed (user gave up)
                if !items[index].isRevealed {
                    items[index].isRevealed = true
                    DispatchQueue.main.async {
                        self.listCategoryGridViewDelegate?.revealEntities(at: [index])
                    }
                }
            }
        }
    }
    
    // either add entity to watchlist/favorites, or remove it.
    func setEntityAsFavorite(id: Int, entityWasAdded: Bool) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            if entityWasAdded {
                items[index].isFavorite = true
            } else { // entity was removed from favorites/watchlist
                items[index].isFavorite = false
            }
        }
    }
    
    func presentNextQuestion(currentQuestionID: Int) {
        // nothing
        print("** WARNING: 'nextQuestion' was attempted in listCategoryGridPresenter for \(sortParameters.listCategoryType). The next button was likely pressed - it should not be present in detail presented from here.")
    }
}
