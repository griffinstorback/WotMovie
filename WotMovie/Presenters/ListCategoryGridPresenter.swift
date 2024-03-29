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
    func cancelLoadImageRequestFor(_ indexPath: IndexPath)
    
    func addItemToWatchlistOrFavorites(_ indexPath: IndexPath)
    func removeItemFromWatchlistOrFavorites(_ indexPath: IndexPath)
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
            // get rid of non-Title types (e.g. Person)
            var filteredResultsTitles: [Title] = []
            filteredResults.forEach { item in
                if let title = item as? Title {
                    filteredResultsTitles.append(title)
                }
            }
            
            // Sort by release date, newest appearing at top (and no release date items appearing at bottom, unless filtered out)
            filteredResults = filteredResultsTitles.sorted { $0.releaseDate ?? "" > $1.releaseDate ?? "" }//.filter { $0.releaseDate == nil }
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
            // stop the loading indicator once items have been fetched
            DispatchQueue.main.async {
                self.listCategoryGridViewDelegate?.allItemsDidLoad()
            }
            
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
        getNextPageFromCoreDataAsync()
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
        guard index < items.count else { return }
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
    
    func cancelLoadImageRequestFor(_ indexPath: IndexPath) {
        let index = indexPath.row
        guard index < items.count else { return }
        
        let item = items[index]
        if let posterPath = item.posterPath {
            imageDownloadManager.cancelImageDownload(path: posterPath)
        }
    }
    
    func addItemToWatchlistOrFavorites(_ indexPath: IndexPath) {
        let index = indexPath.row
        guard index < items.count else { return }
        
        coreDataManager.addEntityToWatchlistOrFavorites(entity: items[index])
        items[index].isFavorite = true
    }
    
    func removeItemFromWatchlistOrFavorites(_ indexPath: IndexPath) {
        let index = indexPath.row
        guard index < items.count else { return }
        
        coreDataManager.removeEntityFromWatchlistOrFavorites(entity: items[index])
        items[index].isFavorite = false
    }
    
    // should use the async method.
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
    
    private func getNextPageFromCoreDataAsync() {
        DispatchQueue.global().async {
            self.coreDataManager.backgroundFetchListCategoryPage(listCategory: self.sortParameters.listCategoryType) { [weak self] entities in
                if let entities = entities {
                    self?.allItems = entities
                }
            }
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
