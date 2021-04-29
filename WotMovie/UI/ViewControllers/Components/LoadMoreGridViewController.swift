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
    func isWaitingForUserToGuessMoreBeforeLoadingMore(_ loadMoreGridViewController: LoadMoreGridViewController) -> Bool
    func loadMoreItems(_ loadMoreGridViewController: LoadMoreGridViewController) -> Bool
    
    func loadImageFor(_ loadMoreGridViewController: LoadMoreGridViewController, index: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void)
    func cancelLoadImageRequestFor(_ loadMoreGridViewController: LoadMoreGridViewController, indexPath: IndexPath)
    
    // methods for providing this grid view with a header - return nil if none to show.
    func viewForHeader(_ loadMoreGridViewController: LoadMoreGridViewController, indexPath: IndexPath) -> UICollectionReusableView?
    func sizeForHeader(_ loadMoreGridViewController: LoadMoreGridViewController) -> CGSize
    func willDisplayHeader(_ loadMoreGridViewController: LoadMoreGridViewController)
    func didEndDisplayingHeader(_ loadMoreGridViewController: LoadMoreGridViewController)
    
    // return true if presenting from non-guess type grid, (i.e. Watchlist)
    func isPresentingFromGuessGrid() -> Bool
    
    func didPresentEntityDetail()
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    
    // these methods called from cells, passed through the extension conforming to GridCollectionViewCellDelegate
    func addItemToWatchlistOrFavorites(_ indexPath: IndexPath)
    func removeItemFromWatchlistOrFavorites(_ indexPath: IndexPath)
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
            let numberOfItems = delegate?.getNumberOfItems(self)
            
            // stop the loading indicator (not the footer one, the initial one) when there is a response
            /*if numberOfItems != nil {
                removeLoadingIndicatorOrErrorView()
            }*/
            
            return numberOfItems ?? 0
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
        
        // need to set these so that cell can get information for displaying and interacting with context menu
        cell.indexPath = indexPath
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        delegate?.cancelLoadImageRequestFor(self, indexPath: indexPath)
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
                let numberOfItems = delegate?.getNumberOfItems(self) ?? 0
                if numberOfItems > 0 {
                    footerView.startLoadingAnimation()
                    
                    _ = delegate?.loadMoreItems(self)
                    
                    // This solution, to scrolling up above footer when no items should be loaded, was bad - it fires the animation before footer even appears
                    //let itemLoadingWasInitiated = delegate?.loadMoreItems(self) ?? false
                    // if item loading was not initiated (i.e. need to guess more on guess grid before loading more) scroll back up above footer.
                    /*if !itemLoadingWasInitiated {
                        collectionView.scrollToItem(at: IndexPath(item: numberOfItems-1, section: 0), at: .bottom, animated: true)
                    }*/
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
    
    var currentlyAnimatingUp: Bool = false
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(scrollView)
        
        // This solution makes it so when footer view is shown, but items are not initiated to load (because user needs to reveal some of the hidden
        // ones first), the collection view animates the view back up so that the footer is just out of view again.
        // IT KIND OF WORKS, but is slightly buggy, and overall, at this point unnecessary.
        
        /*
        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height
        if bottomEdge >= scrollView.contentSize.height {
            let waitingForUserToGuessMore = delegate?.isWaitingForUserToGuessMoreBeforeLoadingMore(self) ?? false
            if waitingForUserToGuessMore {
                let lastItemIndex = (delegate?.getNumberOfItems(self) ?? 0) - 1
                if lastItemIndex >= 0 && !currentlyAnimatingUp {
                    currentlyAnimatingUp = true
                    UIView.animate(withDuration: 0.2, animations: {
                        self.collectionView.scrollToItem(at: IndexPath(item: lastItemIndex, section: 0), at: .bottom, animated: false)
                    }, completion: { _ in
                        self.currentlyAnimatingUp = false
                    })
                    //collectionView.scrollToItem(at: IndexPath(item: lastItemIndex, section: 0), at: .bottom, animated: true)
                }
            }
        }
        */
    }
}

// this enables context menu interactions with cells (cells that aren't hidden, that is)
extension LoadMoreGridViewController: GridCollectionViewCellDelegate {
    func getItemType(_ indexPath: IndexPath) -> EntityType? {
        return delegate?.getItemFor(self, index: indexPath.row)?.type
    }
    
    func isItemInWatchlistOrFavorites(_ indexPath: IndexPath) -> Bool {
        return delegate?.getItemFor(self, index: indexPath.row)?.isFavorite ?? false
    }
    
    func addItemToWatchlistOrFavorites(_ indexPath: IndexPath) {
        delegate?.addItemToWatchlistOrFavorites(indexPath)
    }
    
    func removeItemFromWatchlistOrFavorites(_ indexPath: IndexPath) {
        delegate?.removeItemFromWatchlistOrFavorites(indexPath)
    }
}
