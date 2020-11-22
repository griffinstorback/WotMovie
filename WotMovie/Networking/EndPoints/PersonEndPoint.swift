//
//  PersonEndPoint.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-11-22.
//

import Foundation

public enum PersonApi {
    case popularPeople(page: Int)
    
    case personDetail(id: Int)
    case personCredits(id: Int)
    case personDetailAndCredits(id: Int)
    
    case searchPeople(text: String)
}

extension PersonApi: EndPointType {
    var environmentBaseURL: String {
        NetworkManager.environment.rawValue
    }
    
    var baseURL: URL {
        guard let url = URL(string: environmentBaseURL) else {
            fatalError("baseURL could not be configured (PersonEndPoint)")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .popularPeople: return "person/popular"
            
        case .personDetail(let id): return "person/\(id)"
        case .personCredits(let id): return "person/\(id)/combined_credits"
        case .personDetailAndCredits(let id): return "person/\(id)" // credits added as query parameter (see task)
        
        case .searchPeople: return "search/person"
        }
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var task: HTTPTask {
        switch self {
        case .popularPeople(let page):
            let urlParameters: [String: Any] = ["api_key": NetworkManager.MovieAPIKey, "page": page]
            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: urlParameters)
                        
        case .personDetail, .personCredits:
            let urlParameters: [String: Any] = ["api_key": NetworkManager.MovieAPIKey]
            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: urlParameters)
        case .personDetailAndCredits:
            let urlParameters: [String: Any] = ["api_key": NetworkManager.MovieAPIKey, "append_to_response": "combined_credits"]
            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: urlParameters)
            
        case .searchPeople(let text):
            let urlParameters: [String: Any] = ["api_key": NetworkManager.MovieAPIKey, "query": text]
            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: urlParameters)
            
        //default:
        //    return .request
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}
