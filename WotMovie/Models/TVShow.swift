//
//  TVShow.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-15.
//

import Foundation

struct TVShow: Title {    
    let id: Int
    let type: EntityType = .tvShow
    let posterPath: String?
    let backdrop: String?
    let name: String
    let releaseDate: String?
    let rating: Double
    let overview: String
    let genreIDs: [Int]
}

extension TVShow: Decodable {
    enum TVShowCodingKeys: String, CodingKey {
        case id
        case posterPath = "poster_path"
        case backdrop = "backdrop_path"
        case name
        case releaseDate = "first_air_date"
        case rating = "vote_average"
        case overview
        case genreIDs = "genre_ids"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TVShowCodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        posterPath = try container.decode(String?.self, forKey: .posterPath)
        backdrop = try container.decode(String?.self, forKey: .backdrop)
        name = try container.decode(String.self, forKey: .name)
        releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate)
        rating = try container.decode(Double.self, forKey: .rating)
        overview = try container.decode(String.self, forKey: .overview)
        genreIDs = try container.decode([Int].self, forKey: .genreIDs)
    }
}

struct TVShowApiResponse {
    let page: Int
    let numberOfResults: Int
    let numberOfPages: Int
    let tvShows: [TVShow]
}

extension TVShowApiResponse: Decodable {
    private enum TVShowApiResponseCodingKeys: String, CodingKey {
        case page
        case numberOfResults = "total_results"
        case numberOfPages = "total_pages"
        case tvShows = "results"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TVShowApiResponseCodingKeys.self)
        
        page = try container.decode(Int.self, forKey: .page)
        numberOfResults = try container.decode(Int.self, forKey: .numberOfResults)
        numberOfPages = try container.decode(Int.self, forKey: .numberOfPages)
        tvShows = try container.decode([TVShow].self, forKey: .tvShows)
    }
}
