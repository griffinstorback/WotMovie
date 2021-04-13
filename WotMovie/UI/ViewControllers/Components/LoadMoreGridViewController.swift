//
//  LoadMoreGridViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-01-23.
//

import Foundation
import UIKit

protocol LoadMoreGridViewDelegate: NSObjectProtocol {
    func getNumberOfItems(_ loadMoreGridViewController: LoadMoreGridViewController) -> Int
    func getItemFor(_ loadMoreGridViewController: LoadMoreGridViewController, index: Int) -> Entity?
    func loadMoreItems(_ loadMoreGridViewController: LoadMoreGridViewController)
    func loadImageFor(_ loadMoreGridViewController: LoadMoreGridViewController, index: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void)
    
    // methods for providing this grid view with a header - return nil if none to show.
    func viewForHeader(_ loadMoreGridViewController: LoadMoreGridViewController, indexPath: IndexPath) -> UICollectionReusableView?
    func sizeForHeader(_ loadMoreGridViewController: LoadMoreGridViewController) -> CGSize
    func willDisplayHeader(_ loadMoreGridViewController: LoadMoreGridViewController)
    func didEndDisplayingHeader(_ loadMoreGridViewController: LoadMoreGridViewController)
    
    // return true if presenting from non-guess type grid, (i.e. Watchlist)
    func isPresentingFromGuessGrid() -> Bool
    
    func didPresentEntityDetail()
    func scrollViewDidScroll(_ scrollView: UIScrollView)
}

// Builds on GridViewController to provide an optional footer view which loads more items when in view. Also has optional header
class LoadMoreGridViewController: GridViewController, UICollectionViewDataSource {
    weak var delegate: LoadMoreGridViewDelegate?
    let shouldDisplayLoadMoreFooter: Bool // if true, display the loadmore footer view, and call delegate.loadMore() when it appears
    
    init(shouldDisplayLoadMoreFooter: Bool) {
        self.shouldDisplayLoadMoreFooter = shouldDisplayLoadMoreFooter
        
        super.init()
        
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
    }
    
    func selectCellAt(indexPath: IndexPath) {
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        collectionView(collectionView, didSelectItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 { // there should only ever be one section
            let numberOfItems = delegate?.getNumberOfItems(self) ?? 0
            
            // stop the loading indicator (not the footer one, the initial one) as soon as there is at least one item.
            if numberOfItems > 0 {
                removeLoadingIndicatorOrErrorView()
            }
            
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
        delegate?.loadImageFor(self, index: indexPath.row, completion: cell.imageDataReceived)
        
        // reveal poster image on cell if:
        //   - item has been revealed
        //   - OR, we're presenting from a list category grid (i.e. 'Watchlist' or 'Favorites')
        let isPresentingFromGuessGrid = delegate?.isPresentingFromGuessGrid() ?? false
        if item.isRevealed || !isPresentingFromGuessGrid {
            cell.reveal(animated: false)
        }
        
        if item.correctlyGuessed {
            cell.revealAsCorrect(animated: false)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // can fail when dismissing guess detail by pressing Next button (e.g when next item is at index which is higher than the items count)
        guard let cell = collectionView.cellForItem(at: indexPath) as? GridCollectionViewCell else {
            return
        }
        let cellFrame = cell.frame
        
        // scroll so cell completely visible so doesn't overlap the nav bar or tab bar.
        UIView.animate(withDuration: 0.2) {
            collectionView.scrollRectToVisible(cellFrame, animated: false)
        } completion: { _ in
            if let item = self.delegate?.getItemFor(self, index: indexPath.row) {
                let presentingFromGuessGrid = self.delegate?.isPresentingFromGuessGrid() ?? false
                self.presentGuessDetail(for: item, fromCard: cell.posterImageView, presentingFromGuessGrid: presentingFromGuessGrid)
                
                // tell delegate a modal was presented (useful for recently viewed - so recently viewed won't reload when dismissing the modal)
                self.delegate?.didPresentEntityDetail()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if delegate?.getNumberOfItems(self) ?? 0 > 0 && shouldDisplayLoadMoreFooter {
            return CGSize(width: collectionView.frame.width, height: 100)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        // return zero if no custom header class was supplied (customHeaderClass is a property on base class GridViewController)
        if self.customHeaderClass == nil {
            return .zero
        } else {
            return delegate?.sizeForHeader(self) ?? .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            
            // first, check that the delegate actually registered a header.
            // (customHeaderClass is property of superview GridViewController)
            if self.customHeaderClass != nil {
                
                // ask delegate to provide the view for the header it registered.
                // THIS WILL THROW AN ERROR IF NIL IS RETURNED.
                // DON'T REGISTER A CLASS AS HEADER UNLESS THIS IS IMPLEMENTED PROPERLY.
                let headerView = delegate?.viewForHeader(self, indexPath: indexPath)
                
                return headerView ?? UICollectionReusableView()
            }
        } else if kind == UICollectionView.elementKindSectionFooter && shouldDisplayLoadMoreFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer", for: indexPath) as! GridCollectionViewFooterView
            
            return footerView
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionHeader {
            delegate?.willDisplayHeader(self)
        } else if elementKind == UICollectionView.elementKindSectionFooter && shouldDisplayLoadMoreFooter {
            if let footerView = view as? GridCollectionViewFooterView {
                if delegate?.getNumberOfItems(self) ?? 0 > 0 {
                    footerView.startLoadingAnimation()
                    delegate?.loadMoreItems(self)
                } else {
                    print("**** LoadMoreGridViewController willdisplaysupplementaryview - nothing more to load?")
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionHeader {
            delegate?.didEndDisplayingHeader(self)
        } else if elementKind == UICollectionView.elementKindSectionFooter && shouldDisplayLoadMoreFooter {
            if let footerView = view as? GridCollectionViewFooterView {
                footerView.stopLoadingAnimation()
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(scrollView)
    }
}
