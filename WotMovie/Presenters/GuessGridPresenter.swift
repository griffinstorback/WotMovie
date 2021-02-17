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
    func itemFor(index: Int) -> Entity?
    func loadImageFor(index: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void) // this is used in multiple files - extractable?

    func getGenreCurrentlyDisplaying() -> Genre
    func getMovieGenresAvailableToDisplay() -> [MovieGenre]
    func getTVShowGenresAvailableToDisplay() -> [TVShowGenre]
    func setGenreToDisplay(genreID: Int)
    
    func loadItems()
}

class GuessGridPresenter: GuessGridPresenterProtocol {
    private let networkManager: NetworkManagerProtocol
    private let imageDownloadManager: ImageDownloadManagerProtocol
    private let coreDataManager: CoreDataManager
    weak var guessGridViewDelegate: GuessGridViewDelegate?
    
    let category: CategoryType
    private var nextPage = 1
    
    private var currentlyDisplayingGenre: Genre {
        didSet {
            //
            nextPage = 1
            items.removeAll()
            loadNextPageOfItems()
        }
    }
    private var genresList: [Genre] = []
    
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
        
        // remove items revealed (unless they were revealed awhile ago, ~2 months?)
        newItems = newItems.filter { !$0.isRevealed }//&& $0.lastViewedDate ?? Date() > Date() }
        
        var dupCount = 0
        for newItem in newItems {
            for item in self.items {
                if item.id == newItem.id {
                    dupCount += 1
                }
            }
        }
        
        var totalDups = 0
        for item in self.items {
            for item2 in self.items {
                if item.id == item2.id {
                    totalDups += 1
                }
            }
            totalDups -= 1
        }
        
        self.items += newItems
        
