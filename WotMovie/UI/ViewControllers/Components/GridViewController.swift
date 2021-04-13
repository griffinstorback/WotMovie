//
//  GridViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-01-23.
//

import Foundation
import UIKit

// Collection view displaying a grid of PosterImageView's, number of columns depending on screen width
class GridViewController: DetailPresenterViewController {
    let collectionView: UICollectionView
    
    // this should be shown only while loading first page, then footer loading view (see load more grid vc) should take over as loading indicator
    private let loadingIndicatorOrErrorView: LoadingIndicatorOrErrorView
    
    weak var transitionPresenter: TransitionPresenterProtocol?
    
    private let spacingAmount: CGFloat = 5
    private let minimumCellWidth: CGFloat = 120 // max is (2 * minimum) - 1
    func screenWidth() -> CGFloat { collectionView.bounds.width }
    
    // number of cells per row is as many as can fit (based on minimumCellWidth), but make it at least 3 (this only really affects iphone SE 1)
    func numberOfCellsPerRow() -> Int { max(Int(screenWidth()/(minimumCellWidth)), 3) }
    func spacing() -> CGFloat { spacingAmount - spacingAmount/CGFloat(numberOfCellsPerRow()) }
    
    init() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        loadingIndicatorOrErrorView = LoadingIndicatorOrErrorView(state: .loading)
        
        super.init(nibName: nil, bundle: nil)
        
        setupViews()
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.delaysContentTouches = false
        
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        
        collectionView.register(GridCollectionViewCell.self, forCellWithReuseIdentifier: "GridCollectionViewCell")
        collectionView.register(GridCollectionViewFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")
    }
    
    private func layoutViews() {
        view.addSubview(collectionView)
        collectionView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        
        addLoadingIndicatorOrErrorView()
    }
    
    func addLoadingIndicatorOrErrorView() {
        // don't add loading indicator if it has already been added - also, don't add if show hint button is present
        guard !view.subviews.contains(loadingIndicatorOrErrorView) else { return }
        
        view.addSubview(loadingIndicatorOrErrorView)
        loadingIndicatorOrErrorView.anchorToCenter(yAnchor: collectionView.centerYAnchor, xAnchor: collectionView.centerXAnchor)
    }
    
    func displayErrorInLoadingIndicatorOrErrorView() {
        loadingIndicatorOrErrorView.state = .error
    }
    
    // should remove the loading view as soon as first items load.
    func removeLoadingIndicatorOrErrorView() {
        loadingIndicatorOrErrorView.state = .loaded
        loadingIndicatorOrErrorView.removeFromSuperview()
    }
    
    // CHECK customHeaderClass before deqeueing a header (need to call registerClassAsCollectionViewHeader before)
    var customHeaderClass: AnyClass?
    public func registerClassAsCollectionViewHeader(customClass: AnyClass) {
        collectionView.register(customClass.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        customHeaderClass = customClass
        reloadData()
    }
    
    public func reloadData() {
        collectionView.reloadData()
    }
    
    public func revealEntities(at indices: [Int]) {
        for index in indices {
            let indexPath = IndexPath(item: index, section: 0)
            
            if let cell = collectionView.cellForItem(at: indexPath) as? GridCollectionViewCell {
                cell.reveal(animated: false)
            }
        }
    }
    
    public func revealCorrectlyGuessedEntities(at indices: [Int]) {
        for index in indices {
            let indexPath = IndexPath(item: index, section: 0)
            
            if let cell = collectionView.cellForItem(at: indexPath) as? GridCollectionViewCell {
                cell.revealAsCorrect(animated: false)
            }
        }
    }
    
    func presentGuessDetail(for item: Entity, fromCard: UIView, presentingFromGuessGrid: Bool) {
        let guessDetailViewController: GuessDetailViewController
        
        if !presentingFromGuessGrid {
            switch item.type {
            case .movie, .tvShow:
                if item.correctlyGuessed {
                    guessDetailViewController = TitleDetailViewController(item: item, state: .correctWithNoNextButton)
                } else {
                    guessDetailViewController = TitleDetailViewController(item: item, state: .revealedWithNoNextButton)
                }
            case .person:
                if item.correctlyGuessed {
                    guessDetailViewController = PersonDetailViewController(item: item, state: .correctWithNoNextButton)
                } else {
                    guessDetailViewController = PersonDetailViewController(item: item, state: .revealedWithNoNextButton)
                }
            }
        } else {
            switch item.type {
            case .movie, .tvShow:
                if item.correctlyGuessed {
                    guessDetailViewController = TitleDetailViewController(item: item, state: .correct)
                } else if item.isRevealed {
                    guessDetailViewController = TitleDetailViewController(item: item, state: .revealed)
                } else {
                    guessDetailViewController = TitleDetailViewController(item: item, state: .fullyHidden)
                }
                
            case .person:
                if item.correctlyGuessed {
                    guessDetailViewController = PersonDetailViewController(item: item, state: .correct)
                } else if item.isRevealed {
                    guessDetailViewController = PersonDetailViewController(item: item, state: .revealed)
                } else {
                    guessDetailViewController = PersonDetailViewController(item: item, state: .fullyHidden)
                }
            }
        }
        
        guessDetailViewController.modalPresentationStyle = .fullScreen
        guessDetailViewController.modalPresentationCapturesStatusBarAppearance = true
        
        if transitionPresenter == nil {
            print("** WARNING: about to present guessDetailViewController but transitionPresenter is nil. This will mean if an entity is revealed while modal is presented, the grid its being presented from will not reflect the changes.")
        }
        
        present(guessDetailViewController, fromCard: fromCard, startHidden: !item.isRevealed && !item.correctlyGuessed, transitionPresenter: transitionPresenter)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // for ipad specifically - when rotating, the layout doesnt correctly recalculate item sizes.
        DispatchQueue.main.async {
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
}

extension GridViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // There is a possible rounding error when calculating width of cell.
        // e.g. 3 items try to fit into space of 10 by all being 3.333334 (added together end up being 10.000001), leading to only 2 being shown with large gap in between
        let possibleRoundingError: CGFloat = 0.01
        let itemWidth = screenWidth()/CGFloat(numberOfCellsPerRow()) - spacing() - possibleRoundingError
        
        return CGSize(width: itemWidth, height: itemWidth * 1.5)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacingAmount
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacingAmount
    }
}
