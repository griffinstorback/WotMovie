//
//  GuessGridPresenter.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-15.
//

import Foundation
import UIKit

protocol GuessGridPresenterProtocol {
    var guessGridViewDelegate: GuessGridViewDelegate? { get set }
    var category: CategoryType { get }
    var itemsCount: Int { get }

    func setViewDelegate(guessGridViewDelegate: GuessGridViewDelegate?)
    func itemFor(index: Int) -> Entity
    func loadImageFor(index: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void) // this is used in multiple files - extractable?

    func loadItems()
}

class GuessGridPresenter: GuessGridPresenterProtocol {
    private let networkManager: NetworkManager
    private let imageDownloadManager: ImageDownloadManager
    private let coreDataManager: CoreDataManager
    weak var guessGridViewDelegate: GuessGridViewDelegate?
    
    let category: CategoryType
    private var nextPage = 1
    
    private var items: [Entity] = [] {
        didSet {
            DispatchQueue.main.async {
                self.guessGridViewDelegate?.reloadData()
            }
        }
    }
    var itemsCount: Int {
        return items.count
    }
    
    // filter out entities user has guessed on already, as well as undesirables (e.g. movie with no overview)
    private func setItems(_ items: [Entity]) {
        var newItems = items
        
        if let movies = newItems as? [Movie] {
            newItems = movies.filter { !$0.overview.isEmpty }
            print("Movie objects with nil overview: ", movies.filter { $0.overview.isEmpty })
        } else if let tvShows = newItems as? [TVShow] {
            newItems = tvShows.filter { !$0.overview.isEmpty }
            print("TV objects with nil posterPath: ", tvShows.filter { $0.overview.isEmpty })
        } else if let people = newItems as? [Person] {
            
            // TODO? : Filter out any Person object with undesirable attributes
            
            //newItems = people.filter { $0.posterPath != nil }
            //print("Person objects with nil posterPath: ", people.filter { $0.posterPath == nil })
        }
        
        // remove titles without a poster image
        newItems = newItems.filter { $0.posterPath != nil }
        
        self.items += newItems
    }
    
    init(networkManager: NetworkManager = .shared, imageDownloadManager: ImageDownloadManager = .shared, coreDataManager: CoreDataManager = .shared, category: CategoryType) {
        self.networkManager = networkManager
        self.imageDownloadManager = imageDownloadManager
        self.coreDataManager = coreDataManager
        self.category = category
    }
    
    func setViewDelegate(guessGridViewDelegate: GuessGridViewDelegate?) {
        self.guessGridViewDelegate = guessGridViewDelegate
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

    func loadItems() {
        if category == .movie {
            networkManager.getListOfMoviesByGenre(id: -1, page: nextPage) { [weak self] movies, error in
                if let error = error {
                    print(error)
                    
                    // TODO: Error sometimes is just the page not loading for some reason. Got a 500 error once just for one page.
                    //       Should re-attempt the next page (just once)
                    //self?.nextPage += 1
                    
                    return
                }
                if let movies = movies {
                    self?.setItems(movies)
                    //self?.items += movies
                    self?.nextPage += 1
                }
            }
        } else if category == .tvShow {
            networkManager.getListOfTVShowsByGenre(id: -1, page: nextPage) { [weak self] tvShows, error in
                if let error = error {
                    print(error)
                    
                    // TODO: Error sometimes is just the page not loading for some reason. Got a 500 error once just for one page.
                    //       Should re-attempt the next page (just once)
                    //self?.nextPage += 1
                    
                    return
                }
                if let tvShows = tvShows {
                    self?.setItems(tvShows)
                    //self?.items += tvShows
                    self?.nextPage += 1
                }
            }
        } else if category == .person {
            networkManager.getPopularPeople(page: nextPage) { [weak self] people, error in
                if let error = error {
                    print(error)
                    
                    // TODO: Error sometimes is just the page not loading for some reason. Got a 500 error once just for one page.
                    //       Should re-attempt the next page (just once)
                    //self?.nextPage += 1
                    
                    return
                }
                if let people = people {
                    self?.setItems(people)
                    //self?.items += people
                    self?.nextPage += 1
                }
            }
        }
    }
}
