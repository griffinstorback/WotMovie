//
//  SearchPresenter.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-04-07.
//

import Foundation
import UIKit

protocol SearchPresenterProtocol {
    //var sortParameters: SortParameters { get set }
    var searchResultsCount: Int { get }
    
    //func loadItems()
    
    func setViewDelegate(_ searchViewDelegate: SearchViewDelegate?)
    func searchResultFor(index: Int) -> Entity?
    func setSearchText(_ searchText: String?)
    func loadImageFor(index: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void)
    
    //func getTypesCurrentlyDisplaying() -> ListCategoryDisplayTypes
    //func getTypesAvailableToDisplay() -> [(String,ListCategoryDisplayTypes)]
    //func setTypesToDisplay(listCategoryDisplayTypes: ListCategoryDisplayTypes)
    //func getSortParameters() -> SortParameters
    //func setSortParameters(_ sortParameters: SortParameters)
}

class SearchPresenter: SearchPresenterProtocol {
    private let networkManager: NetworkManagerProtocol
    private let imageDownloadManager: ImageDownloadManagerProtocol
    private let coreDataManager: CoreDataManager
    weak var searchViewDelegate: SearchViewDelegate?
    
    private func setSearchResults(_ entities: [Entity]) {
        searchResults = entities
    }
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
    
    init(networkManager: NetworkManager = NetworkManager.shared,
            imageDownloadManager: ImageDownloadManager = ImageDownloadManager.shared,
            coreDataManager: CoreDataManager = CoreDataManager.shared) {
        self.networkManager = networkManager
        self.imageDownloadManager = imageDownloadManager
        self.coreDataManager = coreDataManager
    }
    
    /*func loadItems() {
        print("***** LOAD ITEMS (THIS PROBABLY SHOULDN'T EVEN BE HERE)")
    }*/
    
    func setViewDelegate(_ searchViewDelegate: SearchViewDelegate?) {
        self.searchViewDelegate = searchViewDelegate
    }
    
    func searchResultFor(index: Int) -> Entity? {
        guard index < searchResults.count else { return nil }
        
        return searchResults[index]
    }
    
    func setSearchText(_ searchText: String?) {
        guard let searchText = searchText, !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        // MAKE THIS SEARCH ALL
        networkManager.searchMovies(searchText: searchText) { [weak self] movies, error in
            if let error = error {
                print(error)
                return
            }
            
            if let movies = movies {
                self?.setSearchResults(movies)
            }
        }
        
        /*switch item.type {
        case .movie:
            networkManager.searchMovies(searchText: searchText) { [weak self] movies, error in
                if let error = error {
                    print(error)
                    return
                }
                
                if let movies = movies {
                    self?.setSearchResults(movies)
                }
            }
        case .tvShow:
            networkManager.searchTVShows(searchText: searchText) { [weak self] tvShows, error in
                if let error = error {
                    print(error)
                    return
                }
                
                if let tvShows = tvShows {
                    self?.setSearchResults(tvShows)
                }
            }
        case .person:
            networkManager.searchPeople(searchText: searchText) { [weak self] people, error in
                if let error = error {
                    print(error)
                    return
                }
                
                if let people = people {
                    self?.setSearchResults(people)
                }
            }
        }*/
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
}
