//
//  SortParameters.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-02-09.
//

import Foundation

enum SortBy: String, CaseIterable {
    case dateAdded = "Date added"
    case alphabetical = "Alphabetical"
    case releaseDate = "Release date"
}

struct SortParameters {
    // the list type e.g. "Watching", "Favorites", "Revealed" etc.
    let listCategoryType: ListCategoryType
    
    // the types being displayed e.g. "Movies", "People", "Movies & TV", etc.
    var displayingTypes: ListCategoryDisplayTypes
    
    var sortBy: SortBy {
        didSet {
            // type 'Person' has no 'releaseDate', so if sorting by release date, filter out people.
            if sortBy == .releaseDate {
                if displayingTypes == .all || displayingTypes == .people {
                    displayingTypes = .moviesAndTVShows
                }
            }
        }
    }
    
    // get default sort parameters for a given ListCategoryType.
    init(categoryType: ListCategoryType) {
        listCategoryType = categoryType
        
        switch categoryType {
        case .allGuessed:
            self.displayingTypes = .all
        case .allRevealed:
            self.displayingTypes = .all
        case .movieOrTvShowWatchlist:
            self.displayingTypes = .moviesAndTVShows
        case .personFavorites:
            self.displayingTypes = .people
        }
        
        self.sortBy = .dateAdded
    }
}
