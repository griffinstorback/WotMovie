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
    func getCountForCategory(index: Int) -> Int
    func loadRecentlyViewed()
    func loadCategoryCounts()
    func getNumberOfRecentlyViewed() -> Int
    func getRecentlyViewedFor(index: Int) -> Entity
    func loadImageFor(index: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void)
}

class ListPresenter: ListPresenterProtocol {
    private let imageDownloadManager: ImageDownloadManagerProtocol
    private let coreDataManager: CoreDataManager
    weak var listViewDelegate: ListViewDelegate?
    
    private var categoryTableViewRows: [ListCategory] = [
        ListCategory(type: .movieOrTvShowWatchlist, title: "Watchlist", imageName: "add_to_watchlist_icon", count: 0),
        ListCategory(type: .personFavorites, title: "Favorites", imageName: "add_to_favorites_icon", count: 0),
        ListCategory(type: .allGuessed, title: "Guessed", imageName: "guessed_correct_bounded", count: 0),
        ListCategory(type: .allRevealed, title: "Revealed", imageName: "question_mark_bounded", count: 0),
    ] {
        didSet {
            DispatchQueue.main.async {
                self.listViewDelegate?.reloadCategoryListData()
            }
        }
    }
    
    private var recentlyViewedItems: [Entity] = [] {
        didSet {
            DispatchQueue.main.async {
                self.listViewDelegate?.reloadRecentlyViewedData()
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
    
    func getCountForCategory(index: Int) -> Int {
        return categoryTableViewRows[index].count
    }
    
    func loadRecentlyViewed() {
        // TODO: perform this request on background thread. As of now, there is a noticeable delay when pressing list tab.
        let items = coreDataManager.fetchPageOfRecentlyViewed()
        recentlyViewedItems = items
    }
    
    func loadCategoryCounts() {
        for i in 0..<categoryTableViewRows.count {
            categoryTableViewRows[i].count = coreDataManager.getCountForListCategory(listCategory: categoryTableViewRows[i].type)
        }
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
