//
//  CoreDataManager.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-11-02.
//

import Foundation
import CoreData
import UIKit

protocol CoreDataManagerProtocol {
    func getNumberGuessedFor(category: CategoryType) -> Int
}

final class CoreDataManager: CoreDataManagerProtocol {
    
    static let shared = CoreDataManager()
    private let coreDataStack = CoreDataStack.shared
    private init() {}


// MARK: -- GENERIC METHODS

    func getTotalNumberGuessed() -> Int {
        return fetchMovieGuessedCount() + fetchPersonGuessedCount() + fetchTVShowGuessedCount()
    }
    
    func getNumberGuessedFor(category: CategoryType) -> Int {
        switch category {
        case .movie:
            return fetchMovieGuessedCount()
        case .person:
            return fetchPersonGuessedCount()
        case .tvShow:
            return fetchTVShowGuessedCount()
        default:
            // if category type was "stats", nothing to return.
            return -1
        }
    }
    
    func getTotalNumberRevealed() -> Int {
        return fetchMovieRevealedCount() + fetchPersonRevealedCount() + fetchTVShowRevealedCount()
    }
    
    func getNumberRevealedFor(category: CategoryType) -> Int {
        switch category {
        case .movie:
            return fetchMovieRevealedCount()
        case .person:
            return fetchPersonRevealedCount()
        case .tvShow:
            return fetchTVShowRevealedCount()
        default:
            // if category type was "stats", nothing to return.
            return -1
        }
    }
    
    // for List page (i.e. "watchlist", "favorites", "guessed"
    func getCountForListCategory(listCategory: ListCategoryType) -> Int {
        switch listCategory {
        case .allGuessed:
            return getTotalNumberGuessed()
        case .allRevealed:
            return getTotalNumberRevealed()
        case .movieOrTvShowWatchlist:
            return fetchWatchlistCount()
        case .personFavorites:
            return fetchFavoritesCount()
        }
    }
    
    // Either: Creates this movie/tv show/person, or
    // Updates the existing info from api, as well as meta info regarding if its been guessed correctly, revealed, hint shown, etc.
    func updateOrCreateEntity(entity: Entity) {
        switch entity.type {
        case .movie:
            if let movie = entity as? Movie {
                updateOrCreateMovie(movie: movie)
            }
        case .tvShow:
            if let tvShow = entity as? TVShow {
                updateOrCreateTVShow(tvShow: tvShow)
            }
        case .person:
            if let person = entity as? Person {
                updateOrCreatePerson(person: person)
            }
        }
    }
    
    // returns empty list if page doesnt exist. returns nil if there was an error
    func fetchEntityPage(category: CategoryType, pageNumber: Int, genreID: Int) -> [Entity]? {
        switch category {
        case .movie:
            return fetchMoviePage(pageNumber, genreID)
        case .person:
            return fetchPersonPage(pageNumber, genreID)
        case .tvShow:
            return fetchTVShowPage(pageNumber, genreID)
        default:
            // if category type was "stats", nothing to return.
            return nil
        }
    }

    func addEntityToWatchlistOrFavorites(entity: Entity) {
        switch entity.type {
        case .movie:
            if let movie = entity as? Movie {
                addMovieToWatchlist(movie: movie)
            }
        case .tvShow:
            if let tvShow = entity as? TVShow {
                addTVShowToWatchlist(tvShow: tvShow)
            }
        case .person:
            if let person = entity as? Person {
                addPersonToFavorites(person: person)
            }
        }
    }
    
    func removeEntityFromWatchlistOrFavorites(entity: Entity) {
        switch entity.type {
        case .movie:
            if let movie = entity as? Movie {
                removeMovieFromWatchlist(movie: movie)
            }
        case .tvShow:
            if let tvShow = entity as? TVShow {
                removeTVShowFromWatchlist(tvShow: tvShow)
            }
        case .person:
            if let person = entity as? Person {
                removePersonFromFavorites(person: person)
            }
        }
    }
    
