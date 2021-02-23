//
//  EnterGuessPresenter.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-29.
//

import Foundation
import UIKit

protocol EnterGuessPresenterProtocol {
    var searchResultsCount: Int { get }
    func setViewDelegate(_ delegat: EnterGuessViewDelegate)
    func loadImage(for index: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void)
    func searchResult(for index: Int) -> Entity
    func search(searchText: String)
    func isCorrect(index: Int) -> Bool
    func itemHasBeenGuessed(id: Int) -> Bool
    func getPlaceholderText() -> String
    func addItemToWatchlist() -> Bool
    func getWatchlistButtonText() -> String
    func getWatchlistImageName() -> String
}

class EnterGuessPresenter: EnterGuessPresenterProtocol {
    private let networkManager: NetworkManagerProtocol
    private let imageDownloadManager: ImageDownloadManagerProtocol
    private let coreDataManager: CoreDataManager
    weak private var enterGuessViewDelegate: EnterGuessViewDelegate?
    
    private var item: Entity
    private var searchResults: [Entity] = [] {
        didSet {
            DispatchQueue.main.async {
                self.enterGuessViewDelegate?.reloadResults()
            }
        }
    }    
    var searchResultsCount: Int {
        return searchResults.count
    }
    
    // holds the attempts made by user, by id
    private var guesses: [Int] = [] {
        didSet {
            DispatchQueue.main.async {
                self.enterGuessViewDelegate?.reloadResults()
            }
        }
    }
    
    init(networkManager: NetworkManager = NetworkManager.shared,
            imageDownloadManager: ImageDownloadManager = ImageDownloadManager.shared,
            coreDataManager: CoreDataManager = CoreDataManager.shared,
            item: Entity) {
        self.item = item
        self.networkManager = networkManager
        self.imageDownloadManager = imageDownloadManager
        self.coreDataManager = coreDataManager
    }
    
    func setViewDelegate(_ delegate: EnterGuessViewDelegate) {
        self.enterGuessViewDelegate = delegate
    }
    
    func loadImage(for index: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void) {
        let item = searchResult(for: index)
        
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
    
    func searchResult(for index: Int) -> Entity {
        return searchResults[index]
    }
    
    func search(searchText: String) {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        switch item.type {
        case .movie:
            networkManager.searchMovies(searchText: searchText) { [weak self] movies, error in
                if let error = error {
                    print(error)
                    return
                }
                
                if let movies = movies {
                    self?.searchResults = movies//.reversed()
                }
            }
        case .tvShow:
            networkManager.searchTVShows(searchText: searchText) { [weak self] tvShows, error in
                if let error = error {
                    print(error)
                    return
                }
                
                if let tvShows = tvShows {
                    self?.searchResults = tvShows//.reversed()
                }
            }
        case .person:
            networkManager.searchPeople(searchText: searchText) { [weak self] people, error in
                if let error = error {
                    print(error)
                    return
                }
                
                if let people = people {
                    self?.searchResults = people//.reversed()
                }
            }
        }
    }
    
    func isCorrect(index: Int) -> Bool {
        guard index < searchResults.count else { return false }
        let selectedItem = searchResults[index]
        let isCorrect = item.id == selectedItem.id
        
        if isCorrect {
            item.isRevealed = true
            item.correctlyGuessed = true
            coreDataManager.updateOrCreateEntity(entity: item)
        } else {
            guesses.append(selectedItem.id)
        }
        
        return isCorrect
    }
    
    func itemHasBeenGuessed(id: Int) -> Bool {
        return guesses.contains(id)
    }
    
    func getPlaceholderText() -> String {
        switch item.type {
        case .movie:
            return "Enter movie name"
        case .tvShow:
            return "Enter TV show name"
        case .person:
            return "Enter name of person"
        }
    }
    
    // returns true if item was added, false if item was removed from watchlist.
    func addItemToWatchlist() -> Bool {
        if item.isFavorite {
            coreDataManager.removeEntityFromWatchlistOrFavorites(entity: item)
            item.isFavorite = false
        } else {
            coreDataManager.addEntityToWatchlistOrFavorites(entity: item)
            item.isFavorite = true
        }
        
        enterGuessViewDelegate?.reloadResults()
        return item.isFavorite
    }
    
    func getWatchlistButtonText() -> String {
        switch item.type {
        case .movie, .tvShow:
            if item.isFavorite {
                return "Remove from Watchlist"
            } else {
                return "Add to Watchlist"
            }
        case .person:
            if item.isFavorite {
                return "Remove from Favorites"
            } else {
                return "Add to Favorites"
            }
        }
    }
    
    func getWatchlistImageName() -> String {
        switch item.type {
        case .movie, .tvShow:
            if item.isFavorite {
                return "remove_from_watchlist_icon"
            } else {
                return "add_to_watchlist_icon"
            }
        case .person:
            if item.isFavorite {
                return "remove_from_favorites_icon"
            } else {
                return "add_to_favorites_icon"
            }
        }
    }
}
