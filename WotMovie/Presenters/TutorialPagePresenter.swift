//
//  TutorialPagePresenter.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-04-23.
//

import Foundation

protocol TutorialPagePresenterProtocol {
    func setViewDelegate(_ delegate: TutorialPageViewDelegate?)
    
    func getDetailViewIdentifier(for index: Int) -> String
    func getDetailViewCount() -> Int
}

class TutorialPagePresenter: TutorialPagePresenterProtocol {
    weak var tutorialPageViewDelegate: TutorialPageViewDelegate?
    
    let orderedDetailViews: [String] = [
        "guess&reveal",
        "genres",
        "browse&search",
        "watchlist&favorites",
        "people"
    ]
    
    init() {
        
    }
    
    func setViewDelegate(_ delegate: TutorialPageViewDelegate?) {
        self.tutorialPageViewDelegate = delegate
    }
    
    func getDetailViewIdentifier(for index: Int) -> String {
        guard index >= 0, index < orderedDetailViews.count else {
            return ""
        }
        
        return orderedDetailViews[index]
    }
    
    func getDetailViewCount() -> Int {
        return orderedDetailViews.count
    }
}
