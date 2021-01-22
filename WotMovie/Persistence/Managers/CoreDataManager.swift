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

final class CoreDataManager {
    
    static let shared = CoreDataManager()
    private let coreDataStack = CoreDataStack.shared
    private init() {}
    
    func getNumberGuessedFor(category: CategoryType) -> Int {
        let context = coreDataStack.persistentContainer.viewContext
        
        switch(category) {
        case .movie:
            let movieFetch = NSFetchRequest<MovieMO>(entityName: "Movie")
            movieFetch.predicate = NSPredicate(format: "correctlyGuessed == %@", NSNumber(value: true))
            
            do {
                let fetchedMoviesCount = try context.count(for: movieFetch)
                return fetchedMoviesCount
            } catch {
                print("** Failed to fetch movie count: \(error)")
                return -1
            }
        case .person:
            return 0
        case .tvShow:
            return 1
        default:
            return 0
        }
    }
    
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
            
            // only set as correctly guessed if it wasnt previously revealed.
            if movie.correctlyGuessed && !movieMO.isRevealed {
                movieMO.isRevealed = true
                movieMO.correctlyGuessed = true
            }
            if movie.isHintShown {
                movieMO.isHintShown = true
            }
            if movie.isRevealed {
                movieMO.isRevealed = true
            }
            
            // attach genre mo objects, either by fetching or by creating them.
            for genreID in movie.genreIDs {
                if let genreMO = fetchGenre(id: genreID) {
                    // only add genre if it doesnt already exist on movie object
                    if !(movieMO.genres?.contains(genreMO) ?? false) {
                        print("** UPDATE MOVIE - adding EXISTING genreMO: \(genreMO)")
                        movieMO.addObject(value: genreMO, for: "genres")
                    }
                } else {
                    let genreMO = GenreMO(context: coreDataStack.persistentContainer.viewContext)
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
    func createMovie(movie: Movie) -> MovieMO {
        let movieMO = MovieMO(context: coreDataStack.persistentContainer.viewContext)
        
        movieMO.id = Int64(movie.id)
        movieMO.isRevealed = movie.isRevealed
        movieMO.isHintShown = movie.isHintShown
        movieMO.correctlyGuessed = movie.correctlyGuessed
        
        movieMO.lastUpdated = Date()
        movieMO.lastViewedDate = Date()
        movieMO.name = movie.name
        movieMO.overview = movie.overview
        movieMO.posterImageURL = movie.posterPath
        movieMO.releaseDate = movie.releaseDate
        
        // attach genre mo objects, either by fetching or by creating them.
        for genreID in movie.genreIDs {
            if let genreMO = fetchGenre(id: genreID) {
                genreMO.addObject(value: movieMO, for: "movies")
                print("** CREATED MOVIE - adding EXISTING genreMO: \(genreMO)")
                //movieMO.addObject(value: genreMO, for: "genres")
            } else {
                let genreMO = GenreMO(context: coreDataStack.persistentContainer.viewContext)
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
    
    // returns empty list if page doesnt exist. returns nil if there was an error
    func fetchEntityPage(type: CategoryType, pageNumber: Int, genreID: Int) -> [Entity]? {
        let moc = coreDataStack.persistentContainer.viewContext
        
        if type == .movie {
            let pageFetch = NSFetchRequest<MoviePageMO>(entityName: "MoviePage")
            pageFetch.predicate = NSPredicate(format: "pageNumber == %ld && genreID == %ld", pageNumber, genreID)
            
            do {
                let fetchedPages = try moc.fetch(pageFetch)
                guard fetchedPages.count > 0 else { return [] }
                guard let movieMOs = fetchedPages[0].movies?.allObjects as? [MovieMO] else { return nil }
                
                return movieMOs.map { Movie(movieMO: $0) }
            } catch {
                print("** Failed to fetch movie page: \(error)")
                return nil
            }
        } else if type == .person {
            // TODO
        } else if type == .tvShow {
            // TODO
        }
        
        return nil
    }
    
    func createMoviePage(movies: [Movie], pageNumber: Int, genreID: Int) {
        let moc = coreDataStack.persistentContainer.viewContext
        let pageMO = MoviePageMO(context: moc)
        pageMO.genreID = Int64(genreID)
        pageMO.pageNumber = Int64(pageNumber)
        pageMO.lastUpdated = Date()
        
        print("** in createmoviepage, about to add each movie")
        
        // create movieMO for each of the apiResponses movies, if they don't already exist
        for movie in movies {
            
            // first check if movie already in core data
            let existingMovies = fetchMovie(id: movie.id)
            if existingMovies.count > 0 {
                pageMO.addObject(value: existingMovies[0], for: "movies")
            } else {
                // none found, create a new movieMO object
                let newMovie = createMovie(movie: movie)
                pageMO.addObject(value: newMovie, for: "movies")
            }
        }
        
        print("** added movies to core data movie page. (\(movies.count) of them)")
        
        try? moc.save()
        
        print("** pageMO after calling moc.save(): \(pageMO)")
        //coreDataStack.saveContext()
    }
    
    // either create this movie/tv show/person, or just update with current date.
    func setEntityAsSeen(entity: Entity) {
        if let movie = entity as? Movie {
            updateOrCreateMovie(movie: movie)
        }
    }
    
    func setEntityAsFavorite(entity: Entity) {
        if let movie = entity as? Movie {
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
    }
    
    func removeEntityFromFavorites(entity: Entity) {
        if let movie = entity as? Movie {
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
    }
    
    // should always be called after a network request is performed for this info.
    func updateOrCreateGenreList(genres: [Genre]) {
        for genre in genres {
            if let genreMO = fetchGenre(id: genre.id) {
                // update existing genre managed object
                genreMO.name = genre.name
                genreMO.lastUpdated = Date()
            } else {
                // create a genre for this id
                let genreMO = GenreMO(context: coreDataStack.persistentContainer.viewContext)
                genreMO.id = Int64(genre.id)
                genreMO.name = genre.name
                genreMO.lastUpdated = Date()
            }
        }
        
        coreDataStack.saveContext()
    }
    
    func fetchGenres() -> [Genre] {
        let moc = coreDataStack.persistentContainer.viewContext
        let genreFetch = NSFetchRequest<GenreMO>(entityName: "Genre")
        
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

    
    // MARK:- HELPER; PRIVATE METHODS
    
    func fetchGenre(id: Int) -> GenreMO? {
        let moc = coreDataStack.persistentContainer.viewContext
        let genreFetch = NSFetchRequest<GenreMO>(entityName: "Genre")
        genreFetch.predicate = NSPredicate(format: "id == %ld", id)
        
        let fetchedGenres: [GenreMO]
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
            print("Detele all data in \(entity) error :", error)
        }
    }
}