    func fetchGuessedEntities() -> [Entity] {
        return fetchGuessedMovies() + fetchGuessedTVShows() + fetchGuessedPeople()
    }
    
    func fetchRevealedEntities() -> [Entity] {
        return fetchRevealedMovies() + fetchRevealedTVShows() + fetchRevealedPeople()
    }
    
    
    
    
    
// MARK: -- COUNT QUERIES
    
    func fetchWatchlistCount() -> Int {
        return fetchMovieWatchlistCount() + fetchTVShowWatchlistCount()
    }
    
    func fetchMovieWatchlistCount() -> Int {
        let context = coreDataStack.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<MovieWatchlistMO>(entityName: "MovieWatchlist")
        
        do {
            let movieWatchlistResultsCount = try context.count(for: fetchRequest)
            return movieWatchlistResultsCount
        } catch {
            print("** Failed to fetch (movie) watchlist count: \(error)")
            return 0
        }
    }
    
    func fetchTVShowWatchlistCount() -> Int {
        let context = coreDataStack.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<TVShowWatchlistMO>(entityName: "TVShowWatchlist")
        
        do {
            let tvShowWatchlistResultsCount = try context.count(for: fetchRequest)
            return tvShowWatchlistResultsCount
        } catch {
            print("** Failed to fetch (tv show) watchlist count: \(error)")
            return 0
        }
    }
    
    func fetchFavoritesCount() -> Int {
        let context = coreDataStack.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<PersonFavoritesMO>(entityName: "PersonFavorites")
        
        do {
            let favoritesResultsCount = try context.count(for: fetchRequest)
            return favoritesResultsCount
        } catch {
            print("** Failed to fetch favorites count: \(error)")
            return 0
        }
    }
    
    func fetchMovieGuessedCount() -> Int {
        let context = coreDataStack.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<MovieGuessedMO>(entityName: "MovieGuessed")
        
        do {
            let movieGuessedCount = try context.count(for: fetchRequest)
            return movieGuessedCount
        } catch {
            print("** Failed to fetch movie guessed count: \(error)")
            return 0
        }
    }
    
    func fetchTVShowGuessedCount() -> Int {
        let context = coreDataStack.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<TVShowGuessedMO>(entityName: "TVShowGuessed")
        
        do {
            let tvShowGuessedCount = try context.count(for: fetchRequest)
            return tvShowGuessedCount
        } catch {
            print("** Failed to fetch tv show guessed count: \(error)")
            return 0
        }
    }
    
    func fetchPersonGuessedCount() -> Int {
        let context = coreDataStack.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<PersonGuessedMO>(entityName: "PersonGuessed")
        
        do {
            let peopleGuessedCount = try context.count(for: fetchRequest)
            return peopleGuessedCount
        } catch {
            print("** Failed to fetch person guessed count: \(error)")
            return 0
        }
    }
    
    func fetchMovieRevealedCount() -> Int {
        let context = coreDataStack.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<MovieRevealedMO>(entityName: "MovieRevealed")
        
        do {
            let movieRevealedCount = try context.count(for: fetchRequest)
            return movieRevealedCount
        } catch {
            print("** Failed to fetch movie revealed count: \(error)")
            return 0
        }
    }
    
    func fetchTVShowRevealedCount() -> Int {
        let context = coreDataStack.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<TVShowRevealedMO>(entityName: "TVShowRevealed")
        
        do {
            let tvShowRevealedCount = try context.count(for: fetchRequest)
            return tvShowRevealedCount
        } catch {
            print("** Failed to fetch tv show revealed count: \(error)")
            return 0
        }
    }
    
    func fetchPersonRevealedCount() -> Int {
        let context = coreDataStack.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<PersonRevealedMO>(entityName: "PersonRevealed")
        
        do {
            let personRevealedCount = try context.count(for: fetchRequest)
            return personRevealedCount
        } catch {
            print("** Failed to fetch person revealed count: \(error)")
            return 0
        }
    }
    
    

    
    
// MARK: -- MOVIES
    
