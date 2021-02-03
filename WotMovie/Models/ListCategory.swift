//
//  ListCategory.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-01-25.
//

import Foundation

// Used for table view at top of List (see ListPresenter)
struct ListCategory {
    let type: ListCategoryType
    let title: String
    let imageName: String
}

enum ListCategoryType {
    case movieOrTvShowWatchlist
    case personFavorites
    case allGuessed
    case allRevealed
}
