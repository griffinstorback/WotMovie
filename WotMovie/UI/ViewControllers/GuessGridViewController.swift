//
//  GuessGridViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-13.
//

import UIKit

protocol GuessGridViewDelegate: NSObjectProtocol {
    func displayItems()
    func displayErrorLoadingItems()
    func reloadData()
    func numberOfItemsPerRow() -> Int
    
    func revealEntities(at indices: [Int])
    func revealCorrectlyGuessedEntities(at indices: [Int])
}

class GuessGridViewController: DetailPresenterViewController {

    private let guessGridViewPresenter: GuessGridPresenterProtocol
    
    private let gridView: LoadMoreGridViewController
    
    init(for category: GuessCategory, presenter: GuessGridPresenterProtocol? = nil) {
        // use passed in presenter if provided (used in tests)
        guessGridViewPresenter = presenter ?? GuessGridPresenter(category: category.type)
        
        gridView = LoadMoreGridViewController()

        super.init(nibName: nil, bundle: nil)
        
        title = "\(category.shortTitle)"
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        navigationItem.largeTitleDisplayMode = .never
        
        guessGridViewPresenter.setViewDelegate(self)
        
        gridView.delegate = self
        gridView.transitionPresenter = guessGridViewPresenter
    }
    
    private func layoutViews() {
        addChildViewController(gridView)
        gridView.view.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // load first page of movies/tv shows
        guessGridViewPresenter.loadItems()
    }
}

extension GuessGridViewController: GuessGridViewDelegate {
    func displayItems() {
        print("displayitems")
    }
    
    func displayErrorLoadingItems() {
        print("displayErrorLoadingitems")
    }
    
    func reloadData() {
        gridView.reloadData()
    }
    
    func numberOfItemsPerRow() -> Int {
        return gridView.numberOfCellsPerRow()
    }
    
    func revealEntities(at indices: [Int]) {
        gridView.revealEntities(at: indices)
    }
    
    func revealCorrectlyGuessedEntities(at indices: [Int]) {
        gridView.revealCorrectlyGuessedEntities(at: indices)
    }
}

extension GuessGridViewController: LoadMoreGridViewDelegate {
    func viewForHeader(_ loadMoreGridViewController: LoadMoreGridViewController, indexPath: IndexPath) -> UICollectionReusableView? {
        return nil
    }
    
    func sizeForHeader(_ loadMoreGridViewController: LoadMoreGridViewController) -> CGSize {
        return .zero
    }
    
    func willDisplayHeader(_ loadMoreGridViewController: LoadMoreGridViewController) {
        // nothing
    }
    
    func didEndDisplayingHeader(_ loadMoreGridViewController: LoadMoreGridViewController) {
        // nothing
    }
    
    func getNumberOfItems(_ loadMoreGridViewController: LoadMoreGridViewController) -> Int {
        return guessGridViewPresenter.itemsCount
    }
    
    func getItemFor(_ loadMoreGridViewController: LoadMoreGridViewController, index: Int) -> Entity? {
        return guessGridViewPresenter.itemFor(index: index)
    }
    
    func loadMoreItems(_ loadMoreGridViewController: LoadMoreGridViewController) {
        guessGridViewPresenter.loadItems()
    }
    
    func loadImageFor(_ loadMoreGridViewController: LoadMoreGridViewController, index: Int, completion: @escaping (UIImage?, String?) -> Void) {
        guessGridViewPresenter.loadImageFor(index: index, completion: completion)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // nothing
    }
}
