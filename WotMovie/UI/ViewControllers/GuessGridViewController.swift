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
    
    private var collectionView: UICollectionView!
    
    private let spacingAmount: CGFloat = 5
    private let minimumCellWidth: CGFloat = 120 // max is (2 * minimum)
    
    init(for category: GuessCategory, presenter: GuessGridPresenterProtocol? = nil) {
        // use passed in presenter if provided (used in tests)
        guessGridViewPresenter = presenter ?? GuessGridPresenter(category: category.type)
        
        super.init(nibName: nil, bundle: nil)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        navigationItem.largeTitleDisplayMode = .never
        title = "\(category.shortTitle)"
        
        guessGridViewPresenter.setViewDelegate(guessGridViewDelegate: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        
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
            guessDetailViewController = TitleDetailViewController(item: item, startHidden: true)
        case .person:
            guessDetailViewController = PersonDetailViewController(item: item, startHidden: true)
        }
        
        guessDetailViewController.modalPresentationStyle = .fullScreen
        guessDetailViewController.modalPresentationCapturesStatusBarAppearance = true
        
        present(guessDetailViewController, fromCard: fromCard, startHidden: true)
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
}

extension GuessGridViewController: UICollectionViewDataSource {
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.delaysContentTouches = false
        
        collectionView.register(GuessGridCollectionViewCell.self, forCellWithReuseIdentifier: "ItemCollectionViewCell")
        collectionView.register(GuessGridFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")
        
        view.addSubview(collectionView)
        
        collectionView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return guessGridViewPresenter.itemsCount
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCollectionViewCell", for: indexPath) as! GuessGridCollectionViewCell
        cell.setCellImagePath(imagePath: guessGridViewPresenter.itemFor(index: indexPath.row).posterPath ?? "")
        guessGridViewPresenter.loadImageFor(index: indexPath.row, completion: cell.imageDataReceived)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! GuessGridCollectionViewCell
        let cellFrame = cell.frame
        
        // scroll so cell completely visible so doesn't overlap the nav bar or tab bar.
        UIView.animate(withDuration: 0.2) {
            collectionView.scrollRectToVisible(cellFrame, animated: false)
        } completion: { _ in
            let item = self.guessGridViewPresenter.itemFor(index: indexPath.row)
            self.presentGuessDetail(for: item, fromCard: cell.posterImageView)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if guessGridViewPresenter.itemsCount > 0 {
            return CGSize(width: collectionView.frame.width, height: 100)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer", for: indexPath) as! GuessGridFooterView
            
            return footerView
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            if let footerView = view as? GuessGridFooterView {
                if guessGridViewPresenter.itemsCount > 0 {
                    footerView.startLoadingAnimation()
                    guessGridViewPresenter.loadItems()
                } else {
                    print("nothing more to load?")
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            if let footerView = view as? GuessGridFooterView {
                footerView.stopLoadingAnimation()
            }
        }
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
