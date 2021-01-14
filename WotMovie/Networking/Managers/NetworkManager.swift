//
//  NetworkManager.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-07.
//

import Foundation

protocol NetworkManagerProtocol {
    // think about changing closure to be (Result<[Genre], NetworkError>) -> ()
    func getMovieGenres(completion: @escaping (_ genres: [Genre]?, _ error: String?) -> ())
    func getTVShowGenres(completion: @escaping (_ genres: [Genre]?, _ error: String?) -> ())
    func getJobsList(completion: @escaping (_ departments: [Department]?, _ error: String?) -> Void)
    func getListOfMoviesByGenre(id: Int, page: Int, completion: @escaping (_ movies: [Movie]?, _ error: String?) -> ())
    func getListOfTVShowsByGenre(id: Int, page: Int, completion: @escaping (_ tvShows: [TVShow]?, _ error: String?) -> ())
    func getPopularPeople(page: Int, completion: @escaping (_ people: [Person]?, _ error: String?) -> ())
    func getCreditsForMovie(id: Int, completion: @escaping (_ credits: Credits?, _ error: String?) -> ())
    func getCreditsForTVShow(id: Int, completion: @escaping (_ credits: Credits?, _ error: String?) -> ())
    func getPersonDetailAndCredits(id: Int, completion: @escaping (_ credits: PersonCredits?, _ error: String?) -> ())
    func getCombinedCreditsForPerson(id: Int, completion: @escaping (_ credits: PersonCredits?, _ error: String?) -> ())
    func searchMovies(searchText: String, completion: @escaping (_ movies: [Movie]?, _ error: String?) -> ())
    func searchTVShows(searchText: String, completion: @escaping (_ tvShows: [TVShow]?, _ error: String?) -> ())
    func searchPeople(searchText: String, completion: @escaping (_ people: [Person]?, _ error: String?) -> ())
}

final class NetworkManager: NetworkManagerProtocol {
    
    static let shared = NetworkManager()
    private init() {}
    
    static let environment: NetworkEnvironment = .production
    static let MovieAPIKey = "3a71a701782ff20157039d47ddd62df9"
    
    private let movieRouter = Router<MovieApi>()
    private let personRouter = Router<PersonApi>()
    
