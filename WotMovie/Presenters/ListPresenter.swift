//
//  ListPresenter.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-01-23.
//

import Foundation
import UIKit

protocol ListPresenterProtocol: TransitionPresenterProtocol {
    func setViewDelegate(_ viewDelegate: ListViewDelegate)
    func getListCategoriesCount() -> Int
    func getListCategoryFor(index: Int) -> ListCategory
    func getCountForCategory(index: Int) -> Int
    func loadRecentlyViewed()
    func loadCategoryCounts()
    func getNumberOfRecentlyViewed() -> Int
    func getRecentlyViewedFor(index: Int) -> Entity
    func loadImageFor(index: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void)
    
    func addItemToWatchlistOrFavorites(_ indexPath: IndexPath)
    func removeItemFromWatchlistOrFavorites(_ indexPath: IndexPath)
}

class ListPresenter: NSObject, ListPresenterProtocol {
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
    
    // have separate setter so we can reload the view when set, but also do operations without reloading view (like setting item as favorite)
    private func setRecentlyViewedItems(items: [Entity]) {
        recentlyViewedItems = items
        
        DispatchQueue.main.async {
            self.listViewDelegate?.reloadRecentlyViewedData()
        }
    }
    private var recentlyViewedItems: [Entity] = []
    
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
    
    let numberOfRecentlyViewedToDisplay: Int = 60
    var firstLoad: Bool = true
    func loadRecentlyViewed() {
        // Should use the async method for first load, then sync method as it needs to be there as soon as possible
        // (using async to update means the user will see a flash after tab has ostensibly loaded)
        
        // TODO: cache query (using nsfetchedresultscontroller?) so sync method runs faster
        if firstLoad {
            loadRecentlyViewedAsync()
            firstLoad = false
        } else {
            loadRecentlyViewedSync()
        }
    }
    
    private func loadRecentlyViewedAsync() {
        DispatchQueue.global().async {
            self.coreDataManager.backgroundFetchRecentlyViewed(limit: self.numberOfRecentlyViewedToDisplay) { [weak self] entities in
                if let items = entities, let amount = self?.numberOfRecentlyViewedToDisplay {
                    let sortedItems = items.sorted { $0.lastViewedDate ?? Date.distantPast > $1.lastViewedDate ?? Date.distantPast }
                    self?.setRecentlyViewedItems(items: Array(sortedItems.prefix(amount)))
                } else {
                    print("** ERROR retrieving recently viewed asynchronously")
                }
            }
        }
    }
    private func loadRecentlyViewedSync() {
        let items = coreDataManager.fetchPageOfRecentlyViewed(limit: numberOfRecentlyViewedToDisplay).sorted { $0.lastViewedDate ?? Date.distantPast > $1.lastViewedDate ?? Date.distantPast }
        setRecentlyViewedItems(items: Array(items.prefix(numberOfRecentlyViewedToDisplay)))
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
    
    func addItemToWatchlistOrFavorites(_ indexPath: IndexPath) {
        let index = indexPath.row
        guard index < recentlyViewedItems.count else { return }
        
        coreDataManager.addEntityToWatchlistOrFavorites(entity: recentlyViewedItems[index])
        recentlyViewedItems[index].isFavorite = true
    }
    
    func removeItemFromWatchlistOrFavorites(_ indexPath: IndexPath) {
        let index = indexPath.row
        guard index < recentlyViewedItems.count else { return }
        
        coreDataManager.removeEntityFromWatchlistOrFavorites(entity: recentlyViewedItems[index])
        recentlyViewedItems[index].isFavorite = false
    }
}

// TransitionPresenterProtocol - called when dismissing modal detail (if item was revealed/added to watchlist while modal was up)
extension ListPresenter {
    func setEntityAsRevealed(id: Int, isCorrect: Bool) {
        if let index = recentlyViewedItems.firstIndex(where: { $0.id == id }) {
            if isCorrect { // if entity was correctly guessed
                if !recentlyViewedItems[index].correctlyGuessed {
                    recentlyViewedItems[index].correctlyGuessed = true
                    DispatchQueue.main.async {
                        self.listViewDelegate?.revealCorrectlyGuessedEntities(at: [index])
                    }
                }
            } else { // if entity was revealed (user gave up)
                if !recentlyViewedItems[index].isRevealed {
                    recentlyViewedItems[index].isRevealed = true
                    DispatchQueue.main.async {
                        self.listViewDelegate?.revealEntities(at: [index])
                    }
                }
            }
        }
    }
    
    // either add entity to watchlist/favorites, or remove it.
    func setEntityAsFavorite(id: Int, entityWasAdded: Bool) {
        if let index = recentlyViewedItems.firstIndex(where: { $0.id == id }) {
            if entityWasAdded {
                recentlyViewedItems[index].isFavorite = true
            } else { // entity was removed from favorites/watchlist
                recentlyViewedItems[index].isFavorite = false
            }
        }
    }
    
    func presentNextQuestion(currentQuestionID: Int) {
        // nothing - there shouldn't be a Next question button displayed for details opened from recently viewed.
    }
}
