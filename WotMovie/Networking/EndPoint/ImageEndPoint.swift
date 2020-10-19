//
//  ImageEndPoint.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-16.
//

import Foundation

public enum ImageApi {
    case imageWithPath(path: String)
}

extension ImageApi: EndPointType {
    var baseURLString: String {
        "https://image.tmdb.org/t/p/"
    }
    
    var baseURL: URL {
        guard let url = URL(string: baseURLString) else {
            fatalError("baseURL could not be configured")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .imageWithPath(let path):
            return "w500\(path)"
        }
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var task: HTTPTask {
        switch self {
        case .imageWithPath:
            return .request
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}
