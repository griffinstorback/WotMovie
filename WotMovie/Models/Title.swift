//
//  Title.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-15.
//

import Foundation

// Movie and TVShow inherit from Title, allowing them to be used interchangeably in Grids/Lists
protocol Title {
    var id: Int { get }
    var posterPath: String? { get }
    var isMovie: Bool { get }
}
