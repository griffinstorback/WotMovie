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
}

class GuessGridViewController: DetailPresenterViewController {

    private let guessGridViewPresenter: GuessGridPresenterProtocol
    
    private let gridView: LoadMoreGridViewController
    
    init(for category: GuessCategory, presenter: GuessGridPresenterProtocol? = nil) {
        // use passed in presenter if provided (used in tests)
        guessGridViewPresenter = presenter ?? GuessGridPresenter(category: category.type)
        
        gridView = LoadMoreGridViewController(showsAlphabeticalLabels: false)

        super.init(nibName: nil, bundle: nil)
        
        navigationItem.largeTitleDisplayMode = .never
        title = "\(category.shortTitle)"
        
        guessGridViewPresenter.setViewDelegate(guessGridViewDelegate: self)
        
        gridView.delegate = self
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
    
    func presentGuessDetail(for item: Entity, fromCard: UIView) {
        let guessDetailViewController: GuessDetailViewController
        
        switch item.type {
        case .movie, .tvShow:
            guessDetailViewController = TitleDetailViewController(item: item, startHidden: !item.isRevealed)
        case .person:
            guessDetailViewController = PersonDetailViewController(item: item, startHidden: !item.isRevealed)
        }
        
        guessDetailViewController.modalPresentationStyle = .fullScreen
        guessDetailViewController.modalPresentationCapturesStatusBarAppearance = true
        
        present(guessDetailViewController, fromCard: fromCard, startHidden: !item.isRevealed)
    }
    
    func reloadData() {
        gridView.reloadData()
    }
}

extension GuessGridViewController: LoadMoreGridViewDelegate {
    func viewForHeader(_ loadMoreGridViewController: LoadMoreGridViewController, indexPath: IndexPath) -> UICollectionReusableView? {
        return nil
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
