//
//  GuessPresenter.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-14.
//

import Foundation

protocol GuessViewDelegate: NSObjectProtocol {
    func displayErrorLoadingGenres()
    func presentGuessGridView(for genre: Genre)
    func reloadData()
}

class GuessPresenter {
    private let networkManager: NetworkManager
    weak private var guessViewDelegate: GuessViewDelegate?
    
    private var movieGenres: [Genre] = [] {
        didSet {
            movieGenres.insert(MovieGenre(id: -1, name: "All movies"), at: 0)
            DispatchQueue.main.async {
                self.guessViewDelegate?.reloadData()
            }
        }
    }
    var movieGenresCount: Int {
        return movieGenres.count
    }
    private var tvShowGenres: [Genre] = [] {
        didSet {
            tvShowGenres.insert(TVShowGenre(id: -1, name: "All TV shows"), at: 0)
            DispatchQueue.main.async {
                self.guessViewDelegate?.reloadData()
            }
        }
    }
    var tvShowGenresCount: Int {
        return tvShowGenres.count
    }
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func setViewDelegate(guessViewDelegate: GuessViewDelegate?) {
        self.guessViewDelegate = guessViewDelegate
    }
    
    func loadGenreList() {
        // load movie genres
        networkManager.getMovieGenres { [weak self] genres, error in
            if let error = error {
                self?.movieGenres = []
                DispatchQueue.main.async {
                    self?.guessViewDelegate?.displayErrorLoadingGenres()
                }
            }
            if let genres = genres {
                self?.movieGenres = genres
            }
        }
        
        // load tv show genres
        networkManager.getTVShowGenres { [weak self] genres, error in
            if let error = error {
                self?.tvShowGenres = []
                DispatchQueue.main.async {
                    self?.guessViewDelegate?.displayErrorLoadingGenres()
                }
            }
            if let genres = genres {
                self?.tvShowGenres = genres
            }
        }
    }
    
    func genreForMovie(index: Int) -> Genre {
        return movieGenres[index]
    }
    
    func genreForTVShow(index: Int) -> Genre {
        return tvShowGenres[index]
    }
    
    func showGenreDetail(index: Int, isMovie: Bool) {
        let genre: Genre
        
        if isMovie {
            genre = movieGenres[index]
        } else {
            genre = tvShowGenres[index]
        }
        
        guessViewDelegate?.presentGuessGridView(for: genre)
    }
}
