//
//  EndPointType.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-07.
//

import Foundation

protocol EndPointType {
    var baseURL: URL { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var task: HTTPTask { get }
    var headers: HTTPHeaders? { get }
}
