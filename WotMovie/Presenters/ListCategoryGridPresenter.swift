//
//  ListCategoryGridPresenter.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-01-26.
//

import Foundation
import UIKit

protocol ListCategoryGridPresenterProtocol {
    var listCategoryType: ListCategoryType { get }
    var itemsCount: Int { get }
    func loadItems()
    func setViewDelegate(_ listCategoryGridViewDelegate: ListCategoryGridViewDelegate?)
    func itemFor(index: Int) -> Entity
    func loadImageFor(index: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void)
}

// TODO: Should make all presenters conform to a BasePresenter class, which should contain
//       methods all presenters (or most) use like loadImageFor(index).
class ListCategoryGridPresenter: ListCategoryGridPresenterProtocol {
    private let imageDownloadManager: ImageDownloadManagerProtocol
    private let coreDataManager: CoreDataManager
    weak var listCategoryGridViewDelegate: ListCategoryGridViewDelegate?
    
    let listCategoryType: ListCategoryType
    
    private var items: [Entity] = [] {
        didSet {
            DispatchQueue.main.async {
                self.listCategoryGridViewDelegate?.reloadData()
            }
        }
    }
    var itemsCount: Int {
        return items.count
    }
    
    init(imageDownloadManager: ImageDownloadManagerProtocol = ImageDownloadManager.shared,
         coreDataManager: CoreDataManager = CoreDataManager.shared,
         listCategoryType: ListCategoryType) {
        self.imageDownloadManager = imageDownloadManager
        self.coreDataManager = coreDataManager
        
        self.listCategoryType = listCategoryType
        
    }
    
    func loadItems() {
        getNextPageFromCoreData()
    }
    
    func setViewDelegate(_ listCategoryGridViewDelegate: ListCategoryGridViewDelegate?) {
        self.listCategoryGridViewDelegate = listCategoryGridViewDelegate
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
        switch listCategoryType {
        case .movieOrTvShowWatchlist:
            let items = coreDataManager.fetchWatchlist(genreID: -1)
            self.items = items
        case .personFavorites:
            let items = coreDataManager.fetchFavoritePeople()
            self.items = items
        case .allGuessed:
            let items = coreDataManager.fetchGuessedEntities()
            self.items = items
        case .allRevealed:
            let items = coreDataManager.fetchRevealedEntities()
            self.items = items
        }
    }
}
