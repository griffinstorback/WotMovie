//
//  MovieOrTVShow.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-11-20.
//

import Foundation

// Used for person results (knownFor array objects, combined credits objects)
// -- WE NEED THIS TYPE, for the character and personsJob properties that aren't present on regular person/title objects

// -- this type is NOT stored in core data currently.

struct MovieOrTVShow: Title {
    let id: Int
    let type: EntityType
    let name: String
    let posterPath: String?
    let popularity: Double? // not used right now, but could be used for sorting (problem is small roles in big films would show before a leading role in smaller film)
    
    let overview: String?
    let releaseDate: String?
    let genreIDs: [Int]
    let voteAverage: Double?
    let backdrop: String?
    
    // these two properties unique to MovieOrTVShow, and are the reason this type exists.
    let personsJob: Job? // if person wasn't acting but was producer, director or other job
    let character: String? // non-nil when person is actor in this movie/show
    
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
        case nameMovie = "title" // title is returned from api for movies (we rename to "name" in our database)
        case nameTVShow = "name" // name is returned from api for tv shows
        case posterPath = "poster_path"
        case popularity
        
        case overview
        case releaseDateMovie = "release_date"
        case releaseDateTVShow = "first_air_date" // tv show has no release_date field, use first air date instead.
        case genreIDs = "genre_ids"
        case voteAverage = "vote_average"
        case backdrop = "backdrop_path"
        
        
        // mediaType itself isnt stored on object but translated to EntityType
        case mediaType = "media_type"
        case personsJob = "job"
        case character = "character"
        
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MovieOrTVShowCodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        
        let mediaType = try container.decode(String.self, forKey: .mediaType)
        if mediaType == "movie" {
            type = .movie
            name = try container.decode(String.self, forKey: .nameMovie)
            releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDateMovie)
        } else if mediaType == "tv" {
            type = .tvShow
            name = try container.decode(String.self, forKey: .nameTVShow)
            releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDateTVShow)
        } else { // this case should never be hit
            // TODO: should return nil from the initializer instead of making it a .person
            print("*** WARNING: decoding a MovieOrTVShow object; mediaType came back null from api. Setting to type .person.")
            type = .person
            name = "-"
            releaseDate = "-"
        }
        
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        popularity = try container.decodeIfPresent(Double.self, forKey: .popularity)
        
        overview = try container.decodeIfPresent(String.self, forKey: .overview)
        genreIDs = try container.decodeIfPresent([Int].self, forKey: .genreIDs) ?? []
        voteAverage = try container.decodeIfPresent(Double.self, forKey: .voteAverage)
        backdrop = try container.decodeIfPresent(String.self, forKey: .backdrop)
        
        personsJob = try container.decodeIfPresent(String.self, forKey: .personsJob)
        character = try container.decodeIfPresent(String.self, forKey: .character)
    }
}
