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
    let collectionView: ContentSizedCollectionView
    var transitionPresenter: TransitionPresenterProtocol?
    
    private let spacingAmount: CGFloat = 5
    private let minimumCellWidth: CGFloat = 120 // max is (2 * minimum)
    func screenWidth() -> CGFloat { collectionView.bounds.width }
    func numberOfCellsPerRow() -> Int { Int(screenWidth()/minimumCellWidth) }
    func spacing() -> CGFloat { spacingAmount - spacingAmount/CGFloat(numberOfCellsPerRow()) }
    
    init() {
        collectionView = ContentSizedCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        super.init(nibName: nil, bundle: nil)
        
        setupViews()
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.delaysContentTouches = false
        
        collectionView.register(GridCollectionViewCell.self, forCellWithReuseIdentifier: "GridCollectionViewCell")
        collectionView.register(GridCollectionViewFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")
    }
    
    private func layoutViews() {
        view.addSubview(collectionView)
        collectionView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
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
        //collectionView.reloadItems(at: indexPaths)
        for index in indices {
            let indexPath = IndexPath(item: index, section: 0)
            let cell = collectionView.cellForItem(at: indexPath) as! GridCollectionViewCell
            cell.reveal(animated: false)
        }
    }
    
    public func revealCorrectlyGuessedEntities(at indices: [Int]) {
        for index in indices {
            let indexPath = IndexPath(item: index, section: 0)
            let cell = collectionView.cellForItem(at: indexPath) as! GridCollectionViewCell
            cell.revealAsCorrect(animated: false)
        }
    }
    
    func presentGuessDetail(for item: Entity, fromCard: UIView) {
        let guessDetailViewController: GuessDetailViewController
        
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
            //guessDetailViewController = PersonDetailViewController(item: item, startHidden: !item.isRevealed && !item.correctlyGuessed, fromGuessGrid: true)
        }
        
        guessDetailViewController.modalPresentationStyle = .fullScreen
        guessDetailViewController.modalPresentationCapturesStatusBarAppearance = true
        
        if transitionPresenter == nil {
            print("** WARNING: about to present guessDetailViewController but transitionPresenter is nil. This will mean if an entity is revealed while modal is presented, the grid its being presented from will not reflect the changes.")
        }
        
        present(guessDetailViewController, fromCard: fromCard, startHidden: !item.isRevealed && !item.correctlyGuessed, transitionPresenter: transitionPresenter)
    }
}

extension GridViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        return CGSize(width: screenWidth()/CGFloat(numberOfCellsPerRow()) - spacing(), height: (screenWidth()/CGFloat(numberOfCellsPerRow()))*1.5)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}
