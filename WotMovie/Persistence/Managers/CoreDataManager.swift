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
    
    func createMovieEntityFrom(movie: Movie) {
        let privateContext = coreDataStack.persistentContainer.newBackgroundContext()
        let movieMO = MovieMO(context: privateContext)
        movieMO.id = Int64(movie.id)
        
        try? privateContext.save()
    }
    
    func createPageEntityFrom(movieApiResponse: MovieApiResponse) {
        let privateContext = coreDataStack.persistentContainer.newBackgroundContext()
        let pageMO = PageMO(context: privateContext)
        pageMO.number = Int64(movieApiResponse.page)
        
        // create movieMO for each of the apiResponses movies, if they don't already exist
        for movie in movieApiResponse.movies {
            let movieMO = MovieMO(context: privateContext)
            movieMO.id = Int64(movie.id)
            
            // pageMO.movies.append(movieMO)
        }
        
        try? privateContext.save()
    }
}
