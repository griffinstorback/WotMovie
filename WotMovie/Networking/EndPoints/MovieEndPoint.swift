//
//  MovieEndPoint.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-08.
//

import Foundation

enum NetworkEnvironment {
    case qa
    case production
    case staging
}

public enum MovieApi {
    case recommended(id: Int)
    case popular(page: Int)
    case newMovies(page: Int)
    case video(id: Int)
    
    case discoverMoviesByGenre(id: Int, page: Int)
    case discoverTVShowsByGenre(id: Int, page: Int)
    case popularPeople(page: Int)
    
    case topRatedMovies(page: Int)
    case topRatedTVShows(page: Int)
        
    case movieGenres
    case tvShowGenres
    case jobs
    
    case movieCredits(id: Int)
    case tvShowCredits(id: Int)
    case personCredits(id: Int)
    
    case searchMovies(text: String)
    case searchTVShows(text: String)
    case searchPeople(text: String)
}

extension MovieApi: EndPointType {
    var environmentBaseURL: String {
        switch NetworkManager.environment {
        case .production: return "https://api.themoviedb.org/3/"
        case .qa: return "https://qa.themoviedb.org/3/"
        case .staging: return "https://staging.themoviedb.org/3/"
        }
    }
    
    var baseURL: URL {
        guard let url = URL(string: environmentBaseURL) else {
            fatalError("baseURL could not be configured")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .recommended(let id): return "\(id)/recommendations"
        case .popular: return "popular"
        case .newMovies: return "movie/now_playing"
        case .video(let id): return "\(id)/videos"
            
        case .discoverMoviesByGenre: return "discover/movie"
        case .discoverTVShowsByGenre: return "discover/tv"
        case .popularPeople: return "person/popular"
            
        case .topRatedMovies: return "movie/top_rated"
        case .topRatedTVShows: return "tv/top_rated"
        
        case .movieGenres: return "genre/movie/list"
        case .tvShowGenres: return "genre/tv/list"
        case .jobs: return "configuration/jobs"
            
        case .movieCredits(let id): return "movie/\(id)/credits"
        case .tvShowCredits(let id): return "tv/\(id)/credits"
        case .personCredits(let id): return "person/\(id)/combined_credits"
            
        case .searchMovies: return "search/movie"
        case .searchTVShows: return "search/tv"
        case .searchPeople: return "search/person"
        }
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var task: HTTPTask {
        switch self {
        case .newMovies(let page):
            let urlParameters: [String: Any] = ["page": page, "api_key": NetworkManager.MovieAPIKey]
            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: urlParameters)
            
        case .movieGenres, .tvShowGenres, .jobs:
            let urlParameters: [String: Any] = ["api_key": NetworkManager.MovieAPIKey]
            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: urlParameters)
        
        case .discoverMoviesByGenre(let id, let page), .discoverTVShowsByGenre(let id, let page):
            var urlParameters: [String: Any] = ["api_key": NetworkManager.MovieAPIKey, "sort_by": "vote_count.desc", "page": page]
            if id != -1 { // id of -1 means display all genres
                urlParameters["with_genres"] = "\(id)"
            }
            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: urlParameters)
        
        case .popularPeople(let page):
            let urlParameters: [String: Any] = ["api_key": NetworkManager.MovieAPIKey, "page": page]
            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: urlParameters)
        
        // NOT REALLY USED (IM PRETTY SURE)
        case .topRatedMovies(let page), .topRatedTVShows(let page):
            let urlParameters: [String: Any] = ["api_key": NetworkManager.MovieAPIKey, "page": page]
            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: urlParameters)
            
        case .movieCredits, .tvShowCredits:
            let urlParameters: [String: Any] = ["api_key": NetworkManager.MovieAPIKey]
            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: urlParameters)
            
        case .personCredits:
            let urlParameters: [String: Any] = ["api_key": NetworkManager.MovieAPIKey]
            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: urlParameters)
        
        case .searchMovies(let text), .searchTVShows(let text), .searchPeople(let text):
            let urlParameters: [String: Any] = ["api_key": NetworkManager.MovieAPIKey, "query": text]
            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: urlParameters)
            
        default: return .request
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}
