//
//  GuessGridViewControllerMock.swift
//  WotMovieTests
//
//  Created by Griffin Storback on 2021-02-12.
//

import Foundation
@testable import WotMovie

class GuessGridViewControllerMock: NSObject, GuessGridViewDelegate {
    // number of times functions are called
    var displayItemsCalledCount = 0
    var displayErrorLoadingItemsCalledCount = 0
    var reloadDataCalledCount = 0
    var numberOfItemsPerRowCalledCount = 0
    var revealEntitiesCalledCount = 0
    var revealCorrectlyGuessedEntitiesCalledCount = 0
    
    let numberOfRows: Int
    
    init(numberOfRows: Int = 3) {
        self.numberOfRows = numberOfRows
    }
    
    func displayItems() {
        displayItemsCalledCount += 1
    }
    
    func displayErrorLoadingItems() {
        displayErrorLoadingItemsCalledCount += 1
    }
    
    func reloadData() {
        reloadDataCalledCount += 1
    }
    
    func numberOfItemsPerRow() -> Int {
        numberOfItemsPerRowCalledCount += 1
        
        return numberOfRows
    }
    
    func revealEntities(at indices: [Int]) {
        revealEntitiesCalledCount += 1
    }
    
    func revealCorrectlyGuessedEntities(at indices: [Int]) {
        revealCorrectlyGuessedEntitiesCalledCount += 1
    }
}
