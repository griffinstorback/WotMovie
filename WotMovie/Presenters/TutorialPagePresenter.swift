//
//  TutorialPagePresenter.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-04-23.
//

import Foundation

protocol TutorialPagePresenterProtocol {
    func setViewDelegate(_ delegate: TutorialPageViewDelegate?)
    
    func getDetailViewIdentifier(for index: Int) -> TutorialPageDetailViewType
    func getDetailViewCount() -> Int
    
    func getTitleTextFor(type: TutorialPageDetailViewType) -> String
    func getBodyTextFor(type: TutorialPageDetailViewType) -> String
    func getImageNameFor(type: TutorialPageDetailViewType) -> String
}

enum TutorialPageDetailViewType: String {
    case guessAndReveal = "Guess and Reveal"
    case enterGuess = "Entering Guesses"
    case genres = "Genres"
    case browseAndSearch = "Browse and Search"
    case watchlistAndFavorites = "Watchlist and Favorites"
    case unlockPeople = "Unlock People"
}

class TutorialPagePresenter: TutorialPagePresenterProtocol {
    weak var tutorialPageViewDelegate: TutorialPageViewDelegate?
    
    let orderedDetailViews: [TutorialPageDetailViewType] = [
        .guessAndReveal,
        .enterGuess,
        .genres,
        .browseAndSearch,
        .watchlistAndFavorites,
        .unlockPeople
    ]
    
    init() { }
    
    func setViewDelegate(_ delegate: TutorialPageViewDelegate?) {
        self.tutorialPageViewDelegate = delegate
    }
    
    func getDetailViewIdentifier(for index: Int) -> TutorialPageDetailViewType {
        guard index >= 0, index < orderedDetailViews.count else {
            print("** ERROR: index out of bounds in TutorialPagePresenter")
            return .guessAndReveal
        }
        
        return orderedDetailViews[index]
    }
    
    func getDetailViewCount() -> Int {
        return orderedDetailViews.count
    }
    
    func getTitleTextFor(type: TutorialPageDetailViewType) -> String {
        switch type {
        case .guessAndReveal:
            return "Welcome to WotMovie"
        case .enterGuess:
            return "Guessing"
        case .genres:
            return "Genres"
        case .browseAndSearch:
            return "Browse and Search"
        case .watchlistAndFavorites:
            return "Watchlist"
        case .unlockPeople:
            return "Unlock People"
        }
    }
    
    func getBodyTextFor(type: TutorialPageDetailViewType) -> String {
        switch type {
        case .guessAndReveal:
            return "Movie trivia and content discovery, all in one"
        case .enterGuess:
            return "Begin entering the name, and select the correct answer"
        case .genres:
            return "Guess and discover from your favorite genres"
        case .browseAndSearch:
            return "Easily browse and search Movie, TV Show, and Person details"
        case .watchlistAndFavorites:
            return "Build a watchlist as you discover new Movies and TV Shows"
        case .unlockPeople:
            return "Guess or Reveal 500 Movies and TV Shows to unlock the People category"
        }
    }
    
    func getImageNameFor(type: TutorialPageDetailViewType) -> String {
        switch type {
        case .guessAndReveal:
            return "movie_category_icon"
        case .enterGuess:
            return "enter_guess_example"
        case .genres:
            return "genres_example_image"
        case .browseAndSearch:
            return "browse_and_search_example"
        case .watchlistAndFavorites:
            return "add_to_watchlist_icon"
        case .unlockPeople:
            return "person_category_icon"
        }
    }
}
