//
//  Genre.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-14.
//

import Foundation

protocol Genre {
    var isMovie: Bool { get }
    var id: Int { get }
    var name: String { get }
}

enum GenreCodingKeys: String, CodingKey {
    case id
    case name
}

struct MovieGenre: Genre {
    let isMovie: Bool = true
    let id: Int
    let name: String
    let correctlyGuessedCount: Int = 0
    
    init(genreMO: MovieGenreMO) {
        id = Int(genreMO.id)
        name = genreMO.name ?? ""
    }
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}
struct TVShowGenre: Genre {
    let isMovie: Bool = false
    let id: Int
    let name: String
    let correctlyGuessedCount: Int = 0
}

extension MovieGenre: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GenreCodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
    }
}
extension TVShowGenre: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GenreCodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
    }
}

struct MovieGenreApiResponse {
    let genres: [MovieGenre]
}
struct TVShowGenreApiResponse {
    let genres: [TVShowGenre]
}

extension MovieGenreApiResponse: Decodable {
    enum GenreApiResponseCodingKeys: String, CodingKey {
        case genres
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GenreApiResponseCodingKeys.self)
        
        genres = try container.decode([MovieGenre].self, forKey: .genres)
    }
}
extension TVShowGenreApiResponse: Decodable {
    enum GenreApiResponseCodingKeys: String, CodingKey {
        case genres
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GenreApiResponseCodingKeys.self)
        
        genres = try container.decode([TVShowGenre].self, forKey: .genres)
    }
}
