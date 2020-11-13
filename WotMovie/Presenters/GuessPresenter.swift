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
    
    let categories: [GuessCategory] = [
        GuessCategory(type: .movie, title: "Guess the movie", shortTitle: "Movies", numberGuessed: 7, imageName: "movie_category_icon"),
        GuessCategory(type: .person, title: "Name the person", shortTitle: "People", numberGuessed: 0, imageName: "person_category_icon"),
        GuessCategory(type: .tvShow, title: "Guess the TV Show", shortTitle: "TV Shows", numberGuessed: 0, imageName: "tv_category_icon"),
        GuessCategory(type: .stats, title: "See all stats", shortTitle: "Stats", numberGuessed: nil, imageName: "question_mark")
    ]
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func setViewDelegate(guessViewDelegate: GuessViewDelegate?) {
        self.guessViewDelegate = guessViewDelegate
    }
}
