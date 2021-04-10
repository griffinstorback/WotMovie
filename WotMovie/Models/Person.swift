//
//  BasePerson.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-21.
//

import Foundation

protocol BasePerson: Entity {
    override var id: Int { get }
    override var type: EntityType { get }
    override var name: String { get }
    override var posterPath: String? { get }
    override var popularity: Double? { get }
    
    var gender: Int? { get }
    var knownForDepartment: String? { get }
}

// MARK: - "Person" is used for full person object (like when guessing people, getting popular people, searching people, etc.)

struct Person: BasePerson {
    var id: Int
    var type: EntityType = .person
    var name: String
    var posterPath: String?
    var popularity: Double?
    
    var gender: Int?
    var knownForDepartment: String?
    
    let knownFor: [Title]
    let birthday: String?
    let deathday: String?
    
    // these need to be retrieved from core data
    var lastViewedDate: Date?
    var isHintShown: Bool = false
    var isRevealed: Bool = false
    var correctlyGuessed: Bool = false
    var isFavorite: Bool = false
    
    init(castMember: CastMember) {
        id = castMember.id
        name = castMember.name
        posterPath = castMember.posterPath
        gender = castMember.gender
        knownForDepartment = castMember.knownForDepartment
        
        knownFor = []
        birthday = nil
        deathday = nil
    }
    
    init(crewMember: CrewMember) {
        id = crewMember.id
        name = crewMember.name
        posterPath = crewMember.posterPath
        gender = crewMember.gender
        knownForDepartment = crewMember.knownForDepartment
        
        knownFor = []
        birthday = nil
        deathday = nil
    }
    
    init(personMO: PersonMO) {
        id = Int(personMO.id)
        name = personMO.name ?? ""
        posterPath = personMO.posterImageURL
        gender = Int(personMO.gender)
        knownForDepartment = personMO.knownForDepartment
        
        knownFor = Person.parseKnownForTitlesFromPersonMO(personMO)
        birthday = personMO.birthday
        deathday = personMO.deathday
        
        lastViewedDate = personMO.lastViewedDate
        isHintShown = personMO.isHintShown
        isRevealed = personMO.revealed != nil || personMO.guessed != nil
        correctlyGuessed = personMO.guessed != nil
        isFavorite = personMO.favorite != nil
    }
    
    static private func parseKnownForTitlesFromPersonMO(_ personMO: PersonMO) -> [Title] {
        // parse movies and tv shows person is known for, and add to knownFor.
        var knownForTitles: [Title] = []
        if let knownForMovies = personMO.knownForMovies?.allObjects as? [MovieMO] {
            for knownForMovie in knownForMovies {
                knownForTitles.append(Movie(movieMO: knownForMovie))
            }
        }
        if let knownForTVShows = personMO.knownForTVShows?.allObjects as? [TVShowMO] {
            for knownForTVShow in knownForTVShows {
                knownForTitles.append(TVShow(tvShowMO: knownForTVShow))
            }
        }
        return knownForTitles
    }
}

extension Person: Decodable {
    private enum PersonCodingKeys: String, CodingKey {
        case id
        case name
        case posterPath = "profile_path"
        case gender
        case knownForDepartment = "known_for_department"
        
        case knownFor = "known_for"
        case birthday
        case deathday
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PersonCodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        gender = try container.decodeIfPresent(Int.self, forKey: .gender)
        knownForDepartment = try container.decodeIfPresent(String.self, forKey: .knownForDepartment)
        
        knownFor = try container.decodeIfPresent([MovieOrTVShow].self, forKey: .knownFor) ?? []
        birthday = try container.decodeIfPresent(String.self, forKey: .birthday)
        deathday = try container.decodeIfPresent(String.self, forKey: .deathday)
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


// MARK: - Cast and crew members are person stubs (like when getting credits)

struct CastMember: BasePerson {
    var id: Int
    var type: EntityType = .person
    var name: String
    var posterPath: String?
    var popularity: Double?
    
    var gender: Int?
    var knownForDepartment: String?
    
    // this field is unique to Cast members
    var character: String?
    
    // these properties are unused on castmember, as user is never guessing castmembers.
    var lastViewedDate: Date?
    var isRevealed: Bool = false
    var isHintShown: Bool = false
    var correctlyGuessed: Bool = false
    var isFavorite: Bool = false
}

struct CrewMember: BasePerson {
    var id: Int
    var type: EntityType = .person
    var name: String
    var posterPath: String?
    var popularity: Double?
    
    var gender: Int?
    var knownForDepartment: String?
    
    // these two fields are unique to Crew members
    var department: String?
    var job: String?
    
    // these properties are unused on crewmember, as user is never guessing crewmembers.
    var lastViewedDate: Date?
    var isRevealed: Bool = false
    var isHintShown: Bool = false
    var correctlyGuessed: Bool = false
    var isFavorite: Bool = false
}

extension CastMember: Decodable {
    enum CastMemberCodingKey: String, CodingKey {
        case id
        case name
        case posterPath = "profile_path"
        case popularity
        
        case gender
        case knownForDepartment = "known_for_department"
        
        case character
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CastMemberCodingKey.self)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        popularity = try container.decodeIfPresent(Double.self, forKey: .popularity)
        
        gender = try container.decodeIfPresent(Int.self, forKey: .gender)
        knownForDepartment = try container.decodeIfPresent(String.self, forKey: .knownForDepartment)
        
        character = try container.decodeIfPresent(String.self, forKey: .character)
    }
}

extension CrewMember: Decodable {
    enum CrewMemberCodingKey: String, CodingKey {
        case id
        case name
        case posterPath = "profile_path"
        case popularity
        
        case gender
        case knownForDepartment = "known_for_department"
        
        case department
        case job
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CrewMemberCodingKey.self)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        popularity = try container.decodeIfPresent(Double.self, forKey: .popularity)
        
        gender = try container.decodeIfPresent(Int.self, forKey: .gender)
        knownForDepartment = try container.decodeIfPresent(String.self, forKey: .knownForDepartment)
        
        department = try container.decodeIfPresent(String.self, forKey: .department)
        job = try container.decodeIfPresent(String.self, forKey: .job)
    }
}
