//
//  ParameterEncoding.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-07.
//

import Foundation

public typealias Parameters = [String:Any]

public protocol ParameterEncoder {
    static func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws
}

public enum ParameterEncoding {
    case urlEncoding
    case jsonEncoding
    case urlAndJsonEncoding
    
    public func encode(urlRequest: inout URLRequest, bodyParameters: Parameters?, urlParameters: Parameters?) throws {
        do {
            switch self {
            case .urlEncoding:
                guard let urlParameters = urlParameters else { return }
                try URLParameterEncoder.encode(urlRequest: &urlRequest, with: urlParameters)
            case .jsonEncoding:
                guard let bodyParameters = bodyParameters else { return }
                try JSONParameterEncoder.encode(urlRequest: &urlRequest, with: bodyParameters)
            case .urlAndJsonEncoding:
                guard let urlParameters = urlParameters, let bodyParameters = bodyParameters else { return }
                try URLParameterEncoder.encode(urlRequest: &urlRequest, with: urlParameters)
                try JSONParameterEncoder.encode(urlRequest: &urlRequest, with: bodyParameters)
            }
        }
    }
}

public enum NetworkError: String, Error {
    case parametersNil = "Parameters were nil."
    case encodingFailed = "Parameter encoding failed."
    case missingURL = "URL is nil."
}
