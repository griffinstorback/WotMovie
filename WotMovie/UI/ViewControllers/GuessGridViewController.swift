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
    
    private let spacingAmount: CGFloat = 5
    private let minimumCellWidth: CGFloat = 120 // max is (2 * minimum)
    
    init(for category: GuessCategory, presenter: GuessGridPresenterProtocol? = nil) {
        // use passed in presenter if provided (used in tests)
        guessGridViewPresenter = presenter ?? GuessGridPresenter(category: category.type)
        
        gridView = LoadMoreGridViewController(showsAlphabeticalLabels: false)

        super.init(nibName: nil, bundle: nil)
        
        navigationItem.largeTitleDisplayMode = .never
        title = "\(category.shortTitle)"
        
        guessGridViewPresenter.setViewDelegate(guessGridViewDelegate: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGridView()
        
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
    func setupGridView() {
        gridView.setupCollectionView()
        gridView.delegate = self
        
        addChildViewController(gridView)
        
        gridView.view.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
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
    
    func loadImageFor(index: Int, completion: @escaping (UIImage?, String?) -> Void) {
        guessGridViewPresenter.loadImageFor(index: index, completion: completion)
    }
}

extension GuessGridViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = collectionView.bounds.width
        let numberOfCellsPerRow = Int(screenWidth/minimumCellWidth)
        let spacing = spacingAmount - spacingAmount/CGFloat(numberOfCellsPerRow)
        
        return CGSize(width: screenWidth/CGFloat(numberOfCellsPerRow) - spacing, height: (screenWidth/CGFloat(numberOfCellsPerRow))*1.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}
