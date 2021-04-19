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
    
    func shouldNotLoadMoreItems() -> Bool
    func loadItems() -> Bool
    
    func addItemToWatchlistOrFavorites(_ indexPath: IndexPath)
    func removeItemFromWatchlistOrFavorites(_ indexPath: IndexPath)
}

class GuessGridPresenter: NSObject, GuessGridPresenterProtocol {
    private let networkManager: NetworkManagerProtocol
    private let imageDownloadManager: ImageDownloadManagerProtocol
    private let coreDataManager: CoreDataManager
    weak var guessGridViewDelegate: GuessGridViewDelegate?
    
    let category: CategoryType
    private var nextPage = 1
    
    private var currentlyDisplayingGenre: Genre {
        didSet {
            // reset items when genre changed
            nextPage = 1
            items.removeAll()
            loadNextPageOfItemsAsync()
        }
    }
    private var genresList: [Genre] = []
    private func setGenres(_ genres: [Genre]) {
        if category == .movie {
            // filter out movie categories that don't make sense to guess from
            let goodMovieCategories = genres.filter { !Constants.BadCategories.movies.contains($0.id) }
            genresList = goodMovieCategories
        } else if category == .tvShow {
            // filter out tv show categories that don't make sense to guess from (like "talk" shows, which are simply named after the host)
            let goodTVShowCategories = genres.filter { !Constants.BadCategories.tvShows.contains($0.id) }
            genresList = goodTVShowCategories
        }
    }
    
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
    
    // number of cells in grid that haven't been guessed yet
    var hiddenItemsCount: Int {
        // sums up the items which are not revealed or guessed (they're hidden)
        return items.reduce(0) { $0 + ((!$1.isRevealed && !$1.correctlyGuessed) ? 1 : 0 )}
    }
    
    // returns the max number of hidden items to show, in order to prevent users from endlessly scrolling for no reason.
    var maxNumberOfHiddenItemsToShow: Int {
        guard let numberOfItemsPerRow = guessGridViewDelegate?.numberOfItemsPerRow() else {
            print("** WARNING: in GuessGridPresenter, could not get # items per row (view delegate is likely nil).")
            return 0
        }
        
        let numberOfRowsToShow = 10
        
        return numberOfItemsPerRow * numberOfRowsToShow
    }
    
