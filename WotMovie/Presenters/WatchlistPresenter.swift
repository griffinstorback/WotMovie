//
//  WatchlistPresenter.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-01-23.
//

import Foundation
import UIKit

protocol WatchlistPresenterProtocol {
    func setViewDelegate(_ viewDelegate: WatchlistViewDelegate)
    func getWatchlistCategoriesCount() -> Int
    func getWatchlistCategoryFor(index: Int) -> WatchlistCategory
    func loadRecentlyViewed()
    func getNumberOfRecentlyViewed() -> Int
    func getRecentlyViewedFor(index: Int) -> Entity
    func getItemCountForCategory(category: WatchlistCategoryType) -> Int
    func loadImageFor(index: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void)
}

class WatchlistPresenter: WatchlistPresenterProtocol {
    private let imageDownloadManager: ImageDownloadManagerProtocol
    private let coreDataManager: CoreDataManager
    weak var watchlistViewDelegate: WatchlistViewDelegate?
    
    private let categoryTableViewRows: [WatchlistCategory] = [
        WatchlistCategory(type: .movieOrTvShowWatchlist, title: "Watchlist", imageName: "watchlist_icon"),
        WatchlistCategory(type: .personFavorites, title: "Favorites", imageName: "favorites_icon"),
        WatchlistCategory(type: .allGuessed, title: "Guessed", imageName: "guessed_correct_icon"),
        WatchlistCategory(type: .allRevealed, title: "Revealed", imageName: "question_mark"),
        
        // TODO: Decide if search should be allowed. Because it would easily allow for cheating,
        //       though of course people could cheat anyways, but this would make it a lot easier,
        //       and might even serve to promote it.
        //WatchlistCategory(title: "Search Movies, TV Shows, and people", imageName: "question_mark")
    ]
    
    private var recentlyViewedNextPage = 1
    private var recentlyViewedItems: [Entity] = [] {
        didSet {
            DispatchQueue.main.async {
                self.watchlistViewDelegate?.reloadData()
            }
        }
    }
    
    init(imageDownloadManager: ImageDownloadManager = ImageDownloadManager.shared,
            coreDataManager: CoreDataManager = CoreDataManager.shared) {
        self.imageDownloadManager = imageDownloadManager
        self.coreDataManager = coreDataManager
    }
    
    func setViewDelegate(_ viewDelegate: WatchlistViewDelegate) {
        self.watchlistViewDelegate = viewDelegate
    }
    
    func getWatchlistCategoriesCount() -> Int {
        return categoryTableViewRows.count
    }
    
    func getWatchlistCategoryFor(index: Int) -> WatchlistCategory {
        return categoryTableViewRows[index]
    }
    
    func getItemCountForCategory(category: WatchlistCategoryType) -> Int {
        switch category {
        case .movieOrTvShowWatchlist:
            return coreDataManager.fetchWatchlistCount()
        case .personFavorites:
            break
        case .allGuessed:
            break
        case .allRevealed:
            break
        }
        
        return -1
    }
    
    func loadRecentlyViewed() {
        let items = coreDataManager.fetchPageOfRecentlyViewed()
        recentlyViewedItems += items
        recentlyViewedNextPage += 1
        
        print("*** number on watchlist: \(getItemCountForCategory(category: .movieOrTvShowWatchlist))")
    }
    
    func getNumberOfRecentlyViewed() -> Int {
        return recentlyViewedItems.count
    }
    
    func getRecentlyViewedFor(index: Int) -> Entity {
        return recentlyViewedItems[index]
    }
    
    func loadImageFor(index: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void) {
        let item = recentlyViewedItems[index]
        
        if let posterPath = item.posterPath {
            imageDownloadManager.downloadImage(path: posterPath) { image, error in
                if let error = error {
                    print(error)
                    DispatchQueue.main.async {
                        completion(nil, nil)
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    completion(image, posterPath)
                }
            }
        } else {
            DispatchQueue.main.async {
                completion(nil, nil)
            }
        }
    }
}
