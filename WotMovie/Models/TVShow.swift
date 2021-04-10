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
    let name: String
    let posterPath: String?
    let popularity: Double?
    
    let overview: String?
    let releaseDate: String?
    let genreIDs: [Int]
    let voteAverage: Double?
    let backdrop: String?
    
    // these need to be retrieved from core data
    var lastViewedDate: Date?
    var isHintShown: Bool = false
    var isRevealed: Bool = false
    var correctlyGuessed: Bool = false
    var isFavorite: Bool = false
    
    init(movieOrTVShow item: MovieOrTVShow) {
        id = item.id
        name = item.name
        posterPath = item.posterPath
        popularity = item.popularity
        
        overview = item.overview
        releaseDate = item.releaseDate
        genreIDs = item.genreIDs
        voteAverage = item.voteAverage
        backdrop = item.backdrop
    }
    
    init(tvShowMO: TVShowMO) {
        id = Int(tvShowMO.id)
        name = tvShowMO.name ?? ""
        posterPath = tvShowMO.posterImageURL
        popularity = tvShowMO.popularity
        
        overview = tvShowMO.overview
        releaseDate = tvShowMO.releaseDate
        genreIDs = TVShow.parseGenreIDsFromTVShowMO(tvShowMO)
        voteAverage = tvShowMO.voteAverage
        backdrop = tvShowMO.backdropImageURL
        
        lastViewedDate = tvShowMO.lastViewedDate
        isHintShown = tvShowMO.isHintShown
        isRevealed = tvShowMO.revealed != nil || tvShowMO.guessed != nil
        correctlyGuessed = tvShowMO.guessed != nil
        isFavorite = tvShowMO.watchlist != nil
    }
    
    static private func parseGenreIDsFromTVShowMO(_ tvShowMO: TVShowMO) -> [Int] {
        if let genres = tvShowMO.genres?.allObjects as? [TVShowGenreMO] {
            var genreIDs = [Int]()
            for genre in genres {
                genreIDs.append(Int(genre.id))
            }
            return genreIDs
        } else {
            return []
        }
    }
}

extension TVShow: Decodable {
    enum TVShowCodingKeys: String, CodingKey {
        case id
        case name
        case posterPath = "poster_path"
        case popularity
        
        case overview
        case releaseDate = "first_air_date"
        case genreIDs = "genre_ids"
        case voteAverage = "vote_average"
        case backdrop = "backdrop_path"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TVShowCodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        popularity = try container.decodeIfPresent(Double.self, forKey: .popularity)
        
        overview = try container.decodeIfPresent(String.self, forKey: .overview)
        releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate)
        genreIDs = try container.decodeIfPresent([Int].self, forKey: .genreIDs) ?? []
        voteAverage = try container.decodeIfPresent(Double.self, forKey: .voteAverage)
        backdrop = try container.decodeIfPresent(String.self, forKey: .backdrop)
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
