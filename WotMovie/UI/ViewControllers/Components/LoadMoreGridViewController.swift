//
//  LoadMoreGridViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-01-23.
//

import Foundation
import UIKit

protocol LoadMoreGridViewDelegate {
    func getNumberOfItems(_ loadMoreGridViewController: LoadMoreGridViewController) -> Int
    func getItemFor(_ loadMoreGridViewController: LoadMoreGridViewController, index: Int) -> Entity?
    func loadMoreItems(_ loadMoreGridViewController: LoadMoreGridViewController)
    func loadImageFor(index: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void)
}

class LoadMoreGridViewController: GridViewController, UICollectionViewDataSource {
    var delegate: LoadMoreGridViewDelegate?
    
    func setupCollectionView() {
        collectionView.dataSource = self
        
        collectionView.backgroundColor = .white
        collectionView.delaysContentTouches = false
        
        collectionView.register(GridCollectionViewCell.self, forCellWithReuseIdentifier: "GridCollectionViewCell")
        collectionView.register(GridCollectionViewFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")
        
        view.addSubview(collectionView)
        
        collectionView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return delegate?.getNumberOfItems(self) ?? 0
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridCollectionViewCell", for: indexPath) as! GridCollectionViewCell
        guard let item = delegate?.getItemFor(self, index: indexPath.row) else {
            return cell
        }
        
        cell.setCellImagePath(imagePath: item.posterPath ?? "")
        delegate?.loadImageFor(index: indexPath.row, completion: cell.imageDataReceived)
        
        if item.isRevealed {
            cell.reveal(animated: false)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! GridCollectionViewCell
        let cellFrame = cell.frame
        
        // scroll so cell completely visible so doesn't overlap the nav bar or tab bar.
        UIView.animate(withDuration: 0.2) {
            collectionView.scrollRectToVisible(cellFrame, animated: false)
        } completion: { _ in
            if let item = self.delegate?.getItemFor(self, index: indexPath.row) {
                self.presentGuessDetail(for: item, fromCard: cell.posterImageView)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if delegate?.getNumberOfItems(self) ?? 0 > 0 {
            return CGSize(width: collectionView.frame.width, height: 100)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer", for: indexPath) as! GridCollectionViewFooterView
            
            return footerView
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            if let footerView = view as? GridCollectionViewFooterView {
                if delegate?.getNumberOfItems(self) ?? 0 > 0 {
                    footerView.startLoadingAnimation()
                    delegate?.loadMoreItems(self)
                } else {
                    print("nothing more to load?")
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            if let footerView = view as? GridCollectionViewFooterView {
                footerView.stopLoadingAnimation()
            }
        }
    }
}
