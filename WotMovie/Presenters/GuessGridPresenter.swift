//
//  GuessGridPresenter.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-15.
//

import Foundation
import UIKit

protocol GuessGridViewDelegate: NSObjectProtocol {
    func displayTitles()
    func displayErrorLoadingTitles()
    func presentGuessTitleDetail(for title: Title)
    func reloadData()
}

class GuessGridPresenter {
    private let networkManager: NetworkManager
    private let imageDownloadManager: ImageDownloadManager
    weak private var guessGridViewDelegate: GuessGridViewDelegate?
    
    private let genre: Genre
    private var nextPage = 1
    
    private var titles: [Title] = [] {
        didSet {
            DispatchQueue.main.async {
                self.guessGridViewDelegate?.reloadData()
            }
        }
    }
    var titlesCount: Int {
        return titles.count
    }
    
    init(networkManager: NetworkManager, imageDownloadManager: ImageDownloadManager, genre: Genre) {
        self.networkManager = networkManager
        self.imageDownloadManager = imageDownloadManager
        self.genre = genre
    }
    
    func setViewDelegate(guessGridViewDelegate: GuessGridViewDelegate?) {
        self.guessGridViewDelegate = guessGridViewDelegate
    }
    
    func titleFor(index: Int) -> Title {
        return titles[index]
    }
    
    func loadImageFor(index: Int, completion: @escaping (_ image: UIImage?) -> Void) {
        let title = titles[index]
        imageDownloadManager.downloadImage(path: title.posterPath ?? "") { image, error in
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
    
    func loadTitles() {
        if genre.isMovie {
            networkManager.getListOfMoviesByGenre(id: genre.id, page: nextPage) { [weak self] movies, error in
                if let error = error {
                    print(error)
                    return
                }
                if let movies = movies {
                    self?.titles += movies
                    self?.nextPage += 1
                }
            }
        } else {
            networkManager.getListOfTVShowsByGenre(id: genre.id, page: nextPage) { [weak self] tvShows, error in
                if let error = error {
                    print(error)
                    return
                }
                if let tvShows = tvShows {
                    self?.titles += tvShows
                    self?.nextPage += 1
                }
            }
        }
    }
    
    func showGuessDetail(index: Int) {
        let title = titles[index]
        guessGridViewDelegate?.presentGuessTitleDetail(for: title)
    }
}
