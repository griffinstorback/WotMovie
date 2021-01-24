//
//  WatchlistPresenter.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-01-23.
//

import Foundation

protocol WatchlistPresenterProtocol {
    // func GET_CATEGORY_ROW_FOR e.g "Favorites" with favorites.png as img.
    // func GET_RECENTLY_VIEWED_TITLE (just returns localized version of "Recently viewed")
    // func GET_RECENTLY_VIEWED_ITEM_FOR index - pagination with core data for recently viewed items.
    func setViewDelegate(_ viewDelegate: WatchlistViewDelegate)
}

class WatchlistPresenter: WatchlistPresenterProtocol {
    private let imageDownloadManager: ImageDownloadManagerProtocol
    private let coreDataManager: CoreDataManagerProtocol
    weak var watchlistViewDelegate: WatchlistViewDelegate?
    
    init(imageDownloadManager: ImageDownloadManager = ImageDownloadManager.shared,
            coreDataManager: CoreDataManager = CoreDataManager.shared) {
        self.imageDownloadManager = imageDownloadManager
        self.coreDataManager = coreDataManager
    }
    
    func setViewDelegate(_ viewDelegate: WatchlistViewDelegate) {
        self.watchlistViewDelegate = viewDelegate
    }
}
