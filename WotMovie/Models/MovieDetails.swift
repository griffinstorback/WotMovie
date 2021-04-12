//
//  MovieDetails.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-04-11.
//

import Foundation

struct MovieDetails {
    let id: Int
    let movie: Movie // since the basic info comes with details as well, might as well save it in case we want to update the core data object.
    let runtime: Int? // in minutes
    let budget: Int? // in dollars
    let revenue: Int? // in dollars
    let credits: Credits
}

extension MovieDetails: Decodable {
    private enum MovieDetailsCodingKeys: String, CodingKey {
        case id
        case runtime
        case budget
        case revenue
        case credits
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MovieDetailsCodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        movie = try Movie.init(from: decoder)
        runtime = try container.decodeIfPresent(Int.self, forKey: .runtime)
        budget = try container.decodeIfPresent(Int.self, forKey: .budget)
        revenue = try container.decodeIfPresent(Int.self, forKey: .revenue)
        credits = try container.decode(Credits.self, forKey: .credits)
    }
}
