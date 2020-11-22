//
//  NetworkEnvironment.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-11-22.
//

import Foundation

enum NetworkEnvironment: String {
    case qa
    case production = "https://api.themoviedb.org/3/"
    case staging
}
