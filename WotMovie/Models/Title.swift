//
//  Title.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-15.
//

import Foundation

// Movie and TVShow inherit from Title, allowing them to be used interchangeably in Grids/Lists
protocol Title: Entity {
    var id: Int { get }
    var type: EntityType { get }
    var posterPath: String? { get }
    var genreIDs: [Int] { get }
}
