//
//  Title.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-15.
//

import Foundation

// Movie and TVShow inherit from Title, allowing them to be used interchangeably in Grids/Lists
protocol Title: Entity {
    override var id: Int { get }
    override var type: EntityType { get }
    override var name: String { get }
    override var posterPath: String? { get }
    override var popularity: Double? { get }
    
    var overview: String? { get }
    var releaseDate: String? { get }
    var genreIDs: [Int] { get }
    var voteAverage: Double? { get }
    var backdrop: String? { get }
}
