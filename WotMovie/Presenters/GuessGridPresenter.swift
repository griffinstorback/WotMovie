//
//  GuessGridPresenter.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-15.
//

import Foundation
import UIKit

protocol GuessGridPresenterProtocol: TransitionPresenterProtocol {
    var guessGridViewDelegate: GuessGridViewDelegate? { get set }
    var category: CategoryType { get }
    var itemsCount: Int { get }

    func setViewDelegate(_ guessGridViewDelegate: GuessGridViewDelegate?)
    func itemFor(index: Int) -> Entity
    func loadImageFor(index: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void) // this is used in multiple files - extractable?

    func loadItems()
}

class GuessGridPresenter: GuessGridPresenterProtocol {
    private let networkManager: NetworkManagerProtocol
    private let imageDownloadManager: ImageDownloadManagerProtocol
    private let coreDataManager: CoreDataManager
    weak var guessGridViewDelegate: GuessGridViewDelegate?
    
    let category: CategoryType
    private var nextPage = 1
    
    // the items currently being displayed
    private var items: [Entity] = [] {
        didSet {
            //let changedIndices = Array.differentIndices(items, oldValue)
            //print("**** CHANGED INDICES: \(changedIndices)")
            
            // for now, don't do any updates in this observer unless there are new elements to add/remove.
            guard items.count != oldValue.count else {
                print("*** didSet items.count is same as oldValue.count - not reloading.")
                return
            }
            
            DispatchQueue.main.async {
                self.guessGridViewDelegate?.reloadData()
            }
        }
    }
    // returns count of items to display. make sure to call items.count if you need count of actual number of items loaded.
    var itemsCount: Int {
        guard let numberOfItemsPerRow = guessGridViewDelegate?.numberOfItemsPerRow() else {
            print("** WARNING: in GuessGridPresenter, could not get # items per row (view delegate is likely nil).")
            return 0
        }
        
        guard numberOfItemsPerRow != 0 else {
            // don't do pruning if zero returned (it means collection view probably hasn't appeared yet, or has no frame)
            return 0
        }
        
        // prune (if necessary) last few items, to display a clean number of rows.
        return items.count - (items.count % numberOfItemsPerRow)
    }
    
    // filter out entities user has guessed on already, as well as undesirables (e.g. movie with no overview)
    private func addItems(_ items: [Entity]) {
        var newItems = items
        
        if let movies = newItems as? [Movie] {
            newItems = movies.filter { !$0.overview.isEmpty }
            print("Movie objects with nil overview: ", movies.filter { $0.overview.isEmpty })
        } else if let tvShows = newItems as? [TVShow] {
            newItems = tvShows.filter { !$0.overview.isEmpty }
            print("TV objects with nil posterPath: ", tvShows.filter { $0.overview.isEmpty })
        } else if let people = newItems as? [Person] {
            
            // TODO? : Filter out any Person object with undesirable attributes
            
            //newItems = people.filter { $0.posterPath != nil }
            //print("Person objects with nil posterPath: ", people.filter { $0.posterPath == nil })
        }
        
        // remove titles without a poster image
        newItems = newItems.filter { $0.posterPath != nil }
        
        // remove items guessed
        newItems = newItems.filter { !$0.correctlyGuessed }
        
        // remove items revealed (unless they were revealed awhile ago)
        newItems = newItems.filter { !$0.isRevealed }//&& $0.lastViewedDate ?? Date() > Date() }
        
        // prune last couple items off the end of items if number isn't divisable by row count
        // (we want full rows, no half/partially filled rows)
        // TODO
        
        self.items += newItems
    }
    
    init(networkManager: NetworkManagerProtocol = NetworkManager.shared,
            imageDownloadManager: ImageDownloadManagerProtocol = ImageDownloadManager.shared,
            coreDataManager: CoreDataManager = CoreDataManager.shared,
            category: CategoryType) {
        self.networkManager = networkManager
        self.imageDownloadManager = imageDownloadManager
        self.coreDataManager = coreDataManager
        self.category = category
    }
    
    func setViewDelegate(_ guessGridViewDelegate: GuessGridViewDelegate?) {
        self.guessGridViewDelegate = guessGridViewDelegate
    }
    
