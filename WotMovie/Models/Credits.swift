//
//  Credits.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-21.
//

import Foundation

/*
 
 Credits can hold either Movie or TVShow credits. This model is mostly just used within the MovieDetails and TVShowDetails structs.
 
 */

struct Credits {
    let id: Int? // when querying just credits, the title's id comes back - but if appending credits on to another request (like details), it doesn't
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
        
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        cast = try container.decode([CastMember].self, forKey: .cast)
        crew = try container.decode([CrewMember].self, forKey: .crew)
    }
}