    func updateOrCreateMovie(movie: Movie) {
        let existingMovieEntries = fetchMovie(id: movie.id)
        
        if existingMovieEntries.count > 0 {
            print("** Found \(existingMovieEntries.count) existing entries for movie \(movie.id)")
            
            let movieMO = existingMovieEntries[0]
            
            // update all values except 'id,' 'dateAdded,' and 'guessed'
            // (in case movie overview in api has changed since last stored).
            movieMO.lastUpdated = Date()
            movieMO.lastViewedDate = Date()
            movieMO.name = movie.name
            movieMO.overview = movie.overview
            movieMO.posterImageURL = movie.posterPath
            movieMO.releaseDate = movie.releaseDate
            
            if movie.isHintShown && !movieMO.isHintShown {
                movieMO.isHintShown = true
            }
            
            // set either as "guessed" or "revealed", or neither. Cannot be both.
            if movie.correctlyGuessed && movieMO.revealed == nil && movieMO.guessed == nil {
                let movieGuessedMO = MovieGuessedMO(context: coreDataStack.persistentContainer.viewContext)
                movieGuessedMO.dateAdded = Date()
                movieMO.guessed = movieGuessedMO
                movieMO.isHintShown = true
            }
            if movie.isRevealed && movieMO.revealed == nil && movieMO.guessed == nil {
                let movieRevealedMO = MovieRevealedMO(context: coreDataStack.persistentContainer.viewContext)
                movieRevealedMO.dateAdded = Date()
                movieMO.revealed = movieRevealedMO
                movieMO.isHintShown = true
            }
            
            // attach genre mo objects, either by fetching or by creating them.
            for genreID in movie.genreIDs {
                if let genreMO = fetchMovieGenre(id: genreID) {
                    // only add genre if it doesnt already exist on movie object
                    if !(movieMO.genres?.contains(genreMO) ?? false) {
                        print("** UPDATE MOVIE - adding EXISTING genreMO: \(genreMO)")
                        movieMO.addObject(value: genreMO, for: "genres")
                    }
                } else {
                    let genreMO = MovieGenreMO(context: coreDataStack.persistentContainer.viewContext)
                    genreMO.id = Int64(genreID)
                    print("** UPDATE MOVIE - adding NEW genreMO: \(genreMO)")
                    movieMO.addObject(value: genreMO, for: "genres")
                }
            }
            
            coreDataStack.saveContext()
        } else {
            print("** Found 0 existing entries for movie \(movie.id). Creating one now.")
            createMovie(movie: movie)
        }
    }
    
    @discardableResult
    private func createMovie(movie: Movie, shouldSetLastViewedDate: Bool = true) -> MovieMO {
        let movieMO = MovieMO(context: coreDataStack.persistentContainer.viewContext)
        
        movieMO.id = Int64(movie.id)
        movieMO.isHintShown = movie.isHintShown
        
        if movie.isRevealed {
            if movieMO.revealed == nil && movieMO.guessed == nil {
                let movieRevealedMO = MovieRevealedMO(context: coreDataStack.persistentContainer.viewContext)
                movieRevealedMO.dateAdded = Date()
                movieMO.revealed = movieRevealedMO
            }
        }
        if movie.correctlyGuessed {
            if movieMO.guessed == nil && movieMO.revealed == nil {
                let movieGuessedMO = MovieGuessedMO(context: coreDataStack.persistentContainer.viewContext)
                movieGuessedMO.dateAdded = Date()
                movieMO.guessed = movieGuessedMO
            }
        }
        
        // Set this to false if creating a movie but not opening it. (i.e. when creating a page of movies, we don't want
        // the movies to have a lastViewedDate if they haven't been viewed (opened in detail view))
        if shouldSetLastViewedDate {
            movieMO.lastViewedDate = Date()
        }
        
        movieMO.lastUpdated = Date()
        movieMO.name = movie.name
        movieMO.overview = movie.overview
        movieMO.posterImageURL = movie.posterPath
        movieMO.releaseDate = movie.releaseDate
        
        // attach genre mo objects, either by fetching or by creating them.
        for genreID in movie.genreIDs {
            if let genreMO = fetchMovieGenre(id: genreID) {
                genreMO.addObject(value: movieMO, for: "movies")
                print("** CREATED MOVIE - adding EXISTING genreMO: \(genreMO)")
                //movieMO.addObject(value: genreMO, for: "genres")
            } else {
                let genreMO = MovieGenreMO(context: coreDataStack.persistentContainer.viewContext)
                genreMO.id = Int64(genreID)
                genreMO.addObject(value: movieMO, for: "movies")
                print("** CREATED MOVIE - adding NEW genreMO: \(genreMO)")
                //movieMO.addObject(value: genreMO, for: "genres")
                print("** MOVIE MO AFTER CREATING MOVIE: \(movieMO)")
            }
        }
        
        coreDataStack.saveContext()
        return movieMO
    }
    
