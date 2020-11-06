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
    var genreIDs: [Int] { get }
}


// Used for person results (knownFor array objects)
struct MovieOrTVShow: Title {
    let id: Int
    let type: EntityType
    let name: String
    let posterPath: String?
    let genreIDs: [Int]
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
    }
}
