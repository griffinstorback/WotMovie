//
//  CoreDataManager.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-11-02.
//

import Foundation
import CoreData
import UIKit

final class CoreDataManager {
    
    static let shared = CoreDataManager()
    private let coreDataStack = CoreDataStack.shared
    private init() {}
    
    func updateOrCreateMovieEntity(movie: Movie) {
        let existingMovieEntries = readMovie(id: movie.id)
        
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
            
            coreDataStack.saveContext()
        } else {
            print("** Found 0 existing entries for movie \(movie.id). Creating one now.")
            createMovieEntityFrom(movie: movie)
        }
    }
    
    func createMovieEntityFrom(movie: Movie) {
        let movieMO = MovieMO(context: coreDataStack.persistentContainer.viewContext)
        
        movieMO.id = Int64(movie.id)
        movieMO.isRevealed = false
        movieMO.isHintShown = false
        
        movieMO.lastUpdated = Date()
        movieMO.lastViewedDate = Date()
        movieMO.name = movie.name
        movieMO.overview = movie.overview
        movieMO.posterImageURL = movie.posterPath
        movieMO.releaseDate = movie.releaseDate
        
        coreDataStack.saveContext()
    }
    
    func readMovie(id: Int) -> [MovieMO] {
        let moc = coreDataStack.persistentContainer.viewContext
        let movieFetch = NSFetchRequest<MovieMO>(entityName: "Movie")
        movieFetch.predicate = NSPredicate(format: "id == %ld", id)
        movieFetch.returnsObjectsAsFaults = false
        
        do {
            let fetchedMovies = try moc.fetch(movieFetch)
            print("FETCHED MOVIES: \(fetchedMovies)")
            return fetchedMovies
        } catch {
            fatalError("Failed to fetch movie: \(error)")
            //return []
        }
    }
    
    func createPageEntityFrom(movieApiResponse: MovieApiResponse) {
        let privateContext = coreDataStack.persistentContainer.newBackgroundContext()
        let pageMO = MoviePageMO(context: privateContext)
        pageMO.numberAdded = Int64(movieApiResponse.page)
        
        // create movieMO for each of the apiResponses movies, if they don't already exist
        for movie in movieApiResponse.movies {
            let movieMO = MovieMO(context: privateContext)
            movieMO.id = Int64(movie.id)
            
            // pageMO.movies.append(movieMO)
        }
        
        try? privateContext.save()
    }
    
    // either create this movie/tv show/person, or just update with current date.
    func setEntityAsSeen(entity: Entity) {
        if let movie = entity as? Movie {
            updateOrCreateMovieEntity(movie: movie)
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
