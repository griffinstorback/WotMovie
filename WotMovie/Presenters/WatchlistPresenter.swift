//
//  WatchlistPresenter.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-01-23.
//

import Foundation

protocol WatchlistPresenterProtocol {
    
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
