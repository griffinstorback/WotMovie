//
//  MockJSON.swift
//  WotMovieTests
//
//  Created by Griffin Storback on 2020-10-12.
//

import Foundation
@testable import WotMovie

struct MockJSON {
    let id: Int
    let name: String
    let email: String
}

extension MockJSON: Decodable, Equatable {
    enum MockJSONCodingKeys: String, CodingKey {
        case id = "UserID"
        case name = "Name"
        case email = "Email"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MockJSONCodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        email = try container.decode(String.self, forKey: .email)
    }
}
