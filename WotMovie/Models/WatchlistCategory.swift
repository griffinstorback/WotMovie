//
//  WatchlistCategory.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-01-25.
//

import Foundation

// Used for table view at top of Watchlist (see WatchlistPresenter)
struct WatchlistCategory {
    let type: WatchlistCategoryType
    let title: String
    let imageName: String
}

enum WatchlistCategoryType {
    case movieOrTvShowWatchlist
    case personFavorites
    case allGuessed
    case allRevealed
}
