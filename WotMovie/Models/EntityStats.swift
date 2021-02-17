//
//  EntityStats.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-02-16.
//

import Foundation

struct EntityStats {
    let numberOfStatRows = 4
    let type: EntityType
    
    var totalGuessed = 0
    var guessedWithoutHint = 0
    var guessedWithHint = 0
    var totalRevealed = 0
    
    init(type: EntityType) {
        self.type = type
        
        // switch on type, make numberOfStatRows custom to each type
    }
    
    func getEntityTypeName() -> String {
        switch type {
        case .movie:
            return "Movies"
        case .tvShow:
            return "TV Shows"
        case .person:
            return "People"
        }
    }
    
    func getNameForStatTypeAtIndex(index: Int) -> String {
        switch index {
        case 0:
            return "Total Guessed"
        case 1:
            return "Guessed without hint"
        case 2:
            return "Guessed with hint"
        case 3:
            return "Revealed"
        default:
            return ""
        }
    }
    
    func getCountForStatTypeAt(index: Int) -> Int {
        switch index {
        case 0:
            return totalGuessed
        case 1:
            return guessedWithoutHint
        case 2:
            return guessedWithHint
        case 3:
            return totalRevealed
        default:
            return 0
        }
    }
    
    func getIndentLevelForStatTypeAt(index: Int) -> Int {
        switch index {
        case 0: // totalGuessed
            return 0
        case 1: // guessedWithoutHint
            return 1
        case 2: // guessedWithHint
            return 1
        case 3: // totalRevealed
            return 0
        default:
            return 0
        }
    }
}
