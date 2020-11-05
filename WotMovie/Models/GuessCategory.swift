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
    let numberGuessed: Int?
    let imageName: String
    
    var subtitle: String? {
        if let numberGuessed = numberGuessed {
            return "\(numberGuessed) " + "guessed correctly"
        } else {
            return nil
        }
    }
}

enum CategoryType {
    case movie
    case person
    case tvShow
    case stats
}