    // filter out entities user has guessed on already, as well as undesirables (e.g. movie with no overview)
    private func addItems(_ items: [Entity]) {
        // first of all, if any of the movies or tv shows have "BadDescriptions", filter them out.
        var newItems: [Entity] = []
        items.forEach { item in
            if item.type == .movie && !Constants.BadDescriptions.movies.contains(item.id) {
                newItems.append(item)
            } else if item.type == .tvShow && !Constants.BadDescriptions.tvShows.contains(item.id) {
                newItems.append(item)
            } else if item.type == .person {
                newItems.append(item)
            }
        }
        
        // the filter looks a bit convoluted, but simply evaluates to: if overview is empty or nil
        if let movies = newItems as? [Movie] {
            newItems = movies.filter { !($0.overview?.isEmpty ?? true) }
            print("Movie objects with nil overview: ", movies.filter { $0.overview?.isEmpty ?? true })
        } else if let tvShows = newItems as? [TVShow] {
            newItems = tvShows.filter { !($0.overview?.isEmpty ?? true) }
            print("TV objects with nil posterPath: ", tvShows.filter { $0.overview?.isEmpty ?? true })
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
        
        if totalDups > 0 {
            print("&&& ******* DUPS FOUND - GuessGridPresenter.addItems() - added \(newItems.count) new items, with \(dupCount) new dups. New total: \(self.items.count). Total dups: \(totalDups)")
        }
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
        
        // sorted alphabetically, but with all genres at top (otherwise 'action' would be above it)
        return [MovieGenre.allGenres] + genresList.sorted { $0.name < $1.name } as? [MovieGenre] ?? []
    }
    
    func getTVShowGenresAvailableToDisplay() -> [TVShowGenre] {
        if genresList.isEmpty {
            loadGenresList()
        }
        
        // sorted alphabetically, but with all genres at top (otherwise 'action' would be above it)
        return [TVShowGenre.allGenres] + genresList.sorted { $0.name < $1.name } as? [TVShowGenre] ?? []
    }
    
    func setGenreToDisplay(genreID: Int) {
        // if genre isn't in list, fallback to all genres (shouldn't happen ever)
        if category == .movie {
            currentlyDisplayingGenre = genresList.first { $0.id == genreID } ?? MovieGenre.allGenres
        } else if category == .tvShow {
            currentlyDisplayingGenre = genresList.first { $0.id == genreID } ?? TVShowGenre.allGenres
        }
    }
    
    func shouldNotLoadMoreItems() -> Bool {
        return hiddenItemsCount > maxNumberOfHiddenItemsToShow
    }
    
    // call when want to load another page of items.
    func loadItems() -> Bool {
        // before loading next page, if genres haven't been loaded yet, load them.
        if genresList.isEmpty {
            loadGenresList()
        }
        
        // if there are too many hidden items on the page, tell user to guess some before loading more.
        if shouldNotLoadMoreItems() {
            guessGridViewDelegate?.displayLoadMoreItemsAlert(text: "Guess/Reveal some items before loading more!")
            return false // return false to notify user item loading cancelled (so that LoadMoreGridViewController knows to scroll back up
        }
        
        loadNextPageOfItemsAsync()
        
        // TODO: At this point, a new page has been loaded, or started to load.
        //       So, we should check if there are over say 1000 items in the list, and
        //       prune the first page off if there is, in order to avoid memory problems.
        
        return true // return true to notify user that item loading was initiated
    }
    
    
    
    // MARK:- Private methods
    
    private func loadGenresList() {
        if !getGenreListFromCoreData() {
            getGenreListFromNetworkThenCacheInCoreData()
        }
    }

    
    private var isLoading = false // semaphore
    private func loadNextPageOfItemsAsync() { // call this method from main thread, it will make a background thread for itself after checking isLoading
        guard nextPage < 1000 else { return } // in case of bug, don't just keep trying to load new pages forever.
        
        if isLoading {
            print("*** GuessGridPresenter.loadNextPageOfItems() - ABORTING ATTEMPT TO QUERY PAGE \(nextPage) (isLoading is true)")
            return
        }
        isLoading = true
        
        DispatchQueue.global().async {
            self.getPageFromCoreDataAsync(page: self.nextPage) { success in
                if success {
                    self.nextPage += 1
                    self.isLoading = false
                    
                    print("*** GuessGridPresenter.loadNextPageOfItems() - got page \(self.nextPage-1) from core data")
                    if self.items.count < 20 {
                        print("*** GuessGridPresenter.loadNextPageOfItems() - items.count is only \(self.items.count), so loading another page (page \(self.nextPage))...")
                        
                        // dispatch the request on main queue, so that isLoading semaphore is thread safe
                        DispatchQueue.main.async {
                            self.loadNextPageOfItemsAsync()
                        }
                    } else {
                        print("*** GuessGridPresenter.loadNextPageOfItems() - items.count is \(self.items.count), so we're done.")
                    }
                } else {
                    // page from core data came back nil or empty - get it from the network.
                    self.getPageFromNetworkThenCacheInCoreData(page: self.nextPage) { success in
                        if success {
                            self.nextPage += 1
                            self.isLoading = false
                            
                            print("*** GuessGridPresenter.loadNextPageOfItems() - got page \(self.nextPage-1) from network")
                            if self.items.count < 20 {
                                print("*** GuessGridPresenter.loadNextPageOfItems() - items.count is only \(self.items.count), so loading another page (page \(self.nextPage))...")
                                
                                // dispatch the request on main queue, so that isLoading semaphore is thread safe
                                DispatchQueue.main.async {
                                    self.loadNextPageOfItemsAsync()
                                }
                            } else {
                                print("*** GuessGridPresenter.loadNextPageOfItems() - items.count is \(self.items.count), so we're done.")
                            }
                        } else {
                            // network request failed - still increment nextPage, in case there was trouble with just that one page.
                            print("** ERROR: trouble loading page \(self.nextPage) for type \(self.category) - incrementing to page \(self.nextPage + 1), but not retrying here.")
                            self.nextPage += 1
                            self.isLoading = false
                        }
                    }
                }
            }
        }
    }
    
    // loads as many pages as it can find from Core Data synchronously - then starts loading new pages from network asynchronously
    private func loadNextPageOfItemsSync() {
        // first, try to load the current page from core data
        if !getPageFromCoreData(page: nextPage) {
            getPageFromNetworkThenCacheInCoreData(page: nextPage) { success in
                if success {
                    self.nextPage += 1
                    self.isLoading = false
                    
                    print("*** GuessGridPresenter.loadNextPageOfItems() - got page \(self.nextPage-1) from network")
                    if self.items.count < 20 {
                        print("*** GuessGridPresenter.loadNextPageOfItems() - items.count is only \(self.items.count), so loading another page (page \(self.nextPage))...")
                        
                        // dispatch the request on main queue, so that isLoading semaphore is thread safe
                        DispatchQueue.main.async {
                            self.loadNextPageOfItemsSync()
                        }
                    } else {
                        print("*** GuessGridPresenter.loadNextPageOfItems() - items.count is \(self.items.count), so we're done.")
                    }
                } else {
                    // network request failed - still increment nextPage, in case there was trouble with just that one page.
                    print("** ERROR: trouble loading page \(self.nextPage) for type \(self.category) - incrementing to page \(self.nextPage + 1), but not retrying here.")
                    self.nextPage += 1
                    self.isLoading = false
                }
            }
        } else {
            nextPage += 1
            isLoading = false
            
            print("*** GuessGridPresenter.loadNextPageOfItems() - got page \(nextPage-1) from core data")
            if self.items.count < 20 {
                print("*** GuessGridPresenter.loadNextPageOfItems() - items.count is only \(self.items.count), so loading another page (page \(nextPage))...")
                loadNextPageOfItemsSync()
            } else {
                print("*** GuessGridPresenter.loadNextPageOfItems() - items.count is \(self.items.count), so we're done.")
            }
        }
        
        //isLoading = false
    }
    
    // DON'T USE - FETCH FROM BACKGROUND!
    private func getPageFromCoreData(page: Int) -> Bool {
        if let items = coreDataManager.fetchEntityPage(category: category, pageNumber: page, genreID: currentlyDisplayingGenre.id) {
            if items.count != 0 {
                self.addItems(items)
                return true
            }
        }
        
        return false
    }
    
    private func getPageFromCoreDataAsync(page: Int, completion: @escaping (_ success: Bool) -> Void) {
        coreDataManager.backgroundFetchEntityPage(category: category, page: page, genreID: currentlyDisplayingGenre.id) { [weak self] items in
            
            // simulate delay
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                if let items = items, items.count > 0 {
                    self?.addItems(items)
                    completion(true)
                    return
                } else {
                    completion(false)
                    return
                }
            }
        }
    }
    
