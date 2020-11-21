//
//  Job.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-11-20.
//

import Foundation

typealias Job = String

struct Department {
    let name: String
    let jobs: [Job]
}

extension Department: Decodable {
    private enum DepartmentCodingKeys: String, CodingKey {
        case name = "department"
        case jobs
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DepartmentCodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        jobs = try container.decode([String].self, forKey: .jobs)
    }
}
