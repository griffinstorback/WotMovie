//
//  GuessGridPresenterTests.swift
//  WotMovieTests
//
//  Created by Griffin Storback on 2021-02-12.
//

import XCTest
@testable import WotMovie

class GuessGridPresenterTests: XCTestCase {
    
    // sut
    var guessGridPresenter: GuessGridPresenter!
    
    // conforms to GuessGridViewDelegate
    var guessGridViewDelegate: GuessGridViewControllerMock!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // sut
        guessGridPresenter = GuessGridPresenter(networkManager: NetworkManagerMock(), imageDownloadManager: ImageDownloadManagerMock(), coreDataManager: CoreDataManager.shared, category: .movie)
        
        guessGridViewDelegate = GuessGridViewControllerMock(numberOfRows: 4)
        
        // set the mock guessgrid view delegate as view delegate on presenter
        guessGridPresenter.setViewDelegate(guessGridViewDelegate)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }
    
    func testReloadDataCalledOnceAfterLoadingItems() {
        // reload data should not have been called yet
        XCTAssertEqual(guessGridViewDelegate.reloadDataCalledCount, 0)
        
        guessGridPresenter.loadItems()
        
        // reload data should have been called at least once
        XCTAssertGreaterThan(guessGridViewDelegate.reloadDataCalledCount, 0)
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