    func fetchMovie(id: Int, context: NSManagedObjectContext? = nil) -> [MovieMO] {
        let moc: NSManagedObjectContext
        if let providedContext = context {
            moc = providedContext
        } else {
            moc = coreDataStack.persistentContainer.viewContext
        }
        
        let movieFetch = NSFetchRequest<MovieMO>(entityName: "Movie")
        movieFetch.predicate = NSPredicate(format: "id == %ld", id)
        movieFetch.returnsObjectsAsFaults = false
        
        do {
            let fetchedMovies = try moc.fetch(movieFetch)
            print("FETCHED MOVIES: \(fetchedMovies)")
            return fetchedMovies
        } catch {
            print("** Failed to fetch movie: \(error)")
            return []
        }
    }
    
    
    
    

// MARK: -- TV SHOWS
    
    func updateOrCreateTVShow(tvShow: TVShow) {
        
    }
    
    
    
    
    
// MARK: -- PERSONS

    func updateOrCreatePerson(person: Person) {
        
    }
    
    @discardableResult
    func createPerson(person: BasePerson) -> PersonMO {
        let personMO = PersonMO(context: coreDataStack.persistentContainer.viewContext)
        
        personMO.id = Int64(person.id)
        personMO.name = person.name
        personMO.posterImageURL = person.posterPath
        
        coreDataStack.saveContext()
        return personMO
    }
    
    @discardableResult
    func createPerson(person: Person) -> PersonMO {
        let personMO = PersonMO(context: coreDataStack.persistentContainer.viewContext)
        
        personMO.id = Int64(person.id)
        personMO.isHintShown = person.isHintShown
        
        personMO.name = person.name
        personMO.posterImageURL = person.posterPath
        
        //personMO.isRevealed = person.isRevealed
        //personMO.correctlyGuessed = person.correctlyGuessed
        
        // fetch/create the movies in the persons knownFor array, then attach to personMO
        for title in person.knownFor {
            if title.type == .movie {
                /*if let movieMO = fetchMovie(id: title.id) {
                    
                } else {
                    let movieMO = createMovie(movie: Movie(movieOrTVShow: title))
                }*/
            } else if title.type == .tvShow {
                
            }
        }
        
        coreDataStack.saveContext()
        return personMO
    }
    
