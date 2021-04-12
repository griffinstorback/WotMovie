//
//  MovieEndPoint.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-08.
//

import Foundation

public enum MovieApi {
    case recommended(id: Int)
    case popular(page: Int)
    case newMovies(page: Int)
    case video(id: Int)
    
    case discoverMoviesByGenre(id: Int, page: Int)
    case discoverTVShowsByGenre(id: Int, page: Int)
    
    case topRatedMovies(page: Int)
    case topRatedTVShows(page: Int)
        
    case movieGenres
    case tvShowGenres
    case jobs
    
    case movieCredits(id: Int)
    case movieDetailsAndCredits(id: Int)
    case tvShowCredits(id: Int)
    case tvShowDetailsAndCredits(id: Int)
    
    case searchMovies(text: String)
    case searchTVShows(text: String)
    case searchAll(text: String)
}

extension MovieApi: EndPointType {
    var environmentBaseURL: String {
        NetworkManager.environment.rawValue
    }
    
    var baseURL: URL {
        guard let url = URL(string: environmentBaseURL) else {
            fatalError("baseURL could not be configured (MovieEndPoint)")
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
            
        case .topRatedMovies: return "movie/top_rated"
        case .topRatedTVShows: return "tv/top_rated"
        
        case .movieGenres: return "genre/movie/list"
        case .tvShowGenres: return "genre/tv/list"
        case .jobs: return "configuration/jobs"
            
        case .movieCredits(let id): return "movie/\(id)/credits"
        case .movieDetailsAndCredits(let id): return "movie/\(id)"
        case .tvShowCredits(let id): return "tv/\(id)/credits"
        case .tvShowDetailsAndCredits(let id): return "tv/\(id)"
            
        case .searchMovies: return "search/movie"
        case .searchTVShows: return "search/tv"
        case .searchAll: return "search/multi"
        }
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var task: HTTPTask {
        switch self {
        case .newMovies(let page):
            let urlParameters: [String: Any] = ["page": page, "api_key": NetworkManager.api3Key]
            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: urlParameters)
            
        case .movieGenres, .tvShowGenres, .jobs:
            let urlParameters: [String: Any] = ["api_key": NetworkManager.api3Key]
            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: urlParameters)
        
        case .discoverMoviesByGenre(let id, let page), .discoverTVShowsByGenre(let id, let page):
            var urlParameters: [String: Any] = ["api_key": NetworkManager.api3Key, "sort_by": "vote_count.desc", "page": page]
            if id != -1 { // id of -1 means display all genres
                urlParameters["with_genres"] = "\(id)"
            }
            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: urlParameters)
        
        // NOT REALLY USED (IM PRETTY SURE)
        case .topRatedMovies(let page), .topRatedTVShows(let page):
            let urlParameters: [String: Any] = ["api_key": NetworkManager.api3Key, "page": page]
            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: urlParameters)
            
        case .movieCredits, .tvShowCredits:
            let urlParameters: [String: Any] = ["api_key": NetworkManager.api3Key]
            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: urlParameters)
            
        case .movieDetailsAndCredits, .tvShowDetailsAndCredits:
            let urlParameters: [String: Any] = ["api_key": NetworkManager.api3Key, "append_to_response": "credits"]
            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: urlParameters)
        
        case .searchMovies(let text), .searchTVShows(let text), .searchAll(let text):
            let urlParameters: [String: Any] = ["api_key": NetworkManager.api3Key, "query": text]
            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: urlParameters)
            
        default: return .request
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}
