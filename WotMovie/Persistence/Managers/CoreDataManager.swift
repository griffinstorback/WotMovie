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
    func getNumberGuessedFor(category: CategoryType, withHint: Bool) -> Int {
        switch category {
        case .movie:
            return fetchMovieGuessedCount(withHint: withHint)
        case .person:
            return fetchPersonGuessedCount(withHint: withHint)
        case .tvShow:
            return fetchTVShowGuessedCount(withHint: withHint)
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
    @discardableResult
    func updateOrCreateEntity(entity: Entity) -> Entity {
        switch entity.type {
        case .movie:
            if let movie = entity as? Movie {
                return Movie(movieMO: updateOrCreateMovie(movie: movie))
            }
        case .tvShow:
            if let tvShow = entity as? TVShow {
                return TVShow(tvShowMO: updateOrCreateTVShow(tvShow: tvShow))
            }
        case .person:
            if let person = entity as? Person {
                return Person(personMO: updateOrCreatePerson(person: person))
            }
        }
        
        // TODO : DELETE THIS after implementing updateOrCreate person?
        return Movie(movieOrTVShow: MovieOrTVShow(id: -1, type: .movie, name: "ERROR", posterPath: nil, overview: "THIS SHOULD NOT BE SEEN EVER!", releaseDate: "NEVER!", genreIDs: [], personsJob: nil, character: nil))!
    }
    
    // returns empty list if page doesnt exist. returns nil if there was an error
    func fetchEntityPage(category: CategoryType, pageNumber: Int, genreID: Int = -1) -> [Entity]? {
        switch category {
        case .movie:
            return fetchMoviePage(pageNumber, genreID)
        case .person:
            return fetchPersonPage(pageNumber)
        case .tvShow:
            return fetchTVShowPage(pageNumber, genreID)
        default:
            // if category type was "stats", nothing to return.
            return nil
        }
    }
    
    func fetchPageOfRecentlyViewed() -> [Entity] {
        return fetchPageOfRecentlyViewedMovies(amount: 60) + fetchPageOfRecentlyViewedTVShows(amount: 60) + fetchPageOfRecentlyViewedPeople(amount: 60)
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
    func fetchMovieGuessedCount(withHint: Bool) -> Int {
        let context = coreDataStack.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<MovieGuessedMO>(entityName: "MovieGuessed")
        fetchRequest.predicate = NSPredicate(format: "movie.isHintShown == %@", NSNumber(value: withHint))
        
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
    func fetchTVShowGuessedCount(withHint: Bool) -> Int {
        let context = coreDataStack.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<TVShowGuessedMO>(entityName: "TVShowGuessed")
        fetchRequest.predicate = NSPredicate(format: "tvShow.isHintShown == %@", NSNumber(value: withHint))
        
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
    func fetchPersonGuessedCount(withHint: Bool) -> Int {
        let context = coreDataStack.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<PersonGuessedMO>(entityName: "PersonGuessed")
        fetchRequest.predicate = NSPredicate(format: "person.isHintShown == %@", NSNumber(value: withHint))
        
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
    
    @discardableResult
    func updateOrCreateMovie(movie: Movie, shouldSetLastViewedDate: Bool = true) -> MovieMO {
        let moc = coreDataStack.persistentContainer.viewContext
        
        let movieMO = fetchMovie(id: movie.id) ?? {
            print("** UPDATE MOVIE: Movie (\(movie.name)) not found, creating new movieMO.")
            let movieMO = MovieMO(context: moc)
            movieMO.id = Int64(movie.id)
            movieMO.isHintShown = movie.isHintShown
            return movieMO
        }()
            
        // update all values except 'id'
        // (in case movie overview in api has changed since last stored).
        movieMO.language = Locale.autoupdatingCurrent.identifier
        movieMO.lastUpdated = Date()
        movieMO.name = movie.name
        movieMO.overview = movie.overview
        movieMO.posterImageURL = movie.posterPath
        movieMO.releaseDate = movie.releaseDate
        
        // Set this to false if creating a movie but not opening it. (i.e. when creating a page of movies, we don't want
        // the movies to have a lastViewedDate if they haven't been viewed (opened in detail view))
        if shouldSetLastViewedDate {
            movieMO.lastViewedDate = Date()
        }
        
        // Only set these to true; don't allow it to be set from true to false, that should never have to happen.
        if movie.isHintShown {
            movieMO.isHintShown = movie.isHintShown
        }
        
        // set either as "guessed" or "revealed", or neither. Cannot be both.
        if movie.correctlyGuessed && movieMO.revealed == nil && movieMO.guessed == nil {
            let movieGuessedMO = MovieGuessedMO(context: moc)
            movieGuessedMO.dateAdded = Date()
            movieMO.guessed = movieGuessedMO
        }
        if movie.isRevealed && movieMO.revealed == nil && movieMO.guessed == nil {
            let movieRevealedMO = MovieRevealedMO(context: moc)
            movieRevealedMO.dateAdded = Date()
            movieMO.revealed = movieRevealedMO
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
                let genreMO = MovieGenreMO(context: moc)
                genreMO.id = Int64(genreID)
                print("** UPDATE MOVIE - adding NEW genreMO: \(genreMO)")
                movieMO.addObject(value: genreMO, for: "genres")
            }
        }
        
        coreDataStack.saveContext()
        return movieMO
    }
    
    /*
    @discardableResult
    private func createMovie(movie: Movie, shouldSetLastViewedDate: Bool = true) -> MovieMO {
        let movieMO = MovieMO(context: coreDataStack.persistentContainer.viewContext)
        
        movieMO.id = Int64(movie.id)
        movieMO.language = Locale.autoupdatingCurrent.identifier
        movieMO.lastUpdated = Date()
        movieMO.name = movie.name
        movieMO.overview = movie.overview
        movieMO.posterImageURL = movie.posterPath
        movieMO.releaseDate = movie.releaseDate
        
        // Set this to false if creating a movie but not opening it. (i.e. when creating a page of movies, we don't want
        // the movies to have a lastViewedDate if they haven't been viewed (opened in detail view))
        if shouldSetLastViewedDate {
            movieMO.lastViewedDate = Date()
        }
        
        // Only set these to true; don't allow it to be set from true to false, that should never have to happen.
        if movie.isHintShown {
            movieMO.isHintShown = movie.isHintShown
        }
        if movie.isRevealed {
            let movieRevealedMO = MovieRevealedMO(context: coreDataStack.persistentContainer.viewContext)
            movieRevealedMO.dateAdded = Date()
            movieMO.revealed = movieRevealedMO
        }
        if movie.correctlyGuessed {
            let movieGuessedMO = MovieGuessedMO(context: coreDataStack.persistentContainer.viewContext)
            movieGuessedMO.dateAdded = Date()
            movieMO.guessed = movieGuessedMO
        }
        
        // attach genre mo objects, either by fetching or by creating them.
        for genreID in movie.genreIDs {
            if let genreMO = fetchMovieGenre(id: genreID) {
                genreMO.addObject(value: movieMO, for: "movies")
            } else {
                let genreMO = MovieGenreMO(context: coreDataStack.persistentContainer.viewContext)
                genreMO.id = Int64(genreID)
                genreMO.addObject(value: movieMO, for: "movies")
            }
        }
        
        coreDataStack.saveContext()
        return movieMO
    }
    */
    
    func fetchMovie(id: Int, context: NSManagedObjectContext? = nil) -> MovieMO? {
        let moc = context ?? coreDataStack.persistentContainer.viewContext
        
        let movieFetch = NSFetchRequest<MovieMO>(entityName: "Movie")
        movieFetch.predicate = NSPredicate(format: "id == %ld", id)
        movieFetch.returnsObjectsAsFaults = false
        
        do {
            let fetchedMovies = try moc.fetch(movieFetch)
            
            guard fetchedMovies.count > 0 else {
                return nil
            }
            
            if fetchedMovies.count > 1 {
                print("** WARNING: in fetchMovie(), got \(fetchedMovies.count) results when there should be just 1.")
            }
            
            return fetchedMovies[0]
        } catch {
            print("** WARNING: Failed to fetch movie: \(error)")
            return nil
        }
    }
    
    
    
    

// MARK: -- TV SHOWS
    
    @discardableResult
    func updateOrCreateTVShow(tvShow: TVShow, shouldSetLastViewedDate: Bool = true) -> TVShowMO {
        let moc = coreDataStack.persistentContainer.viewContext
        
        let tvShowMO = fetchTVShow(id: tvShow.id) ?? {
            print("** UPDATE TV SHOW: NO PERSON FOUND FOR \(tvShow.name), CREATING ONE NOW")
            let tvShowMO = TVShowMO(context: moc)
            tvShowMO.id = Int64(tvShow.id)
            tvShowMO.isHintShown = tvShow.isHintShown
            return tvShowMO
        }()
        
        // update all values except 'id'
        // (in case tv show in api has changed since last stored, or if user changes language).
        tvShowMO.language = Locale.autoupdatingCurrent.identifier
        tvShowMO.lastUpdated = Date()
        tvShowMO.name = tvShow.name
        tvShowMO.overview = tvShow.overview
        tvShowMO.posterImageURL = tvShow.posterPath
        tvShowMO.releaseDate = tvShow.releaseDate
        
        // Set this to false if creating a tv show but not opening it. (i.e. when creating a page of tv shows, we don't want
        // the tv shows to have a lastViewedDate if they haven't been viewed (opened in detail view))
        if shouldSetLastViewedDate {
            tvShowMO.lastViewedDate = Date()
        }
        
        // Only set these to true; don't allow it to be set from true to false, that should never have to happen.
        if tvShow.isHintShown {
            tvShowMO.isHintShown = tvShow.isHintShown
        }
        
        // set either as "guessed" or "revealed", or neither. Cannot be both.
        if tvShow.correctlyGuessed && tvShowMO.revealed == nil && tvShowMO.guessed == nil {
            let tvShowGuessedMO = TVShowGuessedMO(context: moc)
            tvShowGuessedMO.dateAdded = Date()
            tvShowMO.guessed = tvShowGuessedMO
        }
        if tvShow.isRevealed && tvShowMO.revealed == nil && tvShowMO.guessed == nil {
            let tvShowRevealedMO = TVShowRevealedMO(context: moc)
            tvShowRevealedMO.dateAdded = Date()
            tvShowMO.revealed = tvShowRevealedMO
        }
        
        // attach genre mo objects, either by fetching or by creating them.
        for genreID in tvShow.genreIDs {
            if let genreMO = fetchTVShowGenre(id: genreID) {
                // only add genre if it doesnt already exist on tvshow object
                if !(tvShowMO.genres?.contains(genreMO) ?? false) {
                    print("** UPDATE TV SHOW - adding EXISTING genreMO: \(genreMO)")
                    tvShowMO.addObject(value: genreMO, for: "genres")
                }
            } else {
                let genreMO = TVShowGenreMO(context: moc)
                genreMO.id = Int64(genreID)
                print("** UPDATE TV SHOW - adding NEW genreMO: \(genreMO)")
                tvShowMO.addObject(value: genreMO, for: "genres")
            }
        }
        
        coreDataStack.saveContext()
        return tvShowMO
    }
    
    /*
    @discardableResult
    private func createTVShow(tvShow: TVShow, shouldSetLastViewedDate: Bool = true) -> TVShowMO {
        let tvShowMO = TVShowMO(context: coreDataStack.persistentContainer.viewContext)
        
        tvShowMO.id = Int64(tvShow.id)
        tvShowMO.language = Locale.autoupdatingCurrent.identifier
        tvShowMO.lastUpdated = Date()
        tvShowMO.name = tvShow.name
        tvShowMO.overview = tvShow.overview
        tvShowMO.posterImageURL = tvShow.posterPath
        tvShowMO.releaseDate = tvShow.releaseDate
        
        // Set this to false if creating a tv show but not opening it. (i.e. when creating a page of tv show, we don't want
        // the tv shows to have a lastViewedDate if they haven't been viewed (opened in detail view))
        if shouldSetLastViewedDate {
            tvShowMO.lastViewedDate = Date()
        }
        
        // Only set these to true; don't allow it to be set from true to false, that should never have to happen.
        if tvShow.isHintShown {
            tvShowMO.isHintShown = tvShow.isHintShown
        }
        if tvShow.isRevealed {
            let tvShowRevealedMO = TVShowRevealedMO(context: coreDataStack.persistentContainer.viewContext)
            tvShowRevealedMO.dateAdded = Date()
            tvShowMO.revealed = tvShowRevealedMO
        }
        if tvShow.correctlyGuessed {
            let tvShowGuessedMO = TVShowGuessedMO(context: coreDataStack.persistentContainer.viewContext)
            tvShowGuessedMO.dateAdded = Date()
            tvShowMO.guessed = tvShowGuessedMO
        }
        
        // attach genre mo objects, either by fetching or by creating them.
        for genreID in tvShow.genreIDs {
            if let genreMO = fetchTVShowGenre(id: genreID) {
                genreMO.addObject(value: tvShowMO, for: "tvShows")
            } else {
                let genreMO = TVShowGenreMO(context: coreDataStack.persistentContainer.viewContext)
                genreMO.id = Int64(genreID)
                genreMO.addObject(value: tvShowMO, for: "tvShows")
            }
        }
        
        coreDataStack.saveContext()
        return tvShowMO
    }
     */
    
    func fetchTVShow(id: Int, context: NSManagedObjectContext? = nil) -> TVShowMO? {
        let moc = context ?? coreDataStack.persistentContainer.viewContext
        
        let tvShowFetch = NSFetchRequest<TVShowMO>(entityName: "TVShow")
        tvShowFetch.predicate = NSPredicate(format: "id == %ld", id)
        tvShowFetch.returnsObjectsAsFaults = false
        
        do {
            let fetchedTVShows = try moc.fetch(tvShowFetch)
            guard fetchedTVShows.count > 0 else { return nil }
            
            if fetchedTVShows.count > 1 {
                print("** WARNING: in fetchTVShow(), got \(fetchedTVShows.count) results when there should be just 1.")
            }
            
            return fetchedTVShows[0]
        } catch {
            print("** WARNING: Failed to fetch tvshow: \(error)")
            return nil
        }
    }
    
    
    
    
    
// MARK: -- PERSONS

    @discardableResult
    func updateOrCreatePerson(person: Person, shouldSetLastViewedDate: Bool = true, context: NSManagedObjectContext? = nil) -> PersonMO {
        let moc = context ?? coreDataStack.persistentContainer.viewContext
        
        // get existing person or create new one and set its id
        let personMO = fetchPerson(id: person.id) ?? {
            print("** UPDATE PERSON: NO PERSON FOUND FOR \(person.name), CREATING ONE NOW")
            let personMO = PersonMO(context: moc)
            personMO.id = Int64(person.id)
            personMO.isHintShown = person.isHintShown
            return personMO
        }()
            
        // update all values except id, in case tv show in api has changed since last stored, or if user changes language
        personMO.language = Locale.autoupdatingCurrent.identifier
        personMO.lastUpdated = Date()
        personMO.name = person.name
        personMO.posterImageURL = person.posterPath
        
        personMO.birthday = person.birthday
        personMO.deathday = person.deathday
        personMO.gender = Int16(person.gender ?? 0)
        personMO.knownForDepartment = person.knownForDepartment
        
        // Set this to false if creating a person but not opening it. (i.e. when creating a page of people, we don't want
        // the people to have a lastViewedDate if they haven't been viewed (opened in detail view))
        if shouldSetLastViewedDate {
            personMO.lastViewedDate = Date()
        }
        
        // Only set these to true; don't allow it to be set from true to false, that should never have to happen.
        if person.isHintShown {
            personMO.isHintShown = person.isHintShown
        }
        
        // set either as "guessed" or "revealed", or neither. Cannot be both.
        if person.correctlyGuessed && personMO.revealed == nil && personMO.guessed == nil {
            let personGuessedMO = PersonGuessedMO(context: moc)
            personGuessedMO.dateAdded = Date()
            personMO.guessed = personGuessedMO
        }
        if person.isRevealed && personMO.revealed == nil && personMO.guessed == nil {
            let personRevealedMO = PersonRevealedMO(context: moc)
            personRevealedMO.dateAdded = Date()
            personMO.revealed = personRevealedMO
        }
        
        // fetch/create the movies in the persons knownFor array, then attach to personMO
        for title in person.knownFor {
            if title.type == .movie {
                guard let movieOrTVShow = title as? MovieOrTVShow else { continue }
                guard let movie = Movie(movieOrTVShow: movieOrTVShow) else { continue }
                let movieMO = updateOrCreateMovie(movie: movie)
                
                // only add movie if it doesnt already exist on personMOs knownForMovies
                if !(personMO.knownForMovies?.contains(movieMO) ?? false) {
                    print("** UPDATE PERSON - ADDING MOVIE TO KNOWN FOR MOVIES: \(movieMO)")
                    personMO.addObject(value: movieMO, for: "knownForMovies")
                }
            } else if title.type == .tvShow {
                guard let movieOrTVShow = title as? MovieOrTVShow else { continue }
                guard let tvShow = TVShow(movieOrTVShow: movieOrTVShow) else { continue }
                let tvShowMO = updateOrCreateTVShow(tvShow: tvShow)
                
                // only add tv show if it doesnt already exist on personMOs knownForTVShows
                if !(personMO.knownForTVShows?.contains(tvShowMO) ?? false) {
                    print("** UPDATE PERSON - ADDING TV SHOW TO KNOWN FOR TVSHOWS: \(tvShowMO)")
                    personMO.addObject(value: tvShowMO, for: "knownForTVShows")
                }
            }
        }
        
        coreDataStack.saveContext()
        return personMO
    }
    
    func fetchPerson(id: Int, context: NSManagedObjectContext? = nil) -> PersonMO? {
        let moc = context ?? coreDataStack.persistentContainer.viewContext
        
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
    
    
    
    
    
// MARK: -- GUESS GRID (MOVIES)
    
    func fetchMoviePage(_ pageNumber: Int, _ genreID: Int) -> [Movie]? {
        
        // fetch the movie page, then convert its movie mos to movies and return
        if let moviePageMO = fetchMoviePageMO(pageNumber, genreID) {
            return getMoviesFromMoviePageMO(moviePageMO)
        } else {
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
            if fetchedPages.count > 1 {
                print("** WARNING: movie page for pageNumber \(pageNumber) and genreID \(genreID)")
            }
            
            return fetchedPages[0]
        } catch {
            print("** Failed to fetch movie page: \(error)")
            return nil
        }
    }
    
    @discardableResult
    func updateOrCreateMoviePage(movies: [Movie], pageNumber: Int, genreID: Int) -> [Movie]? {
        let moc = coreDataStack.persistentContainer.viewContext
        
        let moviePageMO = fetchMoviePageMO(pageNumber, genreID) ?? {
            print("** UPDATE MOVIE PAGE: no movie page found for page \(pageNumber), genre \(genreID), creating one now")
            let pageMO = MoviePageMO(context: moc)
            pageMO.genreID = Int64(genreID)
            pageMO.pageNumber = Int64(pageNumber)
            return pageMO
        }()
        
        moviePageMO.lastUpdated = Date()
        moviePageMO.region = Locale.autoupdatingCurrent.regionCode
        
        // replace current movies and replace with new ones
        moviePageMO.removeAllObjects(for: "movies")
        addMoviesToMoviePageMO(movies: movies, moviePageMO: moviePageMO)
        
        coreDataStack.saveContext()
        return getMoviesFromMoviePageMO(moviePageMO)
    }
    
    // DOESN'T SAVE CONTEXT AFTER ADDING MOVIES TO PAGE (helper function, don't call directly)
    private func addMoviesToMoviePageMO(movies: [Movie], moviePageMO: MoviePageMO) {
        for movie in movies {
            // update or create the movie, then add it to the provided page mo
            let movieMO = updateOrCreateMovie(movie: movie, shouldSetLastViewedDate: false)
            moviePageMO.addObject(value: movieMO, for: "movies")
            
            
            // TODO: DELETE --- LEFT IT JUST KEEPING IN CASE SOMETHING GOES WRONG
            // first check if movie already in core data
            /*if let existingMovieMO = fetchMovie(id: movie.id) {
                moviePageMO.addObject(value: existingMovieMO, for: "movies")
            } else {
                // None found, create a new movieMO object, and don't set the lastViewedDate field, because the movie hasn't
                // explicitly been loaded into a detail VC yet.
                let newMovie = createMovie(movie: movie, shouldSetLastViewedDate: false)
                moviePageMO.addObject(value: newMovie, for: "movies")
            }*/
        }
    }
    
    
    
    
    
// MARK: -- GUESS GRID (TV SHOWS)
    
    func fetchTVShowPage(_ pageNumber: Int, _ genreID: Int) -> [TVShow]? {
        
        // fetch the tv show page, then convert its tv show MOs to tv shows and return
        if let tvShowPageMO = fetchTVShowPageMO(pageNumber, genreID) {
            return getTVShowsFromTVShowPageMO(tvShowPageMO)
        } else {
            return nil
        }
    }
    
    private func getTVShowsFromTVShowPageMO(_ tvShowPageMO: TVShowPageMO) -> [TVShow]? {
        guard let tvShowMOs = tvShowPageMO.tvShows?.allObjects as? [TVShowMO] else { return nil }
        return tvShowMOs.map { TVShow(tvShowMO: $0) }
    }
    
    private func fetchTVShowPageMO(_ pageNumber: Int, _ genreID: Int) -> TVShowPageMO? {
        let moc = coreDataStack.persistentContainer.viewContext
        
        let pageFetch = NSFetchRequest<TVShowPageMO>(entityName: "TVShowPage")
        pageFetch.predicate = NSPredicate(format: "pageNumber == %ld && genreID == %ld", pageNumber, genreID)
        
        do {
            let fetchedPages = try moc.fetch(pageFetch)
            guard fetchedPages.count > 0 else { return nil }
            if fetchedPages.count > 1 {
                print("** WARNING: tv show page \(pageNumber) for genreID \(genreID) returned \(fetchedPages.count) results (instead of 1)")
            }
            
            return fetchedPages[0]
        } catch {
            print("** Failed to fetch tv show page: \(error)")
            return nil
        }
    }
    
    @discardableResult
    func updateOrCreateTVShowPage(tvShows: [TVShow], pageNumber: Int, genreID: Int) -> [TVShow]? {
        let moc = coreDataStack.persistentContainer.viewContext
        
        let tvShowPageMO = fetchTVShowPageMO(pageNumber, genreID) ?? {
            print("** UPDATE TV SHOW PAGE: no tv show page found for page \(pageNumber), genre \(genreID), creating one now")
            let pageMO = TVShowPageMO(context: moc)
            pageMO.genreID = Int64(genreID)
            pageMO.pageNumber = Int64(pageNumber)
            return pageMO
        }()
        
        tvShowPageMO.lastUpdated = Date()
        tvShowPageMO.region = Locale.autoupdatingCurrent.regionCode
        
        // reset tvShow objects in this page, if there are any, then add the ones passed in.
        tvShowPageMO.removeAllObjects(for: "tvShows")
        addTVShowsToTVShowPageMO(tvShows: tvShows, tvShowPageMO: tvShowPageMO)

        coreDataStack.saveContext()
        return getTVShowsFromTVShowPageMO(tvShowPageMO)
    }
    
    // DOESN'T SAVE CONTEXT AFTER ADDING TV SHOWS TO PAGE (helper function, don't call directly)
    private func addTVShowsToTVShowPageMO(tvShows: [TVShow], tvShowPageMO: TVShowPageMO) {
        for tvShow in tvShows {
            // update or create the tv show, then add it to the provided page mo
            let tvShowMO = updateOrCreateTVShow(tvShow: tvShow, shouldSetLastViewedDate: false)
            tvShowPageMO.addObject(value: tvShowMO, for: "tvShows")
        }
    }
    
    
    
    
    
// MARK: -- GUESS GRID (PEOPLE)
    
    func fetchPersonPage(_ pageNumber: Int) -> [Person]? {
        
        // fetch the person page, then convert its 'PersonMO's to 'Person's and return
        if let personPageMO = fetchPersonPageMO(pageNumber) {
            return getPeopleFromPersonPageMO(personPageMO)
        } else {
            return nil
        }
    }
    
    private func getPeopleFromPersonPageMO(_ personPageMO: PersonPageMO) -> [Person]? {
        guard let personMOs = personPageMO.people?.allObjects as? [PersonMO] else { return nil }
        return personMOs.map { Person(personMO: $0) }
    }
    
    private func fetchPersonPageMO(_ pageNumber: Int) -> PersonPageMO? {
        let moc = coreDataStack.persistentContainer.viewContext
        
        let pageFetch = NSFetchRequest<PersonPageMO>(entityName: "PersonPage")
        pageFetch.predicate = NSPredicate(format: "pageNumber == %ld", pageNumber)
        
        do {
            let fetchedPages = try moc.fetch(pageFetch)
            guard fetchedPages.count > 0 else { return nil }
            if fetchedPages.count > 1 {
                print("** WARNING: person page \(pageNumber) returned \(fetchedPages.count) results (instead of 1)")
            }
            
            return fetchedPages[0]
        } catch {
            print("** Failed to fetch person page: \(error)")
            return nil
        }
    }
    
    @discardableResult
    func updateOrCreatePersonPage(people: [Person], pageNumber: Int) -> [Person]? {
        let moc = coreDataStack.persistentContainer.viewContext
        
        let personPageMO = fetchPersonPageMO(pageNumber) ?? {
            print("** UPDATE PERSON PAGE: no person page found for page \(pageNumber), creating one now")
            let pageMO = PersonPageMO(context: moc)
            pageMO.pageNumber = Int64(pageNumber)
            return pageMO
        }()
        
        personPageMO.lastUpdated = Date()
        personPageMO.region = Locale.autoupdatingCurrent.regionCode
        
        // reset tvShow objects in this page, if there are any, then add the ones passed in.
        personPageMO.removeAllObjects(for: "people")
        addPeopleToPersonPageMO(people: people, personPageMO: personPageMO)

        coreDataStack.saveContext()
        return getPeopleFromPersonPageMO(personPageMO)
    }
    
    // DOESN'T SAVE CONTEXT AFTER ADDING PEOPLE TO PAGE (helper function, don't call directly)
    private func addPeopleToPersonPageMO(people: [Person], personPageMO: PersonPageMO) {
        for person in people {
            // update or create the person, then add it to the provided page mo
            let personMO = updateOrCreatePerson(person: person, shouldSetLastViewedDate: false)
            personPageMO.addObject(value: personMO, for: "people")
        }
    }
    
    
    
    
    
// MARK: -- RECENTLY VIEWED
    
    func fetchPageOfRecentlyViewedMovies(amount: Int = 60) -> [Movie] {
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
    
    func fetchPageOfRecentlyViewedTVShows(amount: Int = 60) -> [TVShow] {
        let moc = coreDataStack.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<TVShowMO>(entityName: "TVShow")
        fetchRequest.fetchLimit = 60
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastViewedDate", ascending: false)]
        
        do {
            let fetchedTVShows: [TVShowMO] = try moc.fetch(fetchRequest)
            return fetchedTVShows.map { TVShow(tvShowMO: $0) }
        } catch {
            print("** Failed to fetch recently viewed.")
            return []
        }
    }
    
    func fetchPageOfRecentlyViewedPeople(amount: Int = 60) -> [Person] {
        let moc = coreDataStack.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<PersonMO>(entityName: "Person")
        fetchRequest.fetchLimit = 60
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastViewedDate", ascending: false)]
        
        do {
            let fetchedPeople: [PersonMO] = try moc.fetch(fetchRequest)
            return fetchedPeople.map { Person(personMO: $0) }
        } catch {
            print("** Failed to fetch recently viewed.")
            return []
        }
    }
    
    // TODO: Should I implement these? Or should I fetch a page of recently viewed when fetching a guess grid, and filter in the guess grid presenter? (I think the latter would
    // be better - it would mean one core data query instead of a query for each title.)
    func movieWasViewedRecently(movie: Movie) -> Bool {
        return false
    }
    
    func tvShowWasViewedRecently(tvShow: TVShow) -> Bool {
        return false
    }
    
    func personWasViewedRecently(person: Person) -> Bool {
        return false
    }
    
    

    
    
// MARK: -- WATCHLIST & FAVORITES
    
    private func addMovieToWatchlist(movie: Movie) {
        // create movie if it doesnt exist yet.
        if let movieMO = fetchMovie(id: movie.id) {
            
            // add movie to watchlist (if watchlist prop doesnt exist yet)
            if movieMO.watchlist == nil {
                let movieWatchlistItem = MovieWatchlistMO(context: coreDataStack.persistentContainer.viewContext)
                movieWatchlistItem.dateAdded = Date()
                movieWatchlistItem.movie = movieMO
            }
        } else {
            let movieMO = updateOrCreateMovie(movie: movie)
            let movieWatchlistItem = MovieWatchlistMO(context: coreDataStack.persistentContainer.viewContext)
            movieWatchlistItem.dateAdded = Date()
            movieWatchlistItem.movie = movieMO
        }
        
        coreDataStack.saveContext()
    }
    
    private func addTVShowToWatchlist(tvShow: TVShow) {
        // create tv show if it doesnt exist yet.
        if let tvShowMO = fetchTVShow(id: tvShow.id) {
            
            // add movie to watchlist (if watchlist prop doesnt exist yet)
            if tvShowMO.watchlist == nil {
                let tvShowWatchlistItem = TVShowWatchlistMO(context: coreDataStack.persistentContainer.viewContext)
                tvShowWatchlistItem.dateAdded = Date()
                tvShowWatchlistItem.tvShow = tvShowMO
            }
        } else {
            let tvShowMO = updateOrCreateTVShow(tvShow: tvShow)
            let tvShowWatchlistItem = TVShowWatchlistMO(context: coreDataStack.persistentContainer.viewContext)
            tvShowWatchlistItem.dateAdded = Date()
            tvShowWatchlistItem.tvShow = tvShowMO
        }
        
        coreDataStack.saveContext()
    }
    
    private func addPersonToFavorites(person: Person) {
        // create person if it doesnt exist yet.
        if let personMO = fetchPerson(id: person.id) {
            
            // add person to favorites (if favorite property not set yet)
            if personMO.favorite == nil {
                let personFavorite = PersonFavoritesMO(context: coreDataStack.persistentContainer.viewContext)
                personFavorite.dateAdded = Date()
                personFavorite.person = personMO
            }
        } else {
            let personMO = updateOrCreatePerson(person: person)
            let personFavorite = PersonFavoritesMO(context: coreDataStack.persistentContainer.viewContext)
            personFavorite.dateAdded = Date()
            personFavorite.person = personMO
        }
        
        coreDataStack.saveContext()
    }
    
    private func removeMovieFromWatchlist(movie: Movie) {
        // remove from watchlist if possible, otherwise just create the movie
        if let movieMO = fetchMovie(id: movie.id) {
            
            // remove from watchlist
            if let movieWatchlist = movieMO.watchlist {
                coreDataStack.persistentContainer.viewContext.delete(movieWatchlist)
            }
            
            coreDataStack.saveContext()
        } else {
            print("** Found 0 existing entries for movie \(movie.id). Creating one now, but not creating watchlist, because it is attempting to be removed from watchlist")
            updateOrCreateMovie(movie: movie)
        }
    }
    
    private func removeTVShowFromWatchlist(tvShow: TVShow) {
        // remove from watchlist if possible, otherwise just create the tvShow
        if let tvShowMO = fetchTVShow(id: tvShow.id) {
            
            // remove from watchlist
            if let tvShowWatchlist = tvShowMO.watchlist {
                coreDataStack.persistentContainer.viewContext.delete(tvShowWatchlist)
            }
            
            coreDataStack.saveContext()
        } else {
            print("** Found 0 existing entries for tvShow \(tvShow.id). Creating one now, but not creating watchlist, because it is attempting to be removed from watchlist")
            updateOrCreateTVShow(tvShow: tvShow)
        }
    }
    
    private func removePersonFromFavorites(person: Person) {
        // remove from favorites if possible, otherwise just create the person object
        if let personMO = fetchPerson(id: person.id) {
            
            // remove from favorites
            if let personFavorite = personMO.favorite {
                coreDataStack.persistentContainer.viewContext.delete(personFavorite)
            }
            
            coreDataStack.saveContext()
        } else {
            print("** Found 0 existing entries for person \(person.id). Creating one now, but not creating favorite, because it is attempting to be removed from favorite")
            updateOrCreatePerson(person: person)
        }
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
        let moc = coreDataStack.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<TVShowWatchlistMO>(entityName: "TVShowWatchlist")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        
        do {
            let watchlistResults: [TVShowWatchlistMO] = try moc.fetch(fetchRequest)
            
            var tvShowMOs = [TVShowMO]()
            for watchlistResult in watchlistResults {
                if let tvShowMO = watchlistResult.tvShow {
                    tvShowMOs.append(tvShowMO)
                }
            }
            
            return tvShowMOs.map { TVShow(tvShowMO: $0) }
        } catch {
            print("** Failed to fetch watchlist page.")
            return []
        }
    }
    
    func fetchFavoritePeople() -> [Person] {
        let moc = coreDataStack.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<PersonFavoritesMO>(entityName: "PersonFavorites")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        
        do {
            let favoritesResults: [PersonFavoritesMO] = try moc.fetch(fetchRequest)
            
            var personMOs = [PersonMO]()
            for favoritesResult in favoritesResults {
                if let personMO = favoritesResult.person {
                    personMOs.append(personMO)
                }
            }
            
            return personMOs.map { Person(personMO: $0) }
        } catch {
            print("** Failed to fetch favorites")
            return []
        }
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
            print("** Failed to fetch guessed movies.")
            return []
        }
    }
    
    func fetchGuessedTVShows() -> [TVShow] {
        let context = coreDataStack.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<TVShowGuessedMO>(entityName: "TVShowGuessed")
        fetchRequest.fetchLimit = 100000
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        
        do {
            let guessedResults: [TVShowGuessedMO] = try context.fetch(fetchRequest)
            
            var tvShowMOs = [TVShowMO]()
            for guessed in guessedResults {
                if let tvShowMO = guessed.tvShow {
                    tvShowMOs.append(tvShowMO)
                }
            }
            
            return tvShowMOs.map { TVShow(tvShowMO: $0) }
        } catch {
            print("** Failed to fetch guessed tv shows.")
            return []
        }
    }
    
    func fetchGuessedPeople() -> [Person] {
        let context = coreDataStack.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<PersonGuessedMO>(entityName: "PersonGuessed")
        fetchRequest.fetchLimit = 100000
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        
        do {
            let guessedResults: [PersonGuessedMO] = try context.fetch(fetchRequest)
            
            var personMOs = [PersonMO]()
            for guessed in guessedResults {
                if let personMO = guessed.person {
                    personMOs.append(personMO)
                }
            }
            
            return personMOs.map { Person(personMO: $0) }
        } catch {
            print("** Failed to fetch guessed movies.")
            return []
        }
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
            print("** ERROR: Failed to fetch revealed movies")
            return []
        }
    }
    
    func fetchRevealedTVShows() -> [TVShow] {
        let context = coreDataStack.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<TVShowRevealedMO>(entityName: "TVShowRevealed")
        fetchRequest.fetchLimit = 100000
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        
        do {
            let revealedResults: [TVShowRevealedMO] = try context.fetch(fetchRequest)
            
            var tvShowMOs = [TVShowMO]()
            for revealed in revealedResults {
                if let tvShowMO = revealed.tvShow {
                    tvShowMOs.append(tvShowMO)
                }
            }
            
            return tvShowMOs.map { TVShow(tvShowMO: $0) }
        } catch {
            print("** ERROR: Failed to fetch revealed tv shows")
            return []
        }
    }
    
    func fetchRevealedPeople() -> [Person] {
        let context = coreDataStack.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<PersonRevealedMO>(entityName: "PersonRevealed")
        fetchRequest.fetchLimit = 100000
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        
        do {
            let revealedResults: [PersonRevealedMO] = try context.fetch(fetchRequest)
            
            var personMOs = [PersonMO]()
            for revealed in revealedResults {
                if let personMO = revealed.person {
                    personMOs.append(personMO)
                }
            }
            
            return personMOs.map { Person(personMO: $0) }
        } catch {
            print("** ERROR: Failed to fetch revealed people")
            return []
        }
    }
    
    
    
    
    
// MARK: -- MOVIE GENRES
    
    // should always be called after a network request is performed for this info.
    func updateOrCreateMovieGenreList(genres: [Genre]) {
        for genre in genres {
            let genreMO = fetchMovieGenre(id: genre.id) ?? {
                let genreMO = MovieGenreMO(context: coreDataStack.persistentContainer.viewContext)
                genreMO.id = Int64(genre.id)
                return genreMO
            }()
            // update existing/newly created genre managed object
            genreMO.name = genre.name
            genreMO.language = Locale.autoupdatingCurrent.identifier
            genreMO.lastUpdated = Date()
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
        
        do {
            let fetchedGenres = try moc.fetch(genreFetch)
            print("FETCHED Genres: \(fetchedGenres)")
            
            if fetchedGenres.count > 0 {
                if fetchedGenres.count > 1 {
                    print("** WARNING: fetching movie genre (id: \(id)) returned \(fetchedGenres.count) objects - should only be one.")
                }
                
                return fetchedGenres[0]
            } else {
                return nil
            }
        } catch {
            print("** Failed to fetch genre (id: \(id)): \(error)")
            return nil
        }
    }
    
    
    
    
    
// MARK: -- TV SHOW GENRES
    
    // should always be called after a network request is performed for this info.
    func updateOrCreateTVShowGenreList(genres: [Genre]) {
        for genre in genres {
            let genreMO = fetchTVShowGenre(id: genre.id) ?? {
                let genreMO = TVShowGenreMO(context: coreDataStack.persistentContainer.viewContext)
                genreMO.id = Int64(genre.id)
                return genreMO
            }()
            // update existing/newly created genre managed object
            genreMO.name = genre.name
            genreMO.language = Locale.autoupdatingCurrent.identifier
            genreMO.lastUpdated = Date()
        }
        
        coreDataStack.saveContext()
    }
    
    func fetchTVShowGenres() -> [TVShowGenre] {
        let moc = coreDataStack.persistentContainer.viewContext
        let genreFetch = NSFetchRequest<TVShowGenreMO>(entityName: "TVShowGenre")
        
        do {
            let fetched = try moc.fetch(genreFetch)
            let genreObjects = fetched.map { TVShowGenre(genreMO: $0) }
            
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
    
    func fetchTVShowGenre(id: Int) -> TVShowGenreMO? {
        let moc = coreDataStack.persistentContainer.viewContext
        let genreFetch = NSFetchRequest<TVShowGenreMO>(entityName: "TVShowGenre")
        genreFetch.predicate = NSPredicate(format: "id == %ld", id)
        
        do {
            let fetchedGenres = try moc.fetch(genreFetch)
            print("FETCHED Genres: \(fetchedGenres)")
            
            if fetchedGenres.count > 0 {
                if fetchedGenres.count > 1 {
                    print("** WARNING: fetching tv show genre (id: \(id)) returned \(fetchedGenres.count) objects - should only be one.")
                }
                
                return fetchedGenres[0]
            } else {
                return nil
            }
        } catch {
            print("** Failed to fetch genre (id: \(id)): \(error)")
            return nil
        }
    }
    
    
    

    
// MARK: -- CREDITS (NOT CURRENTLY BEING CACHED. FUNCTIONALITY CAN BE ADDED LATER IF NEEDED)
    /*
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
    */

    
    
    
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