    func fetchPerson(id: Int, context: NSManagedObjectContext? = nil) -> PersonMO? {
        let moc: NSManagedObjectContext
        if let providedContext = context {
            moc = providedContext
        } else {
            moc = coreDataStack.persistentContainer.viewContext
        }
        
        let personFetch = NSFetchRequest<PersonMO>(entityName: "Person")
        personFetch.predicate = NSPredicate(format: "id == %ld", id)
        
        do {
            let fetchedPersons = try moc.fetch(personFetch)
            
            if fetchedPersons.count > 0 {
                
                if fetchedPersons.count > 1 {
                    print("*** WARNING: fetch for person with id \(id) returned \(fetchedPersons.count) PersonMOs.")
                }
                
                return fetchedPersons[0]
            } else {
                return nil
            }
        } catch {
            print("* ERROR: fetch Person by id failed. returning nil")
            return nil
        }
    }
    
    
    
    
    
// MARK: -- GUESS GRID
    
    func fetchMoviePage(_ pageNumber: Int, _ genreID: Int) -> [Movie]? {
        
        // fetch the movie page, then convert its movie mos to movies and return
        if let moviePageMO = fetchMoviePageMO(pageNumber, genreID) {
            print("**** fetchMoviePage - found existing movie page mo, returning movies")
            return getMoviesFromMoviePageMO(moviePageMO)
        } else {
            print("**** fetchMoviePage - NO movie page mo found")
            return nil
        }
    }
    
    private func getMoviesFromMoviePageMO(_ moviePageMO: MoviePageMO) -> [Movie]? {
        guard let movieMOs = moviePageMO.movies?.allObjects as? [MovieMO] else { return nil }
        return movieMOs.map { Movie(movieMO: $0) }
    }
    
    private func fetchMoviePageMO(_ pageNumber: Int, _ genreID: Int) -> MoviePageMO? {
        let moc = coreDataStack.persistentContainer.viewContext
        
        let pageFetch = NSFetchRequest<MoviePageMO>(entityName: "MoviePage")
        pageFetch.predicate = NSPredicate(format: "pageNumber == %ld && genreID == %ld", pageNumber, genreID)
        
        do {
            let fetchedPages = try moc.fetch(pageFetch)
            guard fetchedPages.count > 0 else { return nil }
            print("*** fetchedPages count: \(fetchedPages.count)")
            
            return fetchedPages[0]
        } catch {
            print("** Failed to fetch movie page: \(error)")
            return nil
        }
    }
    
    func fetchPersonPage(_ pageNumber: Int, _ genreID: Int) -> [Person]? {
        return []
    }
    
    func fetchTVShowPage(_ pageNumber: Int, _ genreID: Int) -> [TVShow]? {
        return []
    }
    
    @discardableResult
    func updateOrCreateMoviePage(movies: [Movie], pageNumber: Int, genreID: Int) -> [Movie]? {
        if let moviePageMO = fetchMoviePageMO(pageNumber, genreID) {
            print("**** updateOrCreateMoviePage - movie page mo found, updating it with movies now.")
            moviePageMO.removeAllObjects(for: "movies")
            
            addMoviesToMoviePageMO(movies: movies, moviePageMO: moviePageMO)
            
            moviePageMO.lastUpdated = Date()

            coreDataStack.saveContext()
            return getMoviesFromMoviePageMO(moviePageMO)
        } else {
            print("**** updateOrCreateMoviePage - NO movie page mo found, creating one now.")
            return createMoviePage(movies: movies, pageNumber: pageNumber, genreID: genreID)
        }
    }
    
    // DOESN'T SAVE CONTEXT AFTER ADDING MOVIES TO PAGE.
    private func addMoviesToMoviePageMO(movies: [Movie], moviePageMO: MoviePageMO) {
        for movie in movies {
            // first check if movie already in core data
            let existingMovies = fetchMovie(id: movie.id)
            if existingMovies.count > 0 {
                moviePageMO.addObject(value: existingMovies[0], for: "movies")
            } else {
                // None found, create a new movieMO object, and don't set the lastViewedDate field, because the movie hasn't
                // explicitly been loaded into a detail VC yet.
                let newMovie = createMovie(movie: movie, shouldSetLastViewedDate: false)
                moviePageMO.addObject(value: newMovie, for: "movies")
            }
        }
    }
    
