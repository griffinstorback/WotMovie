//
//  GuessPresenter.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-14.
//

import Foundation

protocol GuessPresenterProtocol {
    func setViewDelegate(guessViewDelegate: GuessViewDelegate?)
    func getCategoryFor(type: CategoryType) -> GuessCategory?
}

class GuessPresenter: GuessPresenterProtocol {
    private let networkManager: NetworkManagerProtocol
    private let coreDataManager: CoreDataManager
    weak private var guessViewDelegate: GuessViewDelegate?
    
    // categories won't change, except for their 'numberGuessed' property, which changes when a user correctly answers a question somewhere else in app.
    private var categories: [CategoryType: GuessCategory] = [
        .movie: GuessCategory(type: .movie, title: "Guess the movie", shortTitle: "Movies", numberGuessed: 0, imageName: "movie_category_icon"),
        .person: GuessCategory(type: .person, title: "Name the person", shortTitle: "People", numberGuessed: 0, imageName: "person_category_icon"),
        .tvShow: GuessCategory(type: .tvShow, title: "Guess the TV Show", shortTitle: "TV Shows", numberGuessed: 0, imageName: "tv_category_icon"),
        .stats: GuessCategory(type: .stats, title: "See all stats", shortTitle: "Stats", numberGuessed: nil, imageName: "stats_icon")
    ]
    
    init(networkManager: NetworkManagerProtocol = NetworkManager.shared, coreDataManager: CoreDataManager = .shared) {
        self.networkManager = networkManager
        self.coreDataManager = coreDataManager
        
        // TODO: replace this with listener for when counts change in core data.
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.updateGuessedCounts()
        }
        
        /*
        coreDataManager.deleteAllData("Genre")
        coreDataManager.deleteAllData("Movie")
        coreDataManager.deleteAllData("MoviePage")
        coreDataManager.deleteAllData("MovieWatchlist")
         */
    }
    
    func setViewDelegate(guessViewDelegate: GuessViewDelegate?) {
        self.guessViewDelegate = guessViewDelegate
    }
    
    func updateGuessedCounts() {
        // update the 'numberGuessed' property on the categories which display a number guessed count
        categories[.movie]?.numberGuessed = coreDataManager.getNumberGuessedFor(category: .movie)
        categories[.person]?.numberGuessed = coreDataManager.getNumberGuessedFor(category: .person)
        categories[.tvShow]?.numberGuessed = coreDataManager.getNumberGuessedFor(category: .tvShow)
        
        guessViewDelegate?.reloadData()
    }
    
    func getCategoryFor(type: CategoryType) -> GuessCategory? {
        return categories[type]
    }
}
