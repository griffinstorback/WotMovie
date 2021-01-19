//
//  Entity.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-29.
//

import Foundation

enum EntityType {
    case movie
    case tvShow
    case person
}

protocol Entity {
    var id: Int { get }
    var type: EntityType { get }
    var name: String { get }
    var posterPath: String? { get }
    
    var isHintShown: Bool { get set }
    var isRevealed: Bool { get set }
    var correctlyGuessed: Bool { get set }
}