    @discardableResult
    private func createMoviePage(movies: [Movie], pageNumber: Int, genreID: Int) -> [Movie]? {
        let moc = coreDataStack.persistentContainer.viewContext
        let pageMO = MoviePageMO(context: moc)
        pageMO.genreID = Int64(genreID)
        pageMO.pageNumber = Int64(pageNumber)
        pageMO.lastUpdated = Date()
        
        // create movieMO for each of the apiResponses movies, if they don't already exist
        addMoviesToMoviePageMO(movies: movies, moviePageMO: pageMO)
        
        coreDataStack.saveContext()
        return fetchMoviePage(pageNumber, genreID)
    }
    
    func createPersonPage(people: [Person], pageNumber: Int, genreID: Int) {
        
    }
    
    func createTVShowPage(tvShows: [TVShow], pageNumber: Int, genreID: Int) {
        
    }
    
    
    
    
    
// MARK: -- RECENTLY VIEWED
    
    func fetchPageOfRecentlyViewed() -> [Entity] {
        let moc = coreDataStack.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<MovieMO>(entityName: "Movie")
        fetchRequest.fetchLimit = 60
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastViewedDate", ascending: false)]
        
        do {
            let fetchedMovies: [MovieMO] = try moc.fetch(fetchRequest)
            return fetchedMovies.map { Movie(movieMO: $0) }
        } catch {
            print("** Failed to fetch recently viewed.")
            return []
        }
    }
    
    

    
    
// MARK: -- WATCHLIST & FAVORITES
    
    func addMovieToWatchlist(movie: Movie) {
        // add to watchlist if isFavorited is set to true
        let existingMovieEntries = fetchMovie(id: movie.id)
        
        if existingMovieEntries.count > 0 {
            print("** Found \(existingMovieEntries.count) existing entries for movie \(movie.id)")
            
            let movieMO = existingMovieEntries[0]
            
            // add movie to watchlist (if watchlist prop doesnt exist yet)
            if movieMO.watchlist == nil {
                print("** WATCHLIST - NEED TO CREATE NEW WATCHLISTMO FOR MOVIE: \(movie.name)")
                let movieWatchlistItem = MovieWatchlistMO(context: coreDataStack.persistentContainer.viewContext)
                movieWatchlistItem.dateAdded = Date()
                movieWatchlistItem.movie = movieMO
            } else {
                print("** WATCHLIST - MOVIE IS ALREADY IN WATCHLIST: \(movie.name)")
            }
            
            coreDataStack.saveContext()
        } else {
            print("** Found 0 existing entries for movie \(movie.id). Creating one now.")
            createMovie(movie: movie)
        }
    }
    
    func addTVShowToWatchlist(tvShow: TVShow) {
        
    }
    
    func addPersonToFavorites(person: Person) {
        
    }
    
    func removeMovieFromWatchlist(movie: Movie) {
        // add to watchlist if isFavorited is set to true
        let existingMovieEntries = fetchMovie(id: movie.id)
        
        if existingMovieEntries.count > 0 {
            print("** Found \(existingMovieEntries.count) existing entries for movie \(movie.id)")
            
            let movieMO = existingMovieEntries[0]
            
            // remove from watchlist
            if let movieWatchlist = movieMO.watchlist {
                print("** WATCHLIST - REMOVING MOVIE: \(movie.name)")
                coreDataStack.persistentContainer.viewContext.delete(movieWatchlist)
            }
            
            coreDataStack.saveContext()
        } else {
            print("** Found 0 existing entries for movie \(movie.id). Creating one now.")
            createMovie(movie: movie)
        }
    }
    
    func removeTVShowFromWatchlist(tvShow: TVShow) {
        
    }
    
    func removePersonFromFavorites(person: Person) {
        
    }
    
    func fetchWatchlist(genreID: Int) -> [Entity] {
        let moviesWatching = fetchMovieWatchlist(genreID: genreID)
        let tvShowsWatching = fetchTVShowWatchlist(genreID: genreID)
        
        return moviesWatching + tvShowsWatching
    }
    
