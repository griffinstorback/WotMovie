//
//  Credits.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-21.
//

import Foundation

struct Credits {
    let id: Int
    let cast: [CastMember]
    let crew: [CrewMember]
}

extension Credits: Decodable {
    private enum CreditsCodingKeys: String, CodingKey {
        case id
        case cast
        case crew
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CreditsCodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        cast = try container.decode([CastMember].self, forKey: .cast)
        crew = try container.decode([CrewMember].self, forKey: .crew)
    }
}

struct PersonCredits {
    let id: Int
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
        
        id = try container.decode(Int.self, forKey: .id)
        cast = try container.decode([MovieOrTVShow].self, forKey: .cast)
        crew = try container.decode([MovieOrTVShow].self, forKey: .crew)
    }
}
