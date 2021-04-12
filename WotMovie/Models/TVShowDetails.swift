//
//  TVShowDetails.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-04-11.
//

import Foundation

struct TVShowDetails {
    let id: Int
    let tvShow: TVShow // since the basic info comes with details as well, might as well save it in case we want to update the core data object.
    let lastAirDate: String?
    let numberOfEpisodes: Int?
    let numberOfSeasons: Int?
    let credits: Credits
}

extension TVShowDetails: Decodable {
    private enum TVShowDetailsCodingKeys: String, CodingKey {
        case id
        case lastAirDate = "last_air_date"
        case numberOfEpisodes = "number_of_episodes"
        case numberOfSeasons = "number_of_seasons"
        case credits
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TVShowDetailsCodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        tvShow = try TVShow.init(from: decoder)
        lastAirDate = try container.decodeIfPresent(String.self, forKey: .lastAirDate)
        numberOfEpisodes = try container.decodeIfPresent(Int.self, forKey: .numberOfEpisodes)
        numberOfSeasons = try container.decodeIfPresent(Int.self, forKey: .numberOfSeasons)
        credits = try container.decode(Credits.self, forKey: .credits)
    }
}