    func fetchMovieWatchlist(genreID: Int) -> [Movie] {
        let moc = coreDataStack.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<MovieWatchlistMO>(entityName: "MovieWatchlist")
        //fetchRequest.fetchLimit = 20
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        //fetchRequest.predicate = NSPredicate(format: "correctlyGuessed == %@", NSNumber(value: true))
        
        do {
            let watchlistResults: [MovieWatchlistMO] = try moc.fetch(fetchRequest)
            
            var movieMOs = [MovieMO]()
            for watchlistResult in watchlistResults {
                if let movieMO = watchlistResult.movie {
                    movieMOs.append(movieMO)
                }
            }
            
            return movieMOs.map { Movie(movieMO: $0) }
        } catch {
            print("** Failed to fetch watchlist page.")
            return []
        }
    }
    
    func fetchTVShowWatchlist(genreID: Int) -> [TVShow] {
        // TODO
        return []
    }
    
    func fetchFavoritePeople() -> [Person] {
        // TODO
        return []
    }
    
    
    
    
    
// MARK: -- GUESSED
    
    func fetchGuessedMovies() -> [Movie] {
        let context = coreDataStack.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<MovieGuessedMO>(entityName: "MovieGuessed")
        fetchRequest.fetchLimit = 100000
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        
        do {
            let guessedResults: [MovieGuessedMO] = try context.fetch(fetchRequest)
            
            var movieMOs = [MovieMO]()
            for guessed in guessedResults {
                if let movieMO = guessed.movie {
                    movieMOs.append(movieMO)
                }
            }
            
            return movieMOs.map { Movie(movieMO: $0) }
        } catch {
            print("** Failed to fetch guessed page.")
            return []
        }
    }
    
    func fetchGuessedTVShows() -> [TVShow] {
        return []
    }
    
    func fetchGuessedPeople() -> [Person] {
        return []
    }
    
    
    
    
    
// MARK: -- REVEALED
    
    func fetchRevealedMovies() -> [Movie] {
        let context = coreDataStack.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<MovieRevealedMO>(entityName: "MovieRevealed")
        fetchRequest.fetchLimit = 100000
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        
        do {
            let revealedResults: [MovieRevealedMO] = try context.fetch(fetchRequest)
            
            var movieMOs = [MovieMO]()
            for revealed in revealedResults {
                if let movieMO = revealed.movie {
                    movieMOs.append(movieMO)
                }
            }
            
            return movieMOs.map { Movie(movieMO: $0) }
        } catch {
            print("** Failed to fetch revealed page.")
            return []
        }
    }
    
    func fetchRevealedTVShows() -> [TVShow] {
        return []
    }
    
    func fetchRevealedPeople() -> [Person] {
        return []
    }
    
    
    
    
    
// MARK: -- GENRES
    
    // should always be called after a network request is performed for this info.
    func updateOrCreateMovieGenreList(genres: [Genre]) {
        for genre in genres {
            if let genreMO = fetchMovieGenre(id: genre.id) {
                // update existing genre managed object
                genreMO.name = genre.name
                genreMO.lastUpdated = Date()
            } else {
                // create a genre for this id
                let genreMO = MovieGenreMO(context: coreDataStack.persistentContainer.viewContext)
                genreMO.id = Int64(genre.id)
                genreMO.name = genre.name
                genreMO.lastUpdated = Date()
            }
        }
        
        coreDataStack.saveContext()
    }
    
    func fetchMovieGenres() -> [MovieGenre] {
        let moc = coreDataStack.persistentContainer.viewContext
        let genreFetch = NSFetchRequest<MovieGenreMO>(entityName: "MovieGenre")
        
        do {
            let fetched = try moc.fetch(genreFetch)
            let genreObjects = fetched.map { MovieGenre(genreMO: $0) }
            
            // if any of the returned genres have no name, we return [] to signify
            // genres need to be updated from network.
            for genre in genreObjects {
                if genre.name.isEmpty { return [] }
            }
            
            return genreObjects
        } catch {
            print("** Failed to perforn fetch for all genres.")
            return []
        }
    }
    
