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
    // (DONT KNOW HOW THIS WOULD WORK WITHOUT SACRIFICING TYPE SAFETY) should just have two functions: perform on background, or on main thread, and pass enum value for function
    //func performOnMainThread(_ coreDataFunction: CoreDataFunction)
    //func performOnBackgroundThread(_ coreDataFunction: CoreDataFunction)
}


final class CoreDataManager: CoreDataManagerProtocol {
    
    static let shared = CoreDataManager()
    private let coreDataStack = CoreDataStack.shared
    private init() {}

    
    
// MARK: -- Background methods (don't call these from main thread)
    
    func backgroundUpdateEntityPage(category: CategoryType, page: Int, genreID: Int, entities: [Entity]) {
        guard entities.count > 0 else {
            print("** ERROR: in backgroundUpdateEntityPage in core data, while trying to update page \(page) of type \(category), entities array was empty")
            return
        }
        
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateMOC.parent = coreDataStack.persistentContainer.viewContext
        privateMOC.performAndWait {
            //do some coredata stuff, but dont carry on beyond this block, until the code
            //in this block has finished executed (sync, not async)
            
            switch category {
            case .movie:
                guard let movies = entities as? [Movie] else {
                    print("** ERROR: in backgroundUpdateEntityPage in core data (for page \(page)), category passed in was .movies, but could not convert entities to [Movie].")
                    return
                }
                updateOrCreateMoviePage(movies: movies, pageNumber: page, genreID: genreID, context: privateMOC)
            case .tvShow:
                guard let tvShows = entities as? [TVShow] else {
                    print("** ERROR: in backgroundUpdateEntityPage in core data (for page \(page)), category passed in was .tvShows, but could not convert entities to [TVShow].")
                    return
                }
                updateOrCreateTVShowPage(tvShows: tvShows, pageNumber: page, genreID: genreID, context: privateMOC)
            case .person:
                guard let people = entities as? [Person] else {
                    print("** ERROR: in backgroundUpdateEntityPage in core data (for page \(page)), category passed in was .movies, but could not convert entities to movie.")
                    return
                }
                updateOrCreatePersonPage(people: people, pageNumber: page, context: privateMOC)
            default:
                print("** ERROR: in backgroundUpdateEntityPage in core data, got bad category type (likely type .stats)")
                return
            }
            
            // probably already saved, but might as well check again.
            coreDataStack.saveContext(privateMOC)
        }
        
        // now save the main context (parent) with the changes from the private context
        coreDataStack.saveContext()
    }
    
    func backgroundUpdateOrCreateEntity(entity: Entity) {
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateMOC.parent = coreDataStack.persistentContainer.viewContext
        privateMOC.performAndWait {
            
            updateOrCreateEntity(entity: entity, context: privateMOC)
            
            // probably already saved, but might as well check again.
            coreDataStack.saveContext(privateMOC)
        }
        
        // now save the main context (parent) with the changes from the private context
        coreDataStack.saveContext()
    }
    
    func backgroundFetchEntityPage(category: CategoryType, page: Int, genreID: Int, completion: @escaping (_ entities: [Entity]?) -> Void) {
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateMOC.parent = coreDataStack.persistentContainer.viewContext
        privateMOC.perform { [weak self] in
            switch category {
            case .movie:
                completion(self?.fetchMoviePage(page, genreID, context: privateMOC))
            case .tvShow:
                completion(self?.fetchTVShowPage(page, genreID, context: privateMOC))
            case .person:
                completion(self?.fetchPersonPage(page, context: privateMOC))
            default:
                completion(nil)
            }
        }
    }
    
    func backgroundFetchListCategoryPage(listCategory: ListCategoryType, completion: @escaping (_ entities: [Entity]?) -> Void) {
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateMOC.parent = coreDataStack.persistentContainer.viewContext
        privateMOC.perform { [weak self] in
            switch listCategory {
            case .movieOrTvShowWatchlist:
                completion(self?.fetchWatchlist(genreID: -1, context: privateMOC))
            case .personFavorites:
                completion(self?.fetchFavoritePeople(context: privateMOC))
            case .allGuessed:
                completion(self?.fetchGuessedEntities(context: privateMOC))
            case .allRevealed:
                completion(self?.fetchRevealedEntities(context: privateMOC))
            }
        }
    }
    
    func backgroundFetchRecentlyViewed(limit: Int = 40, context: NSManagedObjectContext? = nil, completion: @escaping (_ entities: [Entity]?) -> Void){
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateMOC.parent = coreDataStack.persistentContainer.viewContext
        privateMOC.perform { [weak self] in
            completion(self?.fetchPageOfRecentlyViewed(limit: limit, context: privateMOC))
        }
    }
    
    
    
    
    
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
    