    // returns true if successful
    private func getPageFromNetworkThenCacheInCoreData(page: Int, completion: @escaping (_ success: Bool) -> Void) {
        print("** Retrieving grid of type \(category) (p. \(page)) items from network..")
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

        } else if category == .tvShow {
            networkManager.getListOfTVShowsByGenre(id: currentlyDisplayingGenre.id, page: page) { [weak self] tvShows, error in
                if let error = error {
                    print(error)
                    completion(false)
                    return
                }
                if let tvShows = tvShows {
                    
                    // update/create page in core data, then retrieve the newly posted page
                    if let strongSelf = self {
                        DispatchQueue.main.async {
                            
                            let newlyAddedTVShows = strongSelf.coreDataManager.updateOrCreateTVShowPage(tvShows: tvShows, pageNumber: page, genreID: strongSelf.currentlyDisplayingGenre.id)
                            strongSelf.addItems(newlyAddedTVShows ?? [])
                            completion(true)
                            return
                        }
                    }
                    
                    completion(false)
                    return
                }
            }
            
        } else if category == .person {
            networkManager.getPopularPeople(page: page) { [weak self] people, error in
                if let error = error {
                    print(error)
                    completion(false)
                    return
                }
                if let people = people {
                    
                    // update/create page in core data, then retrieve the newly posted page
                    if let strongSelf = self {
                        DispatchQueue.main.async {
                            
                            let newlyAddedPeople = strongSelf.coreDataManager.updateOrCreatePersonPage(people: people, pageNumber: page)
                            strongSelf.addItems(newlyAddedPeople ?? [])
                            completion(true)
                            return
                        }
                    }
                    
                    completion(false)
                    return
                }
            }
        }
    }
    
    // returns true if got results from core data.
    private func getGenreListFromCoreData() -> Bool {
        if category == .movie {
            setGenres(coreDataManager.fetchMovieGenres())
            return !genresList.isEmpty
        } else if category == .tvShow {
            setGenres(coreDataManager.fetchTVShowGenres())
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
                    self?.setGenres(genres)
                    
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
                    self?.setGenres(genres)
                    
                    // cache result in core data
                    DispatchQueue.main.async {
                        self?.coreDataManager.updateOrCreateTVShowGenreList(genres: genres)
                    }
                }
            }
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
}

// TransitionPresenterProtocol - called when dismissing modal detail (if item was revealed/added to watchlist while modal was up)
extension GuessGridPresenter {
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
        
        // get index of question just guessed
        if let index = items.firstIndex(where: { $0.id == currentQuestionID }) {
            
            // iterate through items until we find one that hasn't been guessed/revealed.
            for i in index+1..<items.count {
                if !items[i].correctlyGuessed && !items[i].isRevealed {
                    
                    // found the next item which hasn't been opened.
                    guessGridViewDelegate?.presentGuessDetailFor(index: i)
                    return
                }
            }
        }
    }
}
