//
//  EnterGuessPresenter.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-29.
//

import Foundation
import UIKit

protocol EnterGuessViewDelegate: NSObjectProtocol {
    func reloadResults()
}

class EnterGuessPresenter {
    private let networkManager: NetworkManager
    private let imageDownloadManager: ImageDownloadManager
    weak private var enterGuessViewDelegate: EnterGuessViewDelegate?
    
    var searchResults: [Movie] = [] {
        didSet {
            DispatchQueue.main.async {
                self.enterGuessViewDelegate?.reloadResults()
            }
        }
    }
    var searchResultsCount: Int {
        return searchResults.count
    }
    
    init(networkManager: NetworkManager, imageDownloadManager: ImageDownloadManager) {
        self.networkManager = networkManager
        self.imageDownloadManager = imageDownloadManager
    }
    
    func setViewDelegate(_ delegate: EnterGuessViewDelegate) {
        self.enterGuessViewDelegate = delegate
    }
    
    func loadImage(path: String, completion: @escaping (_ image: UIImage?) -> Void) {
        imageDownloadManager.downloadImage(path: path) { image, error in
            if let error = error {
                print(error)
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    func search(searchText: String) {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        networkManager.searchMovies(searchText: searchText) { [weak self] movies, error in
            if let error = error {
                print(error)
                return
            }
            
            if let movies = movies {
                self?.searchResults = movies.reversed()
            }
        }
    }
}
