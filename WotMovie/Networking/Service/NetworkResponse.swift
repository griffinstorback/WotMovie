//
//  NetworkResponse.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-16.
//

import Foundation

public enum NetworkResponse: String {
    case success
    case authenticationError = "You need to be authenticated first."
    case badRequest = "Bad request."
    case outdated = "The url you requested is outdated."
    case failed = "Network request failed."
    case noData = "Response returned with no data to decode"
    case unableToDecode = "We could not decode the response."
    case checkNetworkConnection = "Please check your network connection."
    
    static func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String> {
        print("* STATUS CODE: ", response.statusCode)
        switch response.statusCode {
        case 200...299: return .success
        case 401...500: return .failure(NetworkResponse.authenticationError.rawValue)
        case 501...599: return .failure(NetworkResponse.badRequest.rawValue)
        case 600: return .failure(NetworkResponse.outdated.rawValue)
        default: return .failure(NetworkResponse.failed.rawValue)
        }
    }
}

public enum Result<String> {
    case success
    case failure(String)
}
