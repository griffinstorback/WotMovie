//
//  Person.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-21.
//

import Foundation

protocol Person {
    var id: Int { get }
    var name: String { get }
    var profilePath: String? { get }
}

struct CastMember: Person {
    var id: Int
    var name: String
    var profilePath: String?
    var character: String
}

struct CrewMember: Person {
    var id: Int
    var name: String
    var profilePath: String?
    var department: String
    var job: String
}

extension CastMember: Decodable {
    enum CastMemberCodingKey: String, CodingKey {
        case id
        case name
        case profilePath = "profile_path"
        case character
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CastMemberCodingKey.self)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        profilePath = try container.decode(String?.self, forKey: .profilePath)
        character = try container.decode(String.self, forKey: .character)
    }
}

extension CrewMember: Decodable {
    enum CrewMemberCodingKey: String, CodingKey {
        case id
        case name
        case profilePath = "profile_path"
        case department
        case job
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CrewMemberCodingKey.self)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        profilePath = try container.decode(String?.self, forKey: .profilePath)
        department = try container.decode(String.self, forKey: .department)
        job = try container.decode(String.self, forKey: .job)
    }
}
