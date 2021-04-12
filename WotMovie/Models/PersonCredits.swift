//
//  PersonCredits.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-04-11.
//

import Foundation

/*
 
 PersonCredits is mostly just used within the PersonDetails struct.
 
 */

struct PersonCredits {
    let id: Int?
    let cast: [MovieOrTVShow]
    let crew: [MovieOrTVShow]
}

extension PersonCredits: Decodable {
    private enum PersonCreditsCodingKeys: String, CodingKey {
        case id
        case cast
        case crew
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PersonCreditsCodingKeys.self)
        
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        cast = try container.decode([MovieOrTVShow].self, forKey: .cast)
        crew = try container.decode([MovieOrTVShow].self, forKey: .crew)
    }
}
