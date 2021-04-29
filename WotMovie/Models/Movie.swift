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
    
    init(movieMO: MovieMO) {
        id = Int(movieMO.id)
        name = movieMO.name ?? ""
        posterPath = movieMO.posterImageURL
        popularity = movieMO.popularity
        
        overview = movieMO.overview
        releaseDate = movieMO.releaseDate
        genreIDs = Movie.parseGenreIDsFromMovieMO(movieMO)
        voteAverage = movieMO.voteAverage
        backdrop = movieMO.backdropImageURL
        
        lastViewedDate = movieMO.lastViewedDate
        isHintShown = movieMO.isHintShown
        isRevealed = movieMO.revealed != nil || movieMO.guessed != nil
        correctlyGuessed = movieMO.guessed != nil
        isFavorite = movieMO.watchlist != nil
    }
    
    static private func parseGenreIDsFromMovieMO(_ movieMO: MovieMO) -> [Int] {
        if let genres = movieMO.genres?.allObjects as? [MovieGenreMO] {
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

extension Movie: Decodable {
    enum MovieCodingKeys: String, CodingKey {
        case id
        case name = "title"
        case posterPath = "poster_path"
        case popularity
        
        case overview
        case releaseDate = "release_date"
        case genreIDs = "genre_ids"
        case voteAverage = "vote_average"
        case backdrop = "backdrop_path"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MovieCodingKeys.self)
        
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
