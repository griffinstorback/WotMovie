//
//  Person.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-21.
//

import Foundation

protocol Person: Entity {
    var id: Int { get }
    var type: EntityType { get }
    var posterPath: String? { get }
    var name: String { get }
}

struct CastMember: Person {
    var id: Int
    var type: EntityType = .person
    var name: String
    var posterPath: String?
    var character: String
}

struct CrewMember: Person {
    var id: Int
    var type: EntityType = .person
    var name: String
    var posterPath: String?
    var department: String
    var job: String
}

extension CastMember: Decodable {
    enum CastMemberCodingKey: String, CodingKey {
        case id
        case posterPath = "profile_path"
        case name
        case character
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CastMemberCodingKey.self)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        posterPath = try container.decode(String?.self, forKey: .posterPath)
        character = try container.decode(String.self, forKey: .character)
    }
}

extension CrewMember: Decodable {
    enum CrewMemberCodingKey: String, CodingKey {
        case id
        case posterPath = "profile_path"
        case name
        case department
        case job
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CrewMemberCodingKey.self)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        posterPath = try container.decode(String?.self, forKey: .posterPath)
        department = try container.decode(String.self, forKey: .department)
        job = try container.decode(String.self, forKey: .job)
    }
}
