//
//  MovieOrTVShow.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-11-20.
//

import Foundation

// Used for person results (knownFor array objects, combined credits objects)
// -- WE NEED THIS TYPE, for the character and personsJob properties that aren't present on regular person/title objects

struct MovieOrTVShow: Title {
    let id: Int
    let type: EntityType
    let name: String
    let posterPath: String?
    let overview: String
    let releaseDate: String?
    let genreIDs: [Int]
    let personsJob: Job? // if person wasn't acting but was producer, director or other job
    let character: String? // non-nil when person is actor in this movie/show
    
    // not used right now, but could be used for sorting -- problem is their small roles in big films would show before a leading role in smaller film
    let popularity: Double
    
    // these properties are unused on movieortvshow, because user is never guessing this type.
    var lastViewedDate: Date?
    var isRevealed: Bool = false
    var isHintShown: Bool = false
    var correctlyGuessed: Bool = false
    var isFavorite: Bool = false
}

extension MovieOrTVShow: Decodable {
    enum MovieOrTVShowCodingKeys: String, CodingKey {
        case id
        case posterPath = "poster_path"
        case genreIDs = "genre_ids"
        
        // mediaType itself isnt stored on object but translated to EntityType
        case mediaType = "media_type"
        
        // title is used for movies, name is used for tvshows
        case title
        case name
        
        case overview
        
        // tv show has no release_date field, use first air date instead.
        case releaseDateMovie = "release_date"
        case releaseDateTVShow = "first_air_date"
        
        case personsJob = "job"
        case character = "character"
        
        case popularity
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MovieOrTVShowCodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        genreIDs = try container.decode([Int].self, forKey: .genreIDs)
        
        let mediaType = try container.decode(String.self, forKey: .mediaType)
        
        if mediaType == "movie" {
            type = .movie
            name = try container.decode(String.self, forKey: .title)
            releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDateMovie)
        } else if mediaType == "tv" {
            type = .tvShow
            name = try container.decode(String.self, forKey: .name)
            releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDateTVShow)
        } else {
            // this case should never be hit
            print("*** WARNING: decoding a MovieOrTVShow object; mediaType came back null from api. Setting to type .person.")
            type = .person
            name = "-"
            releaseDate = "-"
        }
        
        overview = try container.decode(String.self, forKey: .overview)
        personsJob = try container.decodeIfPresent(String.self, forKey: .personsJob)
        character = try container.decodeIfPresent(String.self, forKey: .character)
        popularity = try container.decodeIfPresent(Double.self, forKey: .popularity) ?? 0
    }
}
