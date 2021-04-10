//
//  Entity.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-29.
//

import Foundation

enum EntityType {
    case movie
    case tvShow
    case person
}

protocol Entity {
    var id: Int { get }
    var type: EntityType { get }
    var name: String { get }
    var posterPath: String? { get }
    var popularity: Double? { get }
    
    // meta info, not provided by api
    var lastViewedDate: Date? { get set }
    var isHintShown: Bool { get set }
    var isRevealed: Bool { get set }
    var correctlyGuessed: Bool { get set }
    var isFavorite: Bool { get set }
}

struct EntitySearch {
    // see NetworkManager.searchAll() (where this function is used) to see exlpanation for why it is used instead of an object conforming to decodable.
    static func decodeSearchData(data: Data) throws -> [Entity] {
        let jsonData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        
        var entityResults: [Entity] = []
        if let parsedJson = jsonData as? [String: Any], let results = parsedJson["results"] as? [[String: Any]] {
            for result in results {
                if let mediaType = result["media_type"] as? String {
                    if mediaType == "movie" {
                        let movieData = try JSONSerialization.data(withJSONObject: result)
                        let movie = try JSONDecoder().decode(Movie.self, from: movieData)
                        entityResults.append(movie)
                    } else if mediaType == "tv" {
                        let tvShowData = try JSONSerialization.data(withJSONObject: result)
                        let tvShow = try JSONDecoder().decode(TVShow.self, from: tvShowData)
                        entityResults.append(tvShow)
                    } else if mediaType == "person" {
                        let personData = try JSONSerialization.data(withJSONObject: result)
                        let person = try JSONDecoder().decode(Person.self, from: personData)
                        entityResults.append(person)
                    }
                }
            }
        }
        
        return entityResults
    }
}
