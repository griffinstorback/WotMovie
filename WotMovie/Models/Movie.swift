//
//  Movie.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-07.
//

import Foundation

struct Movie: Title {
    let id: Int
    let type: EntityType = .movie
    let posterPath: String?
    let backdrop: String?
    let name: String
    let releaseDate: String?
    let rating: Double?
    let overview: String
    let genreIDs: [Int]
    
    // lastViewedDate should be set when coming from a MovieMO, so GuessGrid knows when it should filter it out
    var lastViewedDate: Date?
    var isHintShown: Bool = false
    var isRevealed: Bool = false
    var correctlyGuessed: Bool = false
    var isFavorite: Bool = false
    
    init?(movieOrTVShow item: MovieOrTVShow) {
        guard item.type == .movie else {
            return nil
        }
        
        id = item.id
        posterPath = item.posterPath
        backdrop = nil
        name = item.name
        releaseDate = item.releaseDate
        rating = nil
        overview = item.overview
        genreIDs = item.genreIDs
    }
    
    init(movieMO: MovieMO) {
        id = Int(movieMO.id)
        posterPath = movieMO.posterImageURL
        backdrop = nil
        name = movieMO.name ?? ""
        releaseDate = movieMO.releaseDate
        rating = nil
        overview = movieMO.overview ?? ""
        
        if let genres = movieMO.genres?.allObjects as? [MovieGenreMO] {
            var genreIDs = [Int]()
            for genre in genres {
                genreIDs.append(Int(genre.id))
            }
            self.genreIDs = genreIDs
        } else {
            genreIDs = []
        }
        
        lastViewedDate = movieMO.lastViewedDate
        isHintShown = movieMO.isHintShown
        isRevealed = movieMO.revealed != nil || movieMO.guessed != nil
        correctlyGuessed = movieMO.guessed != nil
        isFavorite = movieMO.watchlist != nil
    }
}

extension Movie: Decodable {
    enum MovieCodingKeys: String, CodingKey {
        case id
        case posterPath = "poster_path"
        case backdrop = "backdrop_path"
        case name = "title"
        case releaseDate = "release_date"
        case rating = "vote_average"
        case overview
        case genreIDs = "genre_ids"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MovieCodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        backdrop = try container.decodeIfPresent(String.self, forKey: .backdrop)
        name = try container.decode(String.self, forKey: .name)
        releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate)
        rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        overview = try container.decode(String.self, forKey: .overview)
        genreIDs = try container.decode([Int].self, forKey: .genreIDs)
    }
}

struct MovieApiResponse {
    let page: Int
    let numberOfResults: Int
    let numberOfPages: Int
    let movies: [Movie]
}

extension MovieApiResponse: Decodable {
    private enum MovieApiResponseCodingKeys: String, CodingKey {
        case page
        case numberOfResults = "total_results"
        case numberOfPages = "total_pages"
        case movies = "results"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MovieApiResponseCodingKeys.self)
        
        page = try container.decode(Int.self, forKey: .page)
        numberOfResults = try container.decode(Int.self, forKey: .numberOfResults)
        numberOfPages = try container.decode(Int.self, forKey: .numberOfPages)
        movies = try container.decode([Movie].self, forKey: .movies)
    }
}
