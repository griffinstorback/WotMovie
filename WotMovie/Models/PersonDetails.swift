//
//  PersonDetails.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-04-11.
//

import Foundation

struct PersonDetails {
    let id: Int
    let person: Person // since the basic info comes with details as well, might as well save it in case we want to update the core data object.
    let overview: String?
    let personCredits: PersonCredits
}

extension PersonDetails: Decodable {
    enum PersonDetailsCodingKeys: String, CodingKey {
        case id
        case overview = "biography"
        case personCredits = "combined_credits"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PersonDetailsCodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        person = try Person.init(from: decoder)
        overview = try container.decodeIfPresent(String.self, forKey: .overview)
        personCredits = try container.decode(PersonCredits.self, forKey: .personCredits)
    }
}