    // TransitionPresenterProtocol - called when dismissing modal detail (if item was revealed while modal was up)
    func setEntityAsRevealed(id: Int, isCorrect: Bool) {        
        if let index = items.firstIndex(where: { $0.id == id }) {
            if isCorrect { // if entity was correctly guessed
                if !items[index].correctlyGuessed {
                    items[index].correctlyGuessed = true
                    DispatchQueue.main.async {
                        self.guessGridViewDelegate?.revealCorrectlyGuessedEntities(at: [index])
                    }
                }
            } else { // if entity was revealed (user gave up)
                if !items[index].isRevealed {
                    items[index].isRevealed = true
                    DispatchQueue.main.async {
                        self.guessGridViewDelegate?.revealEntities(at: [index])
                    }
                }
            }
        }
    }
    
    func itemFor(index: Int) -> Entity {
        return items[index]
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

    func loadItems() {
        
        // first, try to load the current page from core data
        if getNextPageFromCoreData() {
            
            return
        }
        
        getNextPageFromNetworkThenCacheInCoreData()
    }
    
    // returns true if successful
    private func getNextPageFromCoreData() -> Bool {
        if let items = coreDataManager.fetchEntityPage(category: category, pageNumber: nextPage, genreID: -1) {
            
            // TODO: need to check if lastUpdated > 2 days (or whatever threshold), then update page
            // either right now or on a background thread.
            
            // if empty list was returned, means there is no page entity yet
            if items.count > 0 {
                print("** Retrieved grid (p. \(nextPage)) items (\(items.count) movies) from Core Data")
                self.addItems(items)
                self.nextPage += 1
                
                // recursive call if all those entities we just got had already been revealed.
                if self.items.count < 20 {
                    return getNextPageFromCoreData()
                } else {
                    return true
                }
            } else {
                print("** fetchEntityPage came back with empty list.")
            }
        } else {
            print("** fetchEntityPage came back nil. something went WRONG.")
        }
        
        return false
    }
    
    // returns true if successful
    private func getNextPageFromNetworkThenCacheInCoreData() {
        print("** Retrieving grid (p. \(nextPage)) items from network..")
        if category == .movie {
            networkManager.getListOfMoviesByGenre(id: -1, page: nextPage) { [weak self] movies, error in
                if let error = error {
                    print(error)
                    
                    // TODO: Error sometimes is just the page not loading for some reason. Got a 500 error once just for one page.
                    //       Should re-attempt the next page (just once)
                    //self?.nextPage += 1
                    
                    return
                }
                if let movies = movies {
                    //self?.addItems(movies)
                    
                    // update/create page in core data, then retrieve the newly posted page
                    if let currentPage = self?.nextPage {
                        DispatchQueue.main.async {
                            print("** calling createMoviePage with moviesCount: \(movies.count), page: \(currentPage), genre: -1")
                            self?.coreDataManager.createMoviePage(movies: movies, pageNumber: currentPage, genreID: -1)
                            let newlyAddedMovies = self?.coreDataManager.fetchEntityPage(category: .movie, pageNumber: currentPage, genreID: -1)
                            print("** newlyAddedMovies count: \(newlyAddedMovies?.count ?? -1)")
                            self?.addItems(newlyAddedMovies ?? [])
                        }
                    }
                    
                    self?.nextPage += 1
                }
            }
        } else if category == .tvShow {
            networkManager.getListOfTVShowsByGenre(id: -1, page: nextPage) { [weak self] tvShows, error in
                if let error = error {
                    print(error)
                    
                    // TODO: Error sometimes is just the page not loading for some reason. Got a 500 error once just for one page.
                    //       Should re-attempt the next page (just once)
                    //self?.nextPage += 1
                    
                    return
                }
                if let tvShows = tvShows {
                    self?.addItems(tvShows)
                    //self?.items += tvShows
                    self?.nextPage += 1
                }
            }
        } else if category == .person {
            networkManager.getPopularPeople(page: nextPage) { [weak self] people, error in
                if let error = error {
                    print(error)
                    
                    // TODO: Error sometimes is just the page not loading for some reason. Got a 500 error once just for one page.
                    //       Should re-attempt the next page (just once)
                    //self?.nextPage += 1
                    
                    return
                }
                if let people = people {
                    self?.addItems(people)
                    //self?.items += people
                    self?.nextPage += 1
                }
            }
        }
    }
}
