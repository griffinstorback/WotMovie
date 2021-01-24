//
//  GridViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-01-23.
//

import Foundation
import UIKit

class GridViewController: DetailPresenterViewController {
    let collectionView: UICollectionView
    
    private let spacingAmount: CGFloat = 5
    private let minimumCellWidth: CGFloat = 120 // max is (2 * minimum)
    
    init(showsAlphabeticalLabels: Bool) {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
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
    
    func reloadData() {
        collectionView.reloadData()
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
}

extension GridViewController: UICollectionViewDelegateFlowLayout {
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
