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
    
    case discoverMoviesByGenre(id: Int)
    case discoverTVShowsByGenre(id: Int)
        
    case movieGenres
    case tvShowGenres
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
        
        case .movieGenres: return "genre/movie/list"
        case .tvShowGenres: return "genre/tv/list"
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
            
        case .movieGenres, .tvShowGenres:
            let urlParameters: [String: Any] = ["api_key": NetworkManager.MovieAPIKey]
            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: urlParameters)
            
        case .discoverMoviesByGenre(let id), .discoverTVShowsByGenre(let id):
            var urlParameters: [String: Any] = ["api_key": NetworkManager.MovieAPIKey, "sort_by": "popularity.desc"]
            if id != -1 { // id of -1 means display all genres
                urlParameters["with_genres"] = "\(id)"
            }
            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: urlParameters)
            
        default: return .request
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}
