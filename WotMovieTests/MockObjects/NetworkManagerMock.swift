//
//  NetworkManagerMock.swift
//  WotMovieTests
//
//  Created by Griffin Storback on 2021-02-12.
//

import Foundation
@testable import WotMovie

class NetworkManagerMock: NetworkManagerProtocol {
    func getMovieGenres(completion: @escaping ([Genre]?, String?) -> ()) {
        completion([], nil)
    }
    
    func getTVShowGenres(completion: @escaping ([Genre]?, String?) -> ()) {
        completion([], nil)
    }
    
    func getJobsList(completion: @escaping ([Department]?, String?) -> Void) {
        completion([], nil)
    }
    
    func getListOfMoviesByGenre(id: Int, page: Int, completion: @escaping ([Movie]?, String?) -> ()) {
        completion([], nil)
    }
    
    func getListOfTVShowsByGenre(id: Int, page: Int, completion: @escaping ([TVShow]?, String?) -> ()) {
        completion([], nil)
    }
    
    func getPopularPeople(page: Int, completion: @escaping ([Person]?, String?) -> ()) {
        completion([], nil)
    }
    
    func getCreditsForMovie(id: Int, completion: @escaping (Credits?, String?) -> ()) {
        completion(nil, "not implemented")
    }
    
    func getCreditsForTVShow(id: Int, completion: @escaping (Credits?, String?) -> ()) {
        completion(nil, "not implemented")
    }
    
    func getPersonDetailAndCredits(id: Int, completion: @escaping (PersonCredits?, String?) -> ()) {
        completion(nil, "not implemented")
    }
    
    func getCombinedCreditsForPerson(id: Int, completion: @escaping (PersonCredits?, String?) -> ()) {
        completion(nil, "not implemented")
    }
    
    func searchMovies(searchText: String, completion: @escaping ([Movie]?, String?) -> ()) {
        completion([], nil)
    }
    
    func searchTVShows(searchText: String, completion: @escaping ([TVShow]?, String?) -> ()) {
        completion([], nil)
    }
    
    func searchPeople(searchText: String, completion: @escaping ([Person]?, String?) -> ()) {
        completion([], nil)
    }
}