    func fetchMovieGenre(id: Int) -> MovieGenreMO? {
        let moc = coreDataStack.persistentContainer.viewContext
        let genreFetch = NSFetchRequest<MovieGenreMO>(entityName: "MovieGenre")
        genreFetch.predicate = NSPredicate(format: "id == %ld", id)
        
        let fetchedGenres: [MovieGenreMO]
        do {
            fetchedGenres = try moc.fetch(genreFetch)
            print("FETCHED Genres: \(fetchedGenres)")
        } catch {
            print("** Failed to fetch genre (id: \(id)): \(error)")
            return nil
        }
        
        if fetchedGenres.count > 0 {
            return fetchedGenres[0]
        } else {
            return nil
        }
    }
    
    
    

    
// MARK: -- CREDITS
    
    func updateOrCreateCredits(type: EntityType, credits: Credits) {
        switch type {
    
        case .movie:
            updateOrCreateMovieCredits(credits: credits)
        case .tvShow:
            return
        default:
            return
        }
    }
    
    func updateOrCreateMovieCredits(credits: Credits) {
        let moc = coreDataStack.persistentContainer.viewContext
        let movieCreditsMO = MovieCreditsMO(context: moc)
        movieCreditsMO.id = Int64(credits.id)
        
        // fetch/create person objects, then attach them to cast/crew
        for castMember in credits.cast {
            if let existingPersonMO = fetchPerson(id: castMember.id) {
                movieCreditsMO.addObject(value: existingPersonMO, for: "cast")
            } else {
                let newPersonMO = createPerson(person: castMember)
                movieCreditsMO.addObject(value: newPersonMO, for: "cast")
            }
        }
        for crewMember in credits.crew {
            if let existingPersonMO = fetchPerson(id: crewMember.id) {
                movieCreditsMO.addObject(value: existingPersonMO, for: "crew")
            } else {
                let newPersonMO = createPerson(person: crewMember)
                movieCreditsMO.addObject(value: newPersonMO, for: "crew")
            }
        }
        
        coreDataStack.saveContext()
    }
    
    func updateOrCreateTVShowCredits(credits: Credits) {
        
    }
    
    func getCreditsFor(type: EntityType, id: Int) -> Credits? {
        
        
        return nil
    }
    
    func getPersonCreditsFor(id: Int) -> PersonCredits? {
        
        return nil
    }
    

    
    
    
    // MARK:- HELPER METHODS
    
    func deleteAllData(_ entity: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try coreDataStack.persistentContainer.viewContext.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                coreDataStack.persistentContainer.viewContext.delete(objectData)
            }
        } catch let error {
            print("**** Detele all data in \(entity) error :", error)
        }
    }
    
    func deleteAllDataFromAllEntities() {
        deleteAllData("Movie")
        deleteAllData("TVShow")
        deleteAllData("Person")
        
        deleteAllData("MovieWatchlist")
        deleteAllData("TVShowWatchlist")
        deleteAllData("PersonFavorites")
        
        deleteAllData("MoviePage")
        deleteAllData("TVShowPage")
        deleteAllData("PersonPage")
        
        deleteAllData("MovieGuessed")
        deleteAllData("TVShowGuessed")
        deleteAllData("PersonGuessed")
        
        deleteAllData("MovieRevealed")
        deleteAllData("TVShowRevealed")
        deleteAllData("PersonRevealed")
        
        deleteAllData("MovieCredits")
        deleteAllData("TVShowCredits")
        deleteAllData("PersonCredits")
        
        deleteAllData("MovieGenre")
        deleteAllData("TVShowGenre")
    }
}