        print("*** GuessGridPresenter.addItems() - added \(newItems.count) new items, with \(dupCount) new dups. New total: \(self.items.count). Total dups: \(totalDups)")
    }
    
    init(networkManager: NetworkManagerProtocol = NetworkManager.shared,
            imageDownloadManager: ImageDownloadManagerProtocol = ImageDownloadManager.shared,
            coreDataManager: CoreDataManager = CoreDataManager.shared,
            category: CategoryType) {
        self.networkManager = networkManager
        self.imageDownloadManager = imageDownloadManager
        self.coreDataManager = coreDataManager
        self.category = category
        
        // Set "All genres" as default.
        if category == .tvShow {
            currentlyDisplayingGenre = TVShowGenre(id: -1, name: "All genres")
        } else {
            currentlyDisplayingGenre = MovieGenre(id: -1, name: "All genres")
        }
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
    
    func itemFor(index: Int) -> Entity? {
        // this check important - index can be out of bounds sometimes when changing genre.
        return index < items.count ? items[index] : nil
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
    
    func getGenreCurrentlyDisplaying() -> Genre {
        return currentlyDisplayingGenre
    }
    
    func getMovieGenresAvailableToDisplay() -> [MovieGenre] {
        if genresList.isEmpty {
            loadGenresList()
        }
        
        return genresList.sorted { $0.name < $1.name } as? [MovieGenre] ?? []
    }
    
    func getTVShowGenresAvailableToDisplay() -> [TVShowGenre] {
        return []
    }
    
    func setGenreToDisplay(genreID: Int) {
        if category == .movie {
            currentlyDisplayingGenre = genresList.first { $0.id == genreID } ?? MovieGenre(id: -1, name: "All genres")
        } else if category == .tvShow {
            
        }
    }
    
    // call when want to load another page of items.
    func loadItems() {
        // before loading next page, if genres haven't been loaded yet, load them.
        if genresList.isEmpty {
            loadGenresList()
        }
        
        loadNextPageOfItems()
    }
    
    
    
    // MARK:- Private methods
    
    private func loadGenresList() {
        if !getGenreListFromCoreData() {
            getGenreListFromNetworkThenCacheInCoreData()
        }
    }

    
    private var isLoading = false // semaphore
    private func loadNextPageOfItems() {
        guard nextPage < 1000 else { return } // in case of bug, don't just keep trying to load new pages forever.
        
        if isLoading {
            print("*** GuessGridPresenter.loadNextPageOfItems() - ABORTING ATTEMPT TO QUERY PAGE \(nextPage) (isLoading is true)")
            return
        }
        isLoading = true
        
        // first, try to load the current page from core data
        if !getPageFromCoreData(page: nextPage) {
            getPageFromNetworkThenCacheInCoreData(page: nextPage) { success in
                if success {
                    self.nextPage += 1
                    self.isLoading = false
                    
                    print("*** GuessGridPresenter.loadNextPageOfItems() - got page \(self.nextPage-1) from network")
                    if self.items.count < 20 {
                        print("*** GuessGridPresenter.loadNextPageOfItems() - items.count is only \(self.items.count), so loading another page (page \(self.nextPage))...")
                        self.loadNextPageOfItems()
                    } else {
                        print("*** GuessGridPresenter.loadNextPageOfItems() - items.count is \(self.items.count), so we're done.")
                    }
                }
                
                self.isLoading = false
            }
        } else {
            nextPage += 1
            isLoading = false
            
            print("*** GuessGridPresenter.loadNextPageOfItems() - got page \(nextPage-1) from core data")
            if self.items.count < 20 {
                print("*** GuessGridPresenter.loadNextPageOfItems() - items.count is only \(self.items.count), so loading another page (page \(nextPage))...")
                loadNextPageOfItems()
            } else {
                print("*** GuessGridPresenter.loadNextPageOfItems() - items.count is \(self.items.count), so we're done.")
            }
        }
        
        //isLoading = false
    }
    
    // returns true if successful
    private func getPageFromCoreData(page: Int) -> Bool {
        if let items = coreDataManager.fetchEntityPage(category: category, pageNumber: page, genreID: currentlyDisplayingGenre.id) {
            if items.count != 0 {
                self.addItems(items)
                return true
            }
        }
        
        return false
    }
    
    // returns true if successful
    private func getPageFromNetworkThenCacheInCoreData(page: Int, completion: @escaping (_ success: Bool) -> Void) {
        print("** Retrieving grid (p. \(page)) items from network..")
        if category == .movie {
            networkManager.getListOfMoviesByGenre(id: currentlyDisplayingGenre.id, page: page) { [weak self] movies, error in
                if let error = error {
                    print(error)
                    completion(false)
                    return
                }
                if let movies = movies {
                    
                    // update/create page in core data, then retrieve the newly posted page
                    if let strongSelf = self {
                        DispatchQueue.main.async {
                            
                            let newlyAddedMovies = strongSelf.coreDataManager.updateOrCreateMoviePage(movies: movies, pageNumber: page, genreID: strongSelf.currentlyDisplayingGenre.id)
                            strongSelf.addItems(newlyAddedMovies ?? [])
                            completion(true)
                            return
                        }
                    }
                    
                    completion(false)
                    return
                }
            }
            
            
            
            
        // TODO: UPDATE TV SHOW AND PERSON REQUEST METHODS TO BE LIKE MOVIE.


        } else if category == .tvShow {
            networkManager.getListOfTVShowsByGenre(id: currentlyDisplayingGenre.id, page: page) { [weak self] tvShows, error in
                if let error = error {
                    print(error)
                    
                    // TODO: Error sometimes is just the page not loading for some reason. Got a 500 error once just for one page.
                    //       Should re-attempt the next page (just once)
                    //self?.nextPage += 1
                    
                    return
                }
                if let tvShows = tvShows {
                    //self?.nextPage += 1
                    self?.addItems(tvShows)
                    //self?.items += tvShows
                }
            }
        } else if category == .person {
            networkManager.getPopularPeople(page: page) { [weak self] people, error in
                if let error = error {
                    print(error)
                    
                    // TODO: Error sometimes is just the page not loading for some reason. Got a 500 error once just for one page.
                    //       Should re-attempt the next page (just once)
                    //self?.nextPage += 1
                    
                    return
                }
                if let people = people {
                    //self?.nextPage += 1
                    self?.addItems(people)
                    //self?.items += people
                }
            }
        }
        
        //nextPage += 1
    }
    
    // returns true if got results from core data.
    private func getGenreListFromCoreData() -> Bool {
        if category == .movie {
            genresList = coreDataManager.fetchMovieGenres()
            return !genresList.isEmpty
        } else if category == .tvShow {
            //genresList = coreDataManager.fetchTVShowGenres()
            return !genresList.isEmpty
        }
        
        return false
    }
    
    private func getGenreListFromNetworkThenCacheInCoreData() {
        if category == .movie {
            networkManager.getMovieGenres { [weak self] genres, error in
                if let error = error {
                    print(error)
                    return
                }
                if let genres = genres {
                    self?.genresList = genres
                    
                    // cache result in core data
                    DispatchQueue.main.async {
                        self?.coreDataManager.updateOrCreateMovieGenreList(genres: genres)
                    }
                }
            }
        } else if category == .tvShow {
            networkManager.getTVShowGenres { [weak self] genres, error in
                if let error = error {
                    print(error)
                    return
                }
                if let genres = genres {
                    self?.genresList = genres
                    
                    // cache result in core data
                    //DispatchQueue.main.async {
                    //    self?.coreDataManager.updateOrCreateTVShowGenreList(genres: genres)
                    //}
                }
            }
        }
    }
}
