//
//  ListPresenter.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-01-23.
//

import Foundation
import UIKit

protocol ListPresenterProtocol {
    func setViewDelegate(_ viewDelegate: ListViewDelegate)
    func getListCategoriesCount() -> Int
    func getListCategoryFor(index: Int) -> ListCategory
    func loadRecentlyViewed()
    func getNumberOfRecentlyViewed() -> Int
    func getRecentlyViewedFor(index: Int) -> Entity
    func getItemCountForCategory(category: ListCategoryType) -> Int
    func loadImageFor(index: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void)
}

class ListPresenter: ListPresenterProtocol {
    private let imageDownloadManager: ImageDownloadManagerProtocol
    private let coreDataManager: CoreDataManager
    weak var listViewDelegate: ListViewDelegate?
    
    private let categoryTableViewRows: [ListCategory] = [
        ListCategory(type: .movieOrTvShowWatchlist, title: "Watchlist", imageName: "watchlist_icon"),
        ListCategory(type: .personFavorites, title: "Favorites", imageName: "favorites_icon"),
        ListCategory(type: .allGuessed, title: "Guessed", imageName: "guessed_correct_icon"),
        ListCategory(type: .allRevealed, title: "Revealed", imageName: "question_mark"),
        
        // TODO: Decide if search should be allowed. Because it would easily allow for cheating,
        //       though of course people could cheat anyways, but this would make it a lot easier,
        //       and might even serve to promote it.
        //ListCategory(title: "Search Movies, TV Shows, and people", imageName: "question_mark")
    ]
    
    private var recentlyViewedNextPage = 1
    private var recentlyViewedItems: [Entity] = [] {
        didSet {
            DispatchQueue.main.async {
                self.listViewDelegate?.reloadData()
            }
        }
    }
    
    init(imageDownloadManager: ImageDownloadManager = ImageDownloadManager.shared,
            coreDataManager: CoreDataManager = CoreDataManager.shared) {
        self.imageDownloadManager = imageDownloadManager
        self.coreDataManager = coreDataManager
    }
    
    func setViewDelegate(_ viewDelegate: ListViewDelegate) {
        self.listViewDelegate = viewDelegate
    }
    
    func getListCategoriesCount() -> Int {
        return categoryTableViewRows.count
    }
    
    func getListCategoryFor(index: Int) -> ListCategory {
        return categoryTableViewRows[index]
    }
    
    func getItemCountForCategory(category: ListCategoryType) -> Int {
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
