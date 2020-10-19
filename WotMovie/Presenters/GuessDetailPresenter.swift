//
//  GuessDetailPresenter.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-18.
//

import Foundation

protocol GuessDetailViewDelegate: NSObjectProtocol {
    func displayErrorLoadingDetail()
    func reloadData()
}

class GuessDetailPresenter {
    private let networkManager: NetworkManager
    private let imageDownloadManager: ImageDownloadManager
    weak private var guessDetailViewDelegate: GuessDetailViewDelegate?
    
    private let title: Title
    private let movie: Movie?
    private let tvShow: TVShow?
    
    init(networkManager: NetworkManager, imageDownloadManager: ImageDownloadManager, title: Title) {
        self.networkManager = networkManager
        self.imageDownloadManager = imageDownloadManager
        if title is Movie {
            movie = title as? Movie
            tvShow = nil
            print("MOVIE!")
            print(movie)
        } else if title is TVShow {
            movie = nil
            tvShow = title as? TVShow
            print("TVSHOW!")
            print(tvShow)
        } else {
            movie = nil
            tvShow = nil
        }
        self.title = title
    }
    
    func setViewDelegate(guessDetailViewDelegate: GuessDetailViewDelegate?) {
        self.guessDetailViewDelegate = guessDetailViewDelegate
    }
}
