//
//  BasePerson.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-21.
//

import Foundation

// MARK: - "Person" is used for full person object (like when getting popular people, or searching people)

struct Person: Entity {
    let id: Int
    let type: EntityType = .person
    let name: String
    let posterPath: String?
    let knownFor: [Title]
}

extension Person: Decodable {
    private enum PersonCodingKeys: String, CodingKey {
        case id
        case name
        case posterPath = "profile_path"
        case knownFor = "known_for"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PersonCodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        knownFor = try container.decode([MovieOrTVShow].self, forKey: .knownFor)
    }
}

struct PersonApiResponse {
    let page: Int
    let numberOfResults: Int
    let numberOfPages: Int
    let people: [Person]
}

extension PersonApiResponse: Decodable {
    private enum PersonApiResponseCodingKeys: String, CodingKey {
        case page
        case numberOfResults = "total_results"
        case numberOfPages = "total_pages"
        case people = "results"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PersonApiResponseCodingKeys.self)
        
        page = try container.decode(Int.self, forKey: .page)
        numberOfResults = try container.decode(Int.self, forKey: .numberOfResults)
        numberOfPages = try container.decode(Int.self, forKey: .numberOfPages)
        people = try container.decode([Person].self, forKey: .people)
    }
}


// MARK: - "BasePerson" and implementations of it are person stubs (like when getting credits)

protocol BasePerson: Entity {
    var id: Int { get }
    var type: EntityType { get }
    var posterPath: String? { get }
    var name: String { get }
}

struct CastMember: BasePerson {
    var id: Int
    var type: EntityType = .person
    var name: String
    var posterPath: String?
    var character: String
}

struct CrewMember: BasePerson {
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
