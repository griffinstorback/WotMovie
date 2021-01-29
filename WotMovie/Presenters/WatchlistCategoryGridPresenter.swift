//
//  WatchlistCategoryGridPresenter.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-01-26.
//

import Foundation
import UIKit

protocol WatchlistCategoryGridPresenterProtocol {
    var watchlistCategoryType: WatchlistCategoryType { get }
    var itemsCount: Int { get }
    func loadItems()
    func setViewDelegate(_ watchlistCategoryGridViewDelegate: WatchlistCategoryGridViewDelegate?)
    func itemFor(index: Int) -> Entity
    func loadImageFor(index: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void)
}

// TODO: Should make all presenters conform to a BasePresenter class, which should contain
//       methods all presenters (or most) use like loadImageFor(index).
class WatchlistCategoryGridPresenter: WatchlistCategoryGridPresenterProtocol {
    private let imageDownloadManager: ImageDownloadManagerProtocol
    private let coreDataManager: CoreDataManager
    weak var watchlistCategoryGridViewDelegate: WatchlistCategoryGridViewDelegate?
    
    let watchlistCategoryType: WatchlistCategoryType
    
    private var items: [Entity] = [] {
        didSet {
            DispatchQueue.main.async {
                self.watchlistCategoryGridViewDelegate?.reloadData()
            }
        }
    }
    var itemsCount: Int {
        return items.count
    }
    
    init(imageDownloadManager: ImageDownloadManagerProtocol = ImageDownloadManager.shared,
         coreDataManager: CoreDataManager = CoreDataManager.shared,
         watchlistCategoryType: WatchlistCategoryType) {
        self.imageDownloadManager = imageDownloadManager
        self.coreDataManager = coreDataManager
        
        self.watchlistCategoryType = watchlistCategoryType
        
    }
    
    func loadItems() {
        getNextPageFromCoreData()
    }
    
    func setViewDelegate(_ watchlistCategoryGridViewDelegate: WatchlistCategoryGridViewDelegate?) {
        self.watchlistCategoryGridViewDelegate = watchlistCategoryGridViewDelegate
    }
    
    func itemFor(index: Int) -> Entity {
        return items[index]
    }
    
    func loadImageFor(index: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void) {
        let item = items[index]
        
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
    
    private func getNextPageFromCoreData() {
        switch watchlistCategoryType {
        case .movieOrTvShowWatchlist:
            let items = coreDataManager.fetchWatchlistPage(genreID: -1)
            print("*** items returned from fetchWatchlistPage: \(items)")
            self.items = items
        case .personFavorites:
            break
        case .allGuessed:
            break
        }
    }
}
