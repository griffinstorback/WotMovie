//
//  SearchPresenter.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-04-07.
//

import Foundation
import UIKit
import Combine

protocol SearchPresenterProtocol {
    //var sortParameters: SortParameters { get set }
    var searchResultsCount: Int { get }
    
    var stringToShowWhenNoResultsShown: String { get }
    //func loadItems()
    
    func setViewDelegate(_ searchViewDelegate: SearchViewDelegate?)
    func searchResultFor(index: Int) -> Entity?
    func setSearchText(_ searchText: String?)
    
    func loadImageFor(index: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void)
    func cancelLoadImageRequestFor(_ indexPath: IndexPath)
    
    func getTypesCurrentlyDisplaying() -> CategoryDisplayTypes
    func getTypesAvailableToDisplay() -> [(String,CategoryDisplayTypes)]
    func setTypesToDisplay(categoryDisplayTypes: CategoryDisplayTypes)
    func getSortParameters() -> SortParameters
    func setSortParameters(_ sortParameters: SortParameters)
}

class SearchPresenter: SearchPresenterProtocol {
    private let networkManager: NetworkManagerProtocol
    private let imageDownloadManager: ImageDownloadManagerProtocol
    private let coreDataManager: CoreDataManager
    weak var searchViewDelegate: SearchViewDelegate?
    
    private var sortParameters: SortParameters {
        didSet {
            // no use performing search if nothing to search
            if !searchString.isEmpty {
                performSearch()
            }
        }
    }
    
    private var typesDisplayed: CategoryDisplayTypes {
        didSet {
            // no use performing search if nothing to search
            if !searchString.isEmpty {
                performSearch()
            }
        }
    }
    
    // subscribe to search string in init()
    @Published private var searchString: String = ""
    var cancellables = Set<AnyCancellable>()

    private var searchResults: [Entity] = [] {
        didSet {
            DispatchQueue.main.async {
                self.searchViewDelegate?.reloadData()
            }
        }
    }
    var searchResultsCount: Int {
        return searchResults.count
    }
    
    // the string message to show when no results are shown - either because nothing was searched, or because no results were returned.
    var stringToShowWhenNoResultsShown: String {
        // there shouldn't be a message if there are results shown.
        guard searchResults.isEmpty else { return "" }
        
        if searchString.isEmpty {
            switch typesDisplayed {
            case .all, .moviesAndTVShows: // should never be movies & tv shows here, so if it is (for some bugged reason), just treat as '.all'
                return "Search Movies, TV Shows, and People"
            case .movies:
                return "Search Movies"
            case .tvShows:
                return "Search TV Shows"
            case .people:
                return "Search People"
            }
        } else {
            return "No results"
        }
    }
    
    init(networkManager: NetworkManager = NetworkManager.shared,
            imageDownloadManager: ImageDownloadManager = ImageDownloadManager.shared,
            coreDataManager: CoreDataManager = CoreDataManager.shared) {
        self.networkManager = networkManager
        self.imageDownloadManager = imageDownloadManager
        self.coreDataManager = coreDataManager
        
        typesDisplayed = .all
        
        // TODO: do something about sort paramters - see what's avaible for searching, what's feasible, what's worth it to implement, whether or not to just scrap it.
        // Its not being used here currently.
        sortParameters = SortParameters(categoryType: .allGuessed)
        
        // Use a bit of combine, to easily get that debounce functionality, to prune redundant searches.
        $searchString
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .print()
            .sink { [weak self] _ in
                self?.performSearch()
            }.store(in: &cancellables)
    }
    
    func setViewDelegate(_ searchViewDelegate: SearchViewDelegate?) {
        self.searchViewDelegate = searchViewDelegate
    }
    
    func searchResultFor(index: Int) -> Entity? {
        guard index < searchResults.count else { return nil }
        
        return searchResults[index]
    }
    
    func setSearchText(_ searchText: String?) {
        guard let searchText = searchText, !searchText.isEmpty, !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            searchString = ""
            searchResults = []
            return
        }
        
        searchViewDelegate?.searchStartedLoading()
        
        searchString = searchText
    }
    
    private func performSearch() {
        guard !searchString.isEmpty else {
            searchResults = []
            return
        }
        
        switch typesDisplayed {
        case .all, .moviesAndTVShows: // should never be movies & tv shows here, so if it is (for some bugged reason), just treat as '.all'
            networkManager.searchAll(searchText: searchString) { [weak self] entities, error in
                if let error = error {
                    print(error)
                    return
                }
                
                if let entities = entities {
                    self?.searchResults = entities
                }
            }
        case .movies:
            networkManager.searchMovies(searchText: searchString) { [weak self] movies, error in
                if let error = error {
                    print(error)
                    return
                }
                
                if let movies = movies {
                    self?.searchResults = movies
                }
            }
        case .tvShows:
            networkManager.searchTVShows(searchText: searchString) { [weak self] tvShows, error in
                if let error = error {
                    print(error)
                    return
                }
                
                if let tvShows = tvShows {
                    self?.searchResults = tvShows
                }
            }
        case .people:
            networkManager.searchPeople(searchText: searchString) { [weak self] people, error in
                if let error = error {
                    print(error)
                    return
                }
                
                if let people = people {
                    self?.searchResults = people
                }
            }
        }
    }
    
    func loadImageFor(index: Int, completion: @escaping (UIImage?, String?) -> Void) {
        guard let item = searchResultFor(index: index) else { return }
        
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
        }
    }
    
    func cancelLoadImageRequestFor(_ indexPath: IndexPath) {
        let index = indexPath.row
        guard let item = searchResultFor(index: index) else { return }
        
        if let posterPath = item.posterPath {
            imageDownloadManager.cancelImageDownload(path: posterPath)
        }
    }
    
    func getTypesCurrentlyDisplaying() -> CategoryDisplayTypes {
        return typesDisplayed
    }
    
    func getTypesAvailableToDisplay() -> [(String, CategoryDisplayTypes)] {
        return [
            (CategoryDisplayTypes.all.rawValue, .all),
            (CategoryDisplayTypes.movies.rawValue, .movies),
            (CategoryDisplayTypes.tvShows.rawValue, .tvShows),
            (CategoryDisplayTypes.people.rawValue, .people)
        ]
    }
    
    func setTypesToDisplay(categoryDisplayTypes: CategoryDisplayTypes) {
        self.typesDisplayed = categoryDisplayTypes
    }
    
    func getSortParameters() -> SortParameters {
        return sortParameters
    }
    
    func setSortParameters(_ sortParameters: SortParameters) {
        self.sortParameters = sortParameters
    }
}
