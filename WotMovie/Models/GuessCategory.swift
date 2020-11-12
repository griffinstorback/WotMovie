//
//  GuessCategory.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-11-05.
//

import Foundation

struct GuessCategory {
    let type: CategoryType
    
    let title: String
    let shortTitle: String
    
    // numberGuessed is nil if category isn't leading to guess grid - e.g. "see stats button"
    let numberGuessed: Int?
    let imageName: String
}

enum CategoryType {
    case movie
    case person
    case tvShow
    case stats
}
