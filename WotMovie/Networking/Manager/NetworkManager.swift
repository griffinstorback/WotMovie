//
//  NetworkManager.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-07.
//

import Foundation

final class NetworkManager {
    
    static let shared = NetworkManager()
    private init() {}
    
    static let environment: NetworkEnvironment = .production
    static let MovieAPIKey = "3a71a701782ff20157039d47ddd62df9"
    
    private let router = Router<MovieApi>()
    
    // get list of newest movies
    public func getNewMovies(page: Int, completion: @escaping (_ movies: [Movie]?, _ error: String?) -> ()) {
        router.request(.newMovies(page: page)) { data, response, error in
            if error != nil {
                completion(nil, "Please check your network connection.")
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
        router.request(.movieGenres) { data, response, error in
            if error != nil {
                completion(nil, "Please check your network connection.")
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
        router.request(.tvShowGenres) { data, response, error in
            if error != nil {
                completion(nil, "Please check your network connection.")
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
    
    public func getListOfMoviesByGenre(id: Int, page: Int, completion: @escaping (_ tvShows: [Movie]?, _ error: String?) -> ()) {
        router.request(.discoverMoviesByGenre(id: id, page: page)) { data, response, error in
            if error != nil {
                completion(nil, "Please check your network connection.")
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
        router.request(.discoverTVShowsByGenre(id: id, page: page)) { data, response, error in
            if error != nil {
                completion(nil, "Please check your network connection.")
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
    
    public func getCreditsForMovie(id: Int, completion: @escaping (_ credits: Credits?, _ error: String?) -> ()) {
        router.request(.movieCredits(id: id)) { data, response, error in
            if error != nil {
                completion(nil, "Please check your network connection.")
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
        router.request(.tvShowCredits(id: id)) { data, response, error in
            if error != nil {
                completion(nil, "Please check your network connection.")
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
}