    // for main landing page and within Upgrade view, to show unlock progress for the .person category
    func getNumberOfGuessedAndRevealedMoviesAndTVShows() -> Int {
        let guessedAndRevealedMoviesCount = getNumberGuessedFor(category: .movie) + getNumberRevealedFor(category: .movie)
        let guessedAndRevealedTVShowsCount = getNumberGuessedFor(category: .tvShow) + getNumberRevealedFor(category: .tvShow)
        return guessedAndRevealedMoviesCount + guessedAndRevealedTVShowsCount
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
    func updateOrCreateEntity(entity: Entity, context: NSManagedObjectContext? = nil) -> Entity? {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        // if the requested entity is MovieOrTVShow type, it needs to be converted either to a TV Show or a Movie.
        if let movieOrTVShow = entity as? MovieOrTVShow {
            switch movieOrTVShow.type {
            case .movie:
                let movie = Movie(movieOrTVShow: movieOrTVShow)
                return Movie(movieMO: updateOrCreateMovie(movie: movie, context: context))
            case .tvShow:
                let tvShow = TVShow(movieOrTVShow: movieOrTVShow)
                return TVShow(tvShowMO: updateOrCreateTVShow(tvShow: tvShow, context: context))
            case .person:
                print("** WARNING: updateOrCreateEntity called on type MovieOrTVShow, but it's type was set to .person - this should NEVER happen.")
                return nil
            }
        }

        // if the requested entity is CastMember or CrewMember type, it needs to be converted to Person.
        if let castMember = entity as? CastMember {
            let person = Person(castMember: castMember)
            return Person(personMO: updateOrCreatePerson(person: person, context: context))
        }
        if let crewMember = entity as? CrewMember {
            let person = Person(crewMember: crewMember)
            return Person(personMO: updateOrCreatePerson(person: person, context: context))
        }
        
        switch entity.type {
        case .movie:
            if let movie = entity as? Movie {
                return Movie(movieMO: updateOrCreateMovie(movie: movie, context: context))
            }
        case .tvShow:
            if let tvShow = entity as? TVShow {
                return TVShow(tvShowMO: updateOrCreateTVShow(tvShow: tvShow, context: context))
            }
        case .person:
            if let person = entity as? Person {
                return Person(personMO: updateOrCreatePerson(person: person, context: context))
            }
        }
        
        return nil
    }
    
    // returns empty list if page doesnt exist. returns nil if there was an error
    func fetchEntityPage(category: CategoryType, pageNumber: Int, genreID: Int = -1, context: NSManagedObjectContext? = nil) -> [Entity]? {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        switch category {
        case .movie:
            return fetchMoviePage(pageNumber, genreID, context: context)
        case .person:
            return fetchPersonPage(pageNumber, context: context)
        case .tvShow:
            return fetchTVShowPage(pageNumber, genreID, context: context)
        default:
            // if category type was "stats", nothing to return.
            return nil
        }
    }
    
    func fetchPageOfRecentlyViewed(limit: Int = 40, context: NSManagedObjectContext? = nil) -> [Entity] {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        return fetchPageOfRecentlyViewedMovies(limit: limit, context: context) + fetchPageOfRecentlyViewedTVShows(limit: limit, context: context) + fetchPageOfRecentlyViewedPeople(limit: limit, context: context)
    }

    func addEntityToWatchlistOrFavorites(entity: Entity, context: NSManagedObjectContext? = nil) {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        switch entity.type {
        case .movie:
            if let movie = entity as? Movie {
                addMovieToWatchlist(movie: movie, context: context)
            }
        case .tvShow:
            if let tvShow = entity as? TVShow {
                addTVShowToWatchlist(tvShow: tvShow, context: context)
            }
        case .person:
            if let person = entity as? Person {
                addPersonToFavorites(person: person, context: context)
            }
        }
    }
    
    func removeEntityFromWatchlistOrFavorites(entity: Entity, context: NSManagedObjectContext? = nil) {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        switch entity.type {
        case .movie:
            if let movie = entity as? Movie {
                removeMovieFromWatchlist(movie: movie, context: context)
            }
        case .tvShow:
            if let tvShow = entity as? TVShow {
                removeTVShowFromWatchlist(tvShow: tvShow, context: context)
            }
        case .person:
            if let person = entity as? Person {
                removePersonFromFavorites(person: person, context: context)
            }
        }
    }
    
    func fetchGuessedEntities(context: NSManagedObjectContext? = nil) -> [Entity] {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        var guessedEntitiesWithDateAdded: [(entity: Entity, dateAdded: Date?)] = []
        guessedEntitiesWithDateAdded += fetchGuessedMoviesWithDateAdded(context: context)
        guessedEntitiesWithDateAdded += fetchGuessedTVShowsWithDateAdded(context: context)
        guessedEntitiesWithDateAdded += fetchGuessedPeopleWithDateAdded(context: context)
        
        guessedEntitiesWithDateAdded.sort { $0.dateAdded ?? Date.distantPast > $1.dateAdded ?? Date.distantPast }
        return guessedEntitiesWithDateAdded.map { $0.entity }
    }
    
    func fetchRevealedEntities(context: NSManagedObjectContext? = nil) -> [Entity] {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        var revealedEntitiesWithDateAdded: [(entity: Entity, dateAdded: Date?)] = []
        revealedEntitiesWithDateAdded += fetchRevealedMoviesWithDateAdded(context: context)
        revealedEntitiesWithDateAdded += fetchRevealedTVShowsWithDateAdded(context: context)
        revealedEntitiesWithDateAdded += fetchRevealedPeopleWithDateAdded(context: context)
        
        revealedEntitiesWithDateAdded.sort { $0.dateAdded ?? Date.distantPast > $1.dateAdded ?? Date.distantPast }
        return revealedEntitiesWithDateAdded.map { $0.entity }
    }
    
    
    
    
    
// MARK: -- RESET DATA
    
    func resetMovieData(context: NSManagedObjectContext? = nil) {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        print("***** RESET MOVIE DATA")
        // delete all MovieGuessed objects
        
        // delete all MovieRevealed objects
        
        // set isHintShown to false on all Movie objects
    }
    
    func resetTVShowData(context: NSManagedObjectContext? = nil) {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        print("***** RESET TV SHOW DATA")
    }
    
    func resetPersonData(context: NSManagedObjectContext? = nil) {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        print("***** RESET PERSON DATA")
    }
    
    func resetWatchlistData(context: NSManagedObjectContext? = nil) {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        print("***** RESET WATCHLIST DATA")
    }
    
    func resetFavoritesData(context: NSManagedObjectContext? = nil) {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        print("***** RESET FAVORITES DATA")
    }
    
    // warning: will reset watchlist and favorites data as well.
    func resetAllData(context: NSManagedObjectContext? = nil) {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        print("******* ALL:")
        
        resetMovieData(context: context)
        resetTVShowData(context: context)
        resetPersonData(context: context)
        
        resetWatchlistData()
        resetFavoritesData()
        
        // delete grid pages?
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
    func updateOrCreateMovie(movie: Movie, shouldSetLastViewedDate: Bool = true, context: NSManagedObjectContext? = nil) -> MovieMO {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        let movieMO = fetchMovie(id: movie.id, context: context) ?? {
            print("** UPDATE MOVIE: Movie (\(movie.name)) not found, creating new movieMO.")
            let movieMO = MovieMO(context: context)
            movieMO.id = Int64(movie.id)
            movieMO.isHintShown = movie.isHintShown
            return movieMO
        }()
            
        // update all values except 'id'
        // (in case movie overview in api has changed since last stored).
        movieMO.language = Locale.autoupdatingCurrent.identifier
        movieMO.lastUpdated = Date()
        
        movieMO.name = movie.name
        movieMO.posterImageURL = movie.posterPath
        if let popularity = movie.popularity { movieMO.popularity = popularity }
        
        movieMO.overview = movie.overview
        movieMO.releaseDate = movie.releaseDate
        if let voteAverage = movie.voteAverage { movieMO.voteAverage = voteAverage }
        movieMO.backdropImageURL = movie.backdrop
        
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
            let movieGuessedMO = MovieGuessedMO(context: context)
            movieGuessedMO.dateAdded = Date()
            movieMO.guessed = movieGuessedMO
        }
        if movie.isRevealed && movieMO.revealed == nil && movieMO.guessed == nil {
            let movieRevealedMO = MovieRevealedMO(context: context)
            movieRevealedMO.dateAdded = Date()
            movieMO.revealed = movieRevealedMO
        }
        
        // attach genre mo objects, either by fetching or by creating them.
        for genreID in movie.genreIDs {
            if let genreMO = fetchMovieGenre(id: genreID, context: context) {
                // only add genre if it doesnt already exist on movie object
                if !(movieMO.genres?.contains(genreMO) ?? false) {
                    print("** UPDATE MOVIE - adding EXISTING genreMO: \(genreMO)")
                    movieMO.addObject(value: genreMO, for: "genres")
                }
            } else {
                let genreMO = MovieGenreMO(context: context)
                genreMO.id = Int64(genreID)
                print("** UPDATE MOVIE - adding NEW genreMO: \(genreMO)")
                movieMO.addObject(value: genreMO, for: "genres")
            }
        }
        
        coreDataStack.saveContext(context)
        return movieMO
    }
    
    func fetchMovie(id: Int, context: NSManagedObjectContext? = nil) -> MovieMO? {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        let movieFetch = NSFetchRequest<MovieMO>(entityName: "Movie")
        movieFetch.predicate = NSPredicate(format: "id == %ld", id)
        movieFetch.returnsObjectsAsFaults = false
        
        do {
            let fetchedMovies = try context.fetch(movieFetch)
            
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
    func updateOrCreateTVShow(tvShow: TVShow, shouldSetLastViewedDate: Bool = true, context: NSManagedObjectContext? = nil) -> TVShowMO {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        let tvShowMO = fetchTVShow(id: tvShow.id, context: context) ?? {
            print("** UPDATE TV SHOW: NO PERSON FOUND FOR \(tvShow.name), CREATING ONE NOW")
            let tvShowMO = TVShowMO(context: context)
            tvShowMO.id = Int64(tvShow.id)
            tvShowMO.isHintShown = tvShow.isHintShown
            return tvShowMO
        }()
        
        // update all values except 'id'
        // (in case tv show in api has changed since last stored, or if user changes language).
        tvShowMO.language = Locale.autoupdatingCurrent.identifier
        tvShowMO.lastUpdated = Date()
        
        tvShowMO.name = tvShow.name
        tvShowMO.posterImageURL = tvShow.posterPath
        if let popularity = tvShow.popularity { tvShowMO.popularity = popularity}
        
        tvShowMO.overview = tvShow.overview
        tvShowMO.releaseDate = tvShow.releaseDate
        if let voteAverage = tvShow.voteAverage { tvShowMO.voteAverage = voteAverage }
        tvShowMO.backdropImageURL = tvShow.backdrop
        
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
            let tvShowGuessedMO = TVShowGuessedMO(context: context)
            tvShowGuessedMO.dateAdded = Date()
            tvShowMO.guessed = tvShowGuessedMO
        }
        if tvShow.isRevealed && tvShowMO.revealed == nil && tvShowMO.guessed == nil {
            let tvShowRevealedMO = TVShowRevealedMO(context: context)
            tvShowRevealedMO.dateAdded = Date()
            tvShowMO.revealed = tvShowRevealedMO
        }
        
        // attach genre mo objects, either by fetching or by creating them.
        for genreID in tvShow.genreIDs {
            if let genreMO = fetchTVShowGenre(id: genreID, context: context) {
                // only add genre if it doesnt already exist on tvshow object
                if !(tvShowMO.genres?.contains(genreMO) ?? false) {
                    print("** UPDATE TV SHOW - adding EXISTING genreMO: \(genreMO)")
                    tvShowMO.addObject(value: genreMO, for: "genres")
                }
            } else {
                let genreMO = TVShowGenreMO(context: context)
                genreMO.id = Int64(genreID)
                print("** UPDATE TV SHOW - adding NEW genreMO: \(genreMO)")
                tvShowMO.addObject(value: genreMO, for: "genres")
            }
        }
        
        coreDataStack.saveContext(context)
        return tvShowMO
    }
    
    func fetchTVShow(id: Int, context: NSManagedObjectContext? = nil) -> TVShowMO? {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        let tvShowFetch = NSFetchRequest<TVShowMO>(entityName: "TVShow")
        tvShowFetch.predicate = NSPredicate(format: "id == %ld", id)
        tvShowFetch.returnsObjectsAsFaults = false
        
        do {
            let fetchedTVShows = try context.fetch(tvShowFetch)
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
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        // get existing person or create new one and set its id
        let personMO = fetchPerson(id: person.id, context: context) ?? {
            print("** UPDATE PERSON: NO PERSON FOUND FOR \(person.name), CREATING ONE NOW")
            let personMO = PersonMO(context: context)
            personMO.id = Int64(person.id)
            personMO.isHintShown = person.isHintShown
            return personMO
        }()
            
        // update all values except id, in case tv show in api has changed since last stored, or if user changes language
        personMO.language = Locale.autoupdatingCurrent.identifier
        personMO.lastUpdated = Date()
        
        personMO.name = person.name
        personMO.posterImageURL = person.posterPath
        if let popularity = person.popularity { personMO.popularity = popularity }
        
        if let gender = person.gender { personMO.gender = Int16(gender) }
        personMO.knownForDepartment = person.knownForDepartment
        
        if let birthday = person.birthday { personMO.birthday = birthday }
        if let deathday = person.deathday { personMO.deathday = deathday }
        
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
            let personGuessedMO = PersonGuessedMO(context: context)
            personGuessedMO.dateAdded = Date()
            personMO.guessed = personGuessedMO
        }
        if person.isRevealed && personMO.revealed == nil && personMO.guessed == nil {
            let personRevealedMO = PersonRevealedMO(context: context)
            personRevealedMO.dateAdded = Date()
            personMO.revealed = personRevealedMO
        }
        
        // only update if not empty
        if person.knownFor.count > 0 {
            
            // fetch/create the movies in the persons knownFor array, then attach to personMO
            for title in person.knownFor {
                if title.type == .movie {
                    guard let movieOrTVShow = title as? MovieOrTVShow else { continue }
                    let movie = Movie(movieOrTVShow: movieOrTVShow)
                    let movieMO = updateOrCreateMovie(movie: movie, context: context)
                    
                    // only add movie if it doesnt already exist on personMOs knownForMovies
                    if !(personMO.knownForMovies?.contains(movieMO) ?? false) {
                        print("** UPDATE PERSON - ADDING MOVIE TO KNOWN FOR MOVIES: \(movieMO)")
                        personMO.addObject(value: movieMO, for: "knownForMovies")
                    }
                } else if title.type == .tvShow {
                    guard let movieOrTVShow = title as? MovieOrTVShow else { continue }
                    let tvShow = TVShow(movieOrTVShow: movieOrTVShow)
                    let tvShowMO = updateOrCreateTVShow(tvShow: tvShow, context: context)
                    
                    // only add tv show if it doesnt already exist on personMOs knownForTVShows
                    if !(personMO.knownForTVShows?.contains(tvShowMO) ?? false) {
                        print("** UPDATE PERSON - ADDING TV SHOW TO KNOWN FOR TVSHOWS: \(tvShowMO)")
                        personMO.addObject(value: tvShowMO, for: "knownForTVShows")
                    }
                }
            }
        }
        
        coreDataStack.saveContext(context)
        return personMO
    }
    
    func fetchPerson(id: Int, context: NSManagedObjectContext? = nil) -> PersonMO? {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        let personFetch = NSFetchRequest<PersonMO>(entityName: "Person")
        personFetch.predicate = NSPredicate(format: "id == %ld", id)
        
        do {
            let fetchedPersons = try context.fetch(personFetch)
            
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
    
    func fetchMoviePage(_ pageNumber: Int, _ genreID: Int, context: NSManagedObjectContext? = nil) -> [Movie]? {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        // fetch the movie page, then convert its movie mos to movies and return
        if let moviePageMO = fetchMoviePageMO(pageNumber, genreID, context: context) {
            return getMoviesFromMoviePageMO(moviePageMO)
        } else {
            return nil
        }
    }
    
    private func getMoviesFromMoviePageMO(_ moviePageMO: MoviePageMO) -> [Movie]? {
        guard let movieMOs = moviePageMO.movies?.allObjects as? [MovieMO] else { return nil }
        return movieMOs.map { Movie(movieMO: $0) }
    }
    
    private func fetchMoviePageMO(_ pageNumber: Int, _ genreID: Int, context: NSManagedObjectContext? = nil) -> MoviePageMO? {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        let pageFetch = NSFetchRequest<MoviePageMO>(entityName: "MoviePage")
        pageFetch.predicate = NSPredicate(format: "pageNumber == %ld && genreID == %ld", pageNumber, genreID)
        
        do {
            let fetchedPages = try context.fetch(pageFetch)
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
    func updateOrCreateMoviePage(movies: [Movie], pageNumber: Int, genreID: Int, context: NSManagedObjectContext? = nil) -> [Movie]? {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        let moviePageMO = fetchMoviePageMO(pageNumber, genreID, context: context) ?? {
            print("** UPDATE MOVIE PAGE: no movie page found for page \(pageNumber), genre \(genreID), creating one now")
            let pageMO = MoviePageMO(context: context)
            pageMO.genreID = Int64(genreID)
            pageMO.pageNumber = Int64(pageNumber)
            return pageMO
        }()
        
        moviePageMO.lastUpdated = Date()
        moviePageMO.region = Locale.autoupdatingCurrent.regionCode
        
        // replace current movies and replace with new ones
        moviePageMO.removeAllObjects(for: "movies")
        addMoviesToMoviePageMO(movies: movies, moviePageMO: moviePageMO, context: context)
        
        coreDataStack.saveContext(context)
        return getMoviesFromMoviePageMO(moviePageMO)
    }
    
    // DOESN'T SAVE CONTEXT AFTER ADDING MOVIES TO PAGE (helper function, don't call directly)
    private func addMoviesToMoviePageMO(movies: [Movie], moviePageMO: MoviePageMO, context: NSManagedObjectContext? = nil) {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        for movie in movies {
            // update or create the movie, then add it to the provided page mo
            let movieMO = updateOrCreateMovie(movie: movie, shouldSetLastViewedDate: false, context: context)
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
    
    func fetchTVShowPage(_ pageNumber: Int, _ genreID: Int, context: NSManagedObjectContext? = nil) -> [TVShow]? {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        // fetch the tv show page, then convert its tv show MOs to tv shows and return
        if let tvShowPageMO = fetchTVShowPageMO(pageNumber, genreID, context: context) {
            return getTVShowsFromTVShowPageMO(tvShowPageMO)
        } else {
            return nil
        }
    }
    
    private func getTVShowsFromTVShowPageMO(_ tvShowPageMO: TVShowPageMO) -> [TVShow]? {
        guard let tvShowMOs = tvShowPageMO.tvShows?.allObjects as? [TVShowMO] else { return nil }
        return tvShowMOs.map { TVShow(tvShowMO: $0) }
    }
    
    private func fetchTVShowPageMO(_ pageNumber: Int, _ genreID: Int, context: NSManagedObjectContext? = nil) -> TVShowPageMO? {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        let pageFetch = NSFetchRequest<TVShowPageMO>(entityName: "TVShowPage")
        pageFetch.predicate = NSPredicate(format: "pageNumber == %ld && genreID == %ld", pageNumber, genreID)
        
        do {
            let fetchedPages = try context.fetch(pageFetch)
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
    func updateOrCreateTVShowPage(tvShows: [TVShow], pageNumber: Int, genreID: Int, context: NSManagedObjectContext? = nil) -> [TVShow]? {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        let tvShowPageMO = fetchTVShowPageMO(pageNumber, genreID, context: context) ?? {
            print("** UPDATE TV SHOW PAGE: no tv show page found for page \(pageNumber), genre \(genreID), creating one now")
            let pageMO = TVShowPageMO(context: context)
            pageMO.genreID = Int64(genreID)
            pageMO.pageNumber = Int64(pageNumber)
            return pageMO
        }()
        
        tvShowPageMO.lastUpdated = Date()
        tvShowPageMO.region = Locale.autoupdatingCurrent.regionCode
        
        // reset tvShow objects in this page, if there are any, then add the ones passed in.
        tvShowPageMO.removeAllObjects(for: "tvShows")
        addTVShowsToTVShowPageMO(tvShows: tvShows, tvShowPageMO: tvShowPageMO, context: context)

        coreDataStack.saveContext(context)
        return getTVShowsFromTVShowPageMO(tvShowPageMO)
    }
    
    // DOESN'T SAVE CONTEXT AFTER ADDING TV SHOWS TO PAGE (helper function, don't call directly)
    private func addTVShowsToTVShowPageMO(tvShows: [TVShow], tvShowPageMO: TVShowPageMO, context: NSManagedObjectContext? = nil) {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        for tvShow in tvShows {
            // update or create the tv show, then add it to the provided page mo
            let tvShowMO = updateOrCreateTVShow(tvShow: tvShow, shouldSetLastViewedDate: false, context: context)
            tvShowPageMO.addObject(value: tvShowMO, for: "tvShows")
        }
    }
    
    
    
    
    
// MARK: -- GUESS GRID (PEOPLE)
    
    func fetchPersonPage(_ pageNumber: Int, context: NSManagedObjectContext? = nil) -> [Person]? {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        // fetch the person page, then convert its 'PersonMO's to 'Person's and return
        if let personPageMO = fetchPersonPageMO(pageNumber, context: context) {
            return getPeopleFromPersonPageMO(personPageMO)
        } else {
            return nil
        }
    }
    
    private func getPeopleFromPersonPageMO(_ personPageMO: PersonPageMO) -> [Person]? {
        guard let personMOs = personPageMO.people?.allObjects as? [PersonMO] else { return nil }
        return personMOs.map { Person(personMO: $0) }
    }
    
    private func fetchPersonPageMO(_ pageNumber: Int, context: NSManagedObjectContext? = nil) -> PersonPageMO? {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        let pageFetch = NSFetchRequest<PersonPageMO>(entityName: "PersonPage")
        pageFetch.predicate = NSPredicate(format: "pageNumber == %ld", pageNumber)
        
        do {
            let fetchedPages = try context.fetch(pageFetch)
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
    func updateOrCreatePersonPage(people: [Person], pageNumber: Int, context: NSManagedObjectContext? = nil) -> [Person]? {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        let personPageMO = fetchPersonPageMO(pageNumber, context: context) ?? {
            print("** UPDATE PERSON PAGE: no person page found for page \(pageNumber), creating one now")
            let pageMO = PersonPageMO(context: context)
            pageMO.pageNumber = Int64(pageNumber)
            return pageMO
        }()
        
        personPageMO.lastUpdated = Date()
        personPageMO.region = Locale.autoupdatingCurrent.regionCode
        
        // reset person objects in this page, if there are any, then add the ones passed in.
        personPageMO.removeAllObjects(for: "people")
        addPeopleToPersonPageMO(people: people, personPageMO: personPageMO, context: context)

        coreDataStack.saveContext(context)
        return getPeopleFromPersonPageMO(personPageMO)
    }
    
    // DOESN'T SAVE CONTEXT AFTER ADDING PEOPLE TO PAGE (helper function, don't call directly)
    private func addPeopleToPersonPageMO(people: [Person], personPageMO: PersonPageMO, context: NSManagedObjectContext? = nil) {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        for person in people {
            // update or create the person, then add it to the provided page mo
            let personMO = updateOrCreatePerson(person: person, shouldSetLastViewedDate: false, context: context)
            personPageMO.addObject(value: personMO, for: "people")
        }
    }
    
    
    
    
    
// MARK: -- RECENTLY VIEWED
    
    func fetchPageOfRecentlyViewedMovies(limit: Int = 40, context: NSManagedObjectContext? = nil) -> [Movie] {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<MovieMO>(entityName: "Movie")
        fetchRequest.fetchLimit = limit
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastViewedDate", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "revealed != nil || guessed != nil")
        
        do {
            let fetchedMovies: [MovieMO] = try context.fetch(fetchRequest)
            return fetchedMovies.map { Movie(movieMO: $0) }
        } catch {
            print("** Failed to fetch recently viewed.")
            return []
        }
    }
    
    func fetchPageOfRecentlyViewedTVShows(limit: Int = 40, context: NSManagedObjectContext? = nil) -> [TVShow] {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<TVShowMO>(entityName: "TVShow")
        fetchRequest.fetchLimit = limit
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastViewedDate", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "revealed != nil || guessed != nil")
        
        do {
            let fetchedTVShows: [TVShowMO] = try context.fetch(fetchRequest)
            return fetchedTVShows.map { TVShow(tvShowMO: $0) }
        } catch {
            print("** Failed to fetch recently viewed.")
            return []
        }
    }
    
    func fetchPageOfRecentlyViewedPeople(limit: Int = 40, context: NSManagedObjectContext? = nil) -> [Person] {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<PersonMO>(entityName: "Person")
        fetchRequest.fetchLimit = limit
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastViewedDate", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "revealed != nil || guessed != nil")
        
        do {
            let fetchedPeople: [PersonMO] = try context.fetch(fetchRequest)
            return fetchedPeople.map { Person(personMO: $0) }
        } catch {
            print("** Failed to fetch recently viewed.")
            return []
        }
    }
    
    

    
    
// MARK: -- WATCHLIST & FAVORITES
    
    private func addMovieToWatchlist(movie: Movie, context: NSManagedObjectContext? = nil) {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        // create movie if it doesnt exist yet.
        if let movieMO = fetchMovie(id: movie.id, context: context) {
            
            // add movie to watchlist (if watchlist prop doesnt exist yet)
            if movieMO.watchlist == nil {
                let movieWatchlistItem = MovieWatchlistMO(context: coreDataStack.persistentContainer.viewContext)
                movieWatchlistItem.dateAdded = Date()
                movieWatchlistItem.movie = movieMO
            }
        } else {
            let movieMO = updateOrCreateMovie(movie: movie, context: context)
            let movieWatchlistItem = MovieWatchlistMO(context: coreDataStack.persistentContainer.viewContext)
            movieWatchlistItem.dateAdded = Date()
            movieWatchlistItem.movie = movieMO
        }
        
        coreDataStack.saveContext(context)
    }
    
    private func addTVShowToWatchlist(tvShow: TVShow, context: NSManagedObjectContext? = nil) {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        // create tv show if it doesnt exist yet.
        if let tvShowMO = fetchTVShow(id: tvShow.id, context: context) {
            
            // add movie to watchlist (if watchlist prop doesnt exist yet)
            if tvShowMO.watchlist == nil {
                let tvShowWatchlistItem = TVShowWatchlistMO(context: coreDataStack.persistentContainer.viewContext)
                tvShowWatchlistItem.dateAdded = Date()
                tvShowWatchlistItem.tvShow = tvShowMO
            }
        } else {
            let tvShowMO = updateOrCreateTVShow(tvShow: tvShow, context: context)
            let tvShowWatchlistItem = TVShowWatchlistMO(context: coreDataStack.persistentContainer.viewContext)
            tvShowWatchlistItem.dateAdded = Date()
            tvShowWatchlistItem.tvShow = tvShowMO
        }
        
        coreDataStack.saveContext(context)
    }
    
    private func addPersonToFavorites(person: Person, context: NSManagedObjectContext? = nil) {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        // create person if it doesnt exist yet.
        if let personMO = fetchPerson(id: person.id, context: context) {
            
            // add person to favorites (if favorite property not set yet)
            if personMO.favorite == nil {
                let personFavorite = PersonFavoritesMO(context: coreDataStack.persistentContainer.viewContext)
                personFavorite.dateAdded = Date()
                personFavorite.person = personMO
            }
        } else {
            let personMO = updateOrCreatePerson(person: person, context: context)
            let personFavorite = PersonFavoritesMO(context: coreDataStack.persistentContainer.viewContext)
            personFavorite.dateAdded = Date()
            personFavorite.person = personMO
        }
        
        coreDataStack.saveContext(context)
    }
    
    private func removeMovieFromWatchlist(movie: Movie, context: NSManagedObjectContext? = nil) {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        // remove from watchlist if possible, otherwise just create the movie
        if let movieMO = fetchMovie(id: movie.id, context: context) {
            
            // remove from watchlist
            if let movieWatchlist = movieMO.watchlist {
                context.delete(movieWatchlist)
            }
            
        } else {
            print("** Found 0 existing entries for movie \(movie.id). Creating one now, but not creating watchlist, because it is attempting to be removed from watchlist")
            updateOrCreateMovie(movie: movie, context: context)
        }
    }
    
    private func removeTVShowFromWatchlist(tvShow: TVShow, context: NSManagedObjectContext? = nil) {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        // remove from watchlist if possible, otherwise just create the tvShow
        if let tvShowMO = fetchTVShow(id: tvShow.id, context: context) {
            
            // remove from watchlist
            if let tvShowWatchlist = tvShowMO.watchlist {
                context.delete(tvShowWatchlist)
            }
            
        } else {
            print("** Found 0 existing entries for tvShow \(tvShow.id). Creating one now, but not creating watchlist, because it is attempting to be removed from watchlist")
            updateOrCreateTVShow(tvShow: tvShow, context: context)
        }
    }
    
    private func removePersonFromFavorites(person: Person, context: NSManagedObjectContext? = nil) {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        // remove from favorites if possible, otherwise just create the person object
        if let personMO = fetchPerson(id: person.id, context: context) {
            
            // remove from favorites
            if let personFavorite = personMO.favorite {
                context.delete(personFavorite)
            }
            
        } else {
            print("** Found 0 existing entries for person \(person.id). Creating one now, but not creating favorite, because it is attempting to be removed from favorite")
            updateOrCreatePerson(person: person, context: context)
        }
    }
    
    // 1,200,000 took 21 seconds to retrieve - 12,000 took 0.21 seconds, which is barely acceptable (simulator)
    // real device: 20,000 took 0.61 seconds. This is all on main thread.
    func fetchWatchlist(genreID: Int, context: NSManagedObjectContext? = nil) -> [Entity] {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        var watchlistEntitiesSortedByDateAdded: [(entity: Entity, dateAdded: Date?)] = []
        watchlistEntitiesSortedByDateAdded += fetchMovieWatchlistEntitiesWithDateAdded(genreID: genreID, context: context)
        watchlistEntitiesSortedByDateAdded += fetchTVShowWatchlistEntitiesWithDateAdded(genreID: genreID, context: context)
        
        /*let start = CFAbsoluteTimeGetCurrent()
        for _ in 0..<10000 {
            watchlistEntitiesSortedByDateAdded += fetchTVShowWatchlistEntitiesWithDateAdded(genreID: genreID)
        }*/
        
        watchlistEntitiesSortedByDateAdded.sort { $0.dateAdded ?? Date.distantPast > $1.dateAdded ?? Date.distantPast }
        //let finish = CFAbsoluteTimeGetCurrent()
        //print("**** TOTAL TIME TO RETRIEVE \(watchlistEntitiesSortedByDateAdded.count) ITEMS: \(finish - start)")
        return watchlistEntitiesSortedByDateAdded.map { $0.entity }
    }
    
    func fetchMovieWatchlistEntitiesWithDateAdded(genreID: Int, context: NSManagedObjectContext? = nil) -> [(entity: Movie, dateAdded: Date?)] {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<MovieWatchlistMO>(entityName: "MovieWatchlist")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        
        do {
            let watchlistResults: [MovieWatchlistMO] = try context.fetch(fetchRequest)
            
            var movieAndDates = [(entity: Movie, dateAdded: Date?)]()
            for watchlistResult in watchlistResults {
                if let movieMO = watchlistResult.movie {
                    movieAndDates.append( (entity: Movie(movieMO: movieMO), dateAdded: watchlistResult.dateAdded) )
                }
            }
            
            return movieAndDates
        } catch {
            print("** Failed to fetch watchlist page.")
            return []
        }
    }
    
    func fetchTVShowWatchlistEntitiesWithDateAdded(genreID: Int, context: NSManagedObjectContext? = nil) -> [(entity: TVShow, dateAdded: Date?)] {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<TVShowWatchlistMO>(entityName: "TVShowWatchlist")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        
        do {
            let watchlistResults: [TVShowWatchlistMO] = try context.fetch(fetchRequest)
            
            var tvShowAndDates = [(entity: TVShow, dateAdded: Date?)]()
            for watchlistResult in watchlistResults {
                if let tvShowMO = watchlistResult.tvShow {
                    tvShowAndDates.append( (entity: TVShow(tvShowMO: tvShowMO), dateAdded: watchlistResult.dateAdded) )
                }
            }
            
            return tvShowAndDates
        } catch {
            print("** Failed to fetch watchlist page.")
            return []
        }
    }
    
    func fetchFavoritePeople(context: NSManagedObjectContext? = nil) -> [Person] {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<PersonFavoritesMO>(entityName: "PersonFavorites")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        
        do {
            let favoritesResults: [PersonFavoritesMO] = try context.fetch(fetchRequest)
            
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
    
    func fetchGuessedMoviesWithDateAdded(context: NSManagedObjectContext? = nil) -> [(entity: Movie, dateAdded: Date?)] {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<MovieGuessedMO>(entityName: "MovieGuessed")
        fetchRequest.fetchLimit = 100000
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        
        do {
            let guessedResults: [MovieGuessedMO] = try context.fetch(fetchRequest)
            
            var movieAndDates = [(entity: Movie, dateAdded: Date?)]()
            for guessed in guessedResults {
                if let movieMO = guessed.movie {
                    movieAndDates.append( (entity: Movie(movieMO: movieMO), dateAdded: guessed.dateAdded) )
                }
            }
            
            return movieAndDates
        } catch {
            print("** Failed to fetch guessed movies.")
            return []
        }
    }
    
    func fetchGuessedTVShowsWithDateAdded(context: NSManagedObjectContext? = nil) -> [(entity: TVShow, dateAdded: Date?)] {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<TVShowGuessedMO>(entityName: "TVShowGuessed")
        fetchRequest.fetchLimit = 100000
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        
        do {
            let guessedResults: [TVShowGuessedMO] = try context.fetch(fetchRequest)
            
            var tvShowAndDates = [(entity: TVShow, dateAdded: Date?)]()
            for guessed in guessedResults {
                if let tvShowMO = guessed.tvShow {
                    tvShowAndDates.append( (entity: TVShow(tvShowMO: tvShowMO), dateAdded: guessed.dateAdded) )
                }
            }
            
            return tvShowAndDates
        } catch {
            print("** Failed to fetch guessed tv shows.")
            return []
        }
    }
    
    func fetchGuessedPeopleWithDateAdded(context: NSManagedObjectContext? = nil) -> [(entity: Person, dateAdded: Date?)] {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<PersonGuessedMO>(entityName: "PersonGuessed")
        fetchRequest.fetchLimit = 100000
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        
        do {
            let guessedResults: [PersonGuessedMO] = try context.fetch(fetchRequest)
            
            var personAndDates = [(entity: Person, dateAdded: Date?)]()
            for guessed in guessedResults {
                if let personMO = guessed.person {
                    personAndDates.append( (entity: Person(personMO: personMO), dateAdded: guessed.dateAdded) )
                }
            }
            
            return personAndDates
        } catch {
            print("** Failed to fetch guessed movies.")
            return []
        }
    }
    
    
    
    
    
// MARK: -- REVEALED
    
    func fetchRevealedMoviesWithDateAdded(context: NSManagedObjectContext? = nil) -> [(entity: Movie, dateAdded: Date?)] {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<MovieRevealedMO>(entityName: "MovieRevealed")
        fetchRequest.fetchLimit = 100000
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        
        do {
            let revealedResults: [MovieRevealedMO] = try context.fetch(fetchRequest)
            
            var movieAndDates = [(entity: Movie, dateAdded: Date?)]()
            for revealed in revealedResults {
                if let movieMO = revealed.movie {
                    movieAndDates.append( (entity: Movie(movieMO: movieMO), dateAdded: revealed.dateAdded) )
                }
            }
            
            return movieAndDates
        } catch {
            print("** ERROR: Failed to fetch revealed movies")
            return []
        }
    }
    
    func fetchRevealedTVShowsWithDateAdded(context: NSManagedObjectContext? = nil) -> [(entity: TVShow, dateAdded: Date?)] {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<TVShowRevealedMO>(entityName: "TVShowRevealed")
        fetchRequest.fetchLimit = 100000
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        
        do {
            let revealedResults: [TVShowRevealedMO] = try context.fetch(fetchRequest)
            
            var tvShowAndDates = [(entity: TVShow, dateAdded: Date?)]()
            for revealed in revealedResults {
                if let tvShowMO = revealed.tvShow {
                    tvShowAndDates.append( (entity: TVShow(tvShowMO: tvShowMO), dateAdded: revealed.dateAdded) )
                }
            }
            
            return tvShowAndDates
        } catch {
            print("** ERROR: Failed to fetch revealed tv shows")
            return []
        }
    }
    
    func fetchRevealedPeopleWithDateAdded(context: NSManagedObjectContext? = nil) -> [(entity: Person, dateAdded: Date?)] {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<PersonRevealedMO>(entityName: "PersonRevealed")
        fetchRequest.fetchLimit = 100000
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        
        do {
            let revealedResults: [PersonRevealedMO] = try context.fetch(fetchRequest)
            
            var personAndDates = [(entity: Person, dateAdded: Date?)]()
            for revealed in revealedResults {
                if let personMO = revealed.person {
                    personAndDates.append( (entity: Person(personMO: personMO), dateAdded: revealed.dateAdded) )
                }
            }
            
            return personAndDates
        } catch {
            print("** ERROR: Failed to fetch revealed people")
            return []
        }
    }
    
    
    
    
    
// MARK: -- MOVIE GENRES
    
    // should always be called after a network request is performed for this info.
    func updateOrCreateMovieGenreList(genres: [Genre], context: NSManagedObjectContext? = nil) {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        for genre in genres {
            let genreMO = fetchMovieGenre(id: genre.id, context: context) ?? {
                let genreMO = MovieGenreMO(context: context)
                genreMO.id = Int64(genre.id)
                return genreMO
            }()
            // update existing/newly created genre managed object
            genreMO.name = genre.name
            genreMO.language = Locale.autoupdatingCurrent.identifier
            genreMO.lastUpdated = Date()
        }
        
        coreDataStack.saveContext(context)
    }
    
    func fetchMovieGenres(context: NSManagedObjectContext? = nil) -> [MovieGenre] {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        let genreFetch = NSFetchRequest<MovieGenreMO>(entityName: "MovieGenre")
        
        do {
            let fetched = try context.fetch(genreFetch)
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
    
    func fetchMovieGenre(id: Int, context: NSManagedObjectContext? = nil) -> MovieGenreMO? {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        let genreFetch = NSFetchRequest<MovieGenreMO>(entityName: "MovieGenre")
        genreFetch.predicate = NSPredicate(format: "id == %ld", id)
        
        do {
            let fetchedGenres = try context.fetch(genreFetch)
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
    func updateOrCreateTVShowGenreList(genres: [Genre], context: NSManagedObjectContext? = nil) {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        for genre in genres {
            let genreMO = fetchTVShowGenre(id: genre.id, context: context) ?? {
                let genreMO = TVShowGenreMO(context: context)
                genreMO.id = Int64(genre.id)
                return genreMO
            }()
            // update existing/newly created genre managed object
            genreMO.name = genre.name
            genreMO.language = Locale.autoupdatingCurrent.identifier
            genreMO.lastUpdated = Date()
        }
        
        coreDataStack.saveContext(context)
    }
    
    func fetchTVShowGenres(context: NSManagedObjectContext? = nil) -> [TVShowGenre] {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        let genreFetch = NSFetchRequest<TVShowGenreMO>(entityName: "TVShowGenre")
        
        do {
            let fetched = try context.fetch(genreFetch)
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
    
    func fetchTVShowGenre(id: Int, context: NSManagedObjectContext? = nil) -> TVShowGenreMO? {
        let context = context ?? coreDataStack.persistentContainer.viewContext
        
        let genreFetch = NSFetchRequest<TVShowGenreMO>(entityName: "TVShowGenre")
        genreFetch.predicate = NSPredicate(format: "id == %ld", id)
        
        do {
            let fetchedGenres = try context.fetch(genreFetch)
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