    // get list of newest movies
    // ---NOT BEING USED---
    public func getNewMovies(page: Int, completion: @escaping (_ movies: [Movie]?, _ error: String?) -> ()) {
        movieRouter.request(.newMovies(page: page)) { data, response, error in
            if error != nil {
                completion(nil, NetworkResponse.checkNetworkConnection.rawValue)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = NetworkResponse.handleNetworkResponse(response)
                
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        print("** responseData:")
                        print(responseData)
                        let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        print("** jsonData:")
                        print(jsonData)
                        let apiResponse = try JSONDecoder().decode(MovieApiResponse.self, from: responseData)
                        print("** apiResponse:")
                        print(apiResponse)
                        
                        // success
                        completion(apiResponse.movies, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    print(networkFailureError)
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    public func getMovieGenres(completion: @escaping (_ genres: [Genre]?, _ error: String?) -> ()) {
        movieRouter.request(.movieGenres) { data, response, error in
            if error != nil {
                completion(nil, NetworkResponse.checkNetworkConnection.rawValue)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = NetworkResponse.handleNetworkResponse(response)
                
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        //let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        let apiResponse = try JSONDecoder().decode(MovieGenreApiResponse.self, from: responseData)
                        completion(apiResponse.genres, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    print(networkFailureError)
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    public func getTVShowGenres(completion: @escaping (_ genres: [Genre]?, _ error: String?) -> ()) {
        movieRouter.request(.tvShowGenres) { data, response, error in
            if error != nil {
                completion(nil, NetworkResponse.checkNetworkConnection.rawValue)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = NetworkResponse.handleNetworkResponse(response)
                
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        //let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        let apiResponse = try JSONDecoder().decode(TVShowGenreApiResponse.self, from: responseData)
                        completion(apiResponse.genres, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    print(networkFailureError)
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    public func getJobsList(completion: @escaping (_ departments: [Department]?, _ error: String?) -> Void) {
        movieRouter.request(.jobs) { data, response, error in
            if error != nil {
                completion(nil, NetworkResponse.checkNetworkConnection.rawValue)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = NetworkResponse.handleNetworkResponse(response)
                
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        //let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        let apiResponse = try JSONDecoder().decode([Department].self, from: responseData)
                        completion(apiResponse, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    print(networkFailureError)
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    public func getListOfMoviesByGenre(id: Int, page: Int, completion: @escaping (_ movies: [Movie]?, _ error: String?) -> ()) {
        
        // check if cache contains a Page(genreID, page). 
        
        movieRouter.request(.discoverMoviesByGenre(id: id, page: page)) { data, response, error in
            if error != nil {
                completion(nil, NetworkResponse.checkNetworkConnection.rawValue)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = NetworkResponse.handleNetworkResponse(response)
                
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        print(jsonData)
                        let apiResponse = try JSONDecoder().decode(MovieApiResponse.self, from: responseData)
                        completion(apiResponse.movies, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    print(networkFailureError)
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    public func getListOfTVShowsByGenre(id: Int, page: Int, completion: @escaping (_ tvShows: [TVShow]?, _ error: String?) -> ()) {
        movieRouter.request(.discoverTVShowsByGenre(id: id, page: page)) { data, response, error in
            if error != nil {
                completion(nil, NetworkResponse.checkNetworkConnection.rawValue)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = NetworkResponse.handleNetworkResponse(response)
                
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        print(jsonData)
                        let apiResponse = try JSONDecoder().decode(TVShowApiResponse.self, from: responseData)
                        completion(apiResponse.tvShows, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    print(networkFailureError)
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    public func getPopularPeople(page: Int, completion: @escaping (_ people: [Person]?, _ error: String?) -> ()) {
        personRouter.request(.popularPeople(page: page)) { data, response, error in
            if error != nil {
                completion(nil, NetworkResponse.checkNetworkConnection.rawValue)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = NetworkResponse.handleNetworkResponse(response)
                
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        print(jsonData)
                        let apiResponse = try JSONDecoder().decode(PersonApiResponse.self, from: responseData)
                        completion(apiResponse.people, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    print(networkFailureError)
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    public func getCreditsForMovie(id: Int, completion: @escaping (_ credits: Credits?, _ error: String?) -> ()) {
        movieRouter.request(.movieCredits(id: id)) { data, response, error in
            if error != nil {
                completion(nil, NetworkResponse.checkNetworkConnection.rawValue)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = NetworkResponse.handleNetworkResponse(response)
                
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        //let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        //print(jsonData)
                        let apiResponse = try JSONDecoder().decode(Credits.self, from: responseData)
                        completion(apiResponse, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    print(networkFailureError)
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    public func getCreditsForTVShow(id: Int, completion: @escaping (_ credits: Credits?, _ error: String?) -> ()) {
        movieRouter.request(.tvShowCredits(id: id)) { data, response, error in
            if error != nil {
                completion(nil, NetworkResponse.checkNetworkConnection.rawValue)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = NetworkResponse.handleNetworkResponse(response)
                
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        //let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        //print(jsonData)
                        let apiResponse = try JSONDecoder().decode(Credits.self, from: responseData)
                        completion(apiResponse, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    print(networkFailureError)
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    public func getPersonDetailAndCredits(id: Int, completion: @escaping (_ credits: PersonCredits?, _ error: String?) -> ()) {
        personRouter.request(.personDetailAndCredits(id: id)) { data, response, error in
            if error != nil {
                completion(nil, NetworkResponse.checkNetworkConnection.rawValue)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = NetworkResponse.handleNetworkResponse(response)
                
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        print(jsonData)
                        //let apiResponse = try JSONDecoder().decode(PersonCredits.self, from: responseData)
                        //completion(apiResponse, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    print(networkFailureError)
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    public func getCombinedCreditsForPerson(id: Int, completion: @escaping (_ credits: PersonCredits?, _ error: String?) -> ()) {
        personRouter.request(.personCredits(id: id)) { data, response, error in
            if error != nil {
                completion(nil, NetworkResponse.checkNetworkConnection.rawValue)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = NetworkResponse.handleNetworkResponse(response)
                
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        //let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        //print(jsonData)
                        let apiResponse = try JSONDecoder().decode(PersonCredits.self, from: responseData)
                        completion(apiResponse, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    print(networkFailureError)
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    public func searchMovies(searchText: String, completion: @escaping (_ movies: [Movie]?, _ error: String?) -> ()) {
        movieRouter.request(.searchMovies(text: searchText)) { data, response, error in
            if error != nil {
                completion(nil, NetworkResponse.checkNetworkConnection.rawValue)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = NetworkResponse.handleNetworkResponse(response)
                
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        //let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        //print(jsonData)
                        let apiResponse = try JSONDecoder().decode(MovieApiResponse.self, from: responseData)
                        completion(apiResponse.movies, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    print(networkFailureError)
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    public func searchTVShows(searchText: String, completion: @escaping (_ tvShows: [TVShow]?, _ error: String?) -> ()) {
        movieRouter.request(.searchTVShows(text: searchText)) { data, response, error in
            if error != nil {
                completion(nil, NetworkResponse.checkNetworkConnection.rawValue)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = NetworkResponse.handleNetworkResponse(response)
                
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        //let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        //print(jsonData)
                        let apiResponse = try JSONDecoder().decode(TVShowApiResponse.self, from: responseData)
                        completion(apiResponse.tvShows, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    print(networkFailureError)
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    public func searchPeople(searchText: String, completion: @escaping (_ people: [Person]?, _ error: String?) -> ()) {
        personRouter.request(.searchPeople(text: searchText)) { data, response, error in
            if error != nil {
                completion(nil, NetworkResponse.checkNetworkConnection.rawValue)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = NetworkResponse.handleNetworkResponse(response)
                
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        //let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        //print(jsonData)
                        let apiResponse = try JSONDecoder().decode(PersonApiResponse.self, from: responseData)
                        completion(apiResponse.people, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    print(networkFailureError)
                    completion(nil, networkFailureError)
                }
            }
        }
    }
}
