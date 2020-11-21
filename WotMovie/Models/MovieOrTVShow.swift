//
//  MovieOrTVShow.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-11-20.
//

import Foundation

// Used for person results (knownFor array objects, combined credits objects)
struct MovieOrTVShow: Title {
    let id: Int
    let type: EntityType
    let name: String
    let posterPath: String?
    let overview: String
    let releaseDate: String?
    let genreIDs: [Int]
    let personsJob: Job? // if person wasn't acting but was producer, director or other job
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
        case releaseDate = "release_date"
        case personsJob = "job"
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
        } else if mediaType == "tv" {
            type = .tvShow
            name = try container.decode(String.self, forKey: .name)
        } else {
            // this case should never be hit
            type = .person
            name = ""
        }
        
        overview = try container.decode(String.self, forKey: .overview)
        releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate)
        personsJob = try container.decodeIfPresent(String.self, forKey: .personsJob)
    }
}
