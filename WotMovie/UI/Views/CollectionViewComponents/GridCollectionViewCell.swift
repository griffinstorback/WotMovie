//
//  GridCollectionViewCell.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-16.
//

import UIKit

protocol GridCollectionViewCellDelegate: NSObjectProtocol {
    func getItemType(_ indexPath: IndexPath) -> EntityType?
    func isItemInWatchlistOrFavorites(_ indexPath: IndexPath) -> Bool
    
    func addItemToWatchlistOrFavorites(_ indexPath: IndexPath)
    func removeItemFromWatchlistOrFavorites(_ indexPath: IndexPath)
}

class GridCollectionViewCell: UICollectionViewCell {
    
    var indexPath: IndexPath?
    
    weak var delegate: GridCollectionViewCellDelegate?
    
    var posterImageView: PosterImageView
        
    // need to keep track of the path for image on this cell, so that cell doesn't receive the wrong image (reusable).
    private var imagePath: String = ""
    
    override init(frame: CGRect) {
        posterImageView = PosterImageView(state: .hidden)
        
        super.init(frame: frame)
        
        addSubview(posterImageView)
        posterImageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.indexPath = nil
        // self.delegate - don't need to reset, because all cells will have same delegate object??
        
        self.posterImageView.setImage(nil)
        self.posterImageView.setState(.hidden, animated: false)
        self.imagePath = ""
    }
    
    func setCellImagePath(imagePath: String) {
        self.imagePath = imagePath
    }
    
    func imageDataReceived(image: UIImage?, imagePath: String?) {
        // if image came back, we need to first make sure it matches imagePath that was set on this cell
        // (otherwise, cells occasionally flash the wrong image  - due to glitches with reusable cells)
        if let image = image, let imagePath = imagePath, self.imagePath == imagePath {
            posterImageView.setImage(image)
            return
        }
        
        // if nil image was sent back, we need to set the poster image view accordingly, so it can stop its loading animation.
        if image == nil {
            posterImageView.setImage(nil)
        }
    }
    
    func reveal(animated: Bool) {
        posterImageView.setState(.revealed, animated: animated)
        addContextMenuInteraction()
    }
    
    func revealAsCorrect(animated: Bool) {
        posterImageView.setState(.correctlyGuessed, animated: animated)
        addContextMenuInteraction()
    }
    
    func addContextMenuInteraction() {
        // don't bother adding context menu if grid item is hidden (no point)
        if posterImageView.state != .hidden && posterImageView.state != .revealWhileDetailOpenButHideOnGrid {
            if interactions.isEmpty {
                let interaction = UIContextMenuInteraction(delegate: self)
                addInteraction(interaction)
            }
        }
    }
    
    // these are called from context menu (when holding down on cell, IF it is revealed)
    func addToWatchlistOrFavorites(_ action: UIAction) {
        guard let indexPath = indexPath else {
            print("** WARNING: No indexPath was set on GridCollectionViewCell - context menu interactions will not work")
            return
        }
        guard let delegate = delegate else {
            print("** WARNING: No delegate set in GridCollectionViewCell - context menu interactions will not work")
            return
        }
        
        delegate.addItemToWatchlistOrFavorites(indexPath)
    }
    
    func removeFromWatchlistOrFavorites(_ action: UIAction) {
        guard let indexPath = indexPath else {
            print("** WARNING: No indexPath was set on GridCollectionViewCell - context menu interactions will not work")
            return
        }
        guard let delegate = delegate else {
            print("** WARNING: No delegate set in GridCollectionViewCell - context menu interactions will not work")
            return
        }
        
        delegate.removeItemFromWatchlistOrFavorites(indexPath)
    }
}

extension GridCollectionViewCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in
            var actions: [UIAction] = []
            
            // IF the item on the grid is HIDDEN, then it makes no sense to allow it to be added to watchlist/favorites.
            if self.posterImageView.state != .hidden && self.posterImageView.state != .revealWhileDetailOpenButHideOnGrid {
                if let indexPath = self.indexPath, let itemType = self.delegate?.getItemType(indexPath), let isFavorite = self.delegate?.isItemInWatchlistOrFavorites(indexPath) {
                    switch itemType {
                    case .movie, .tvShow:
                        if isFavorite {
                            actions.append(self.makeRemoveFromWatchlistAction())
                        } else {
                            actions.append(self.makeAddToWatchlistAction())
                        }
                    case .person:
                        if isFavorite {
                            actions.append(self.makeRemoveFromFavoritesAction())
                        } else {
                            actions.append(self.makeAddToFavoritesAction())
                        }
                    }
                }
            }
            
            return UIMenu(title: "", children: actions)
        })
    }
    
    func makeAddToWatchlistAction() -> UIAction {
        let addToWatchlistAction = UIAction(title: "Add to watchlist", image: UIImage(named: "add_to_watchlist_icon"), identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off, handler: addToWatchlistOrFavorites)
        return addToWatchlistAction
    }
    
    func makeAddToFavoritesAction() -> UIAction {
        let addToFavoritesAction = UIAction(title: "Add to favorites", image: UIImage(named: "add_to_favorites_icon"), identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off, handler: addToWatchlistOrFavorites)
        return addToFavoritesAction
    }
    
    func makeRemoveFromWatchlistAction() -> UIAction {
        let removeFromWatchlistAction = UIAction(title: "Remove from watchlist", image: UIImage(named: "remove_from_watchlist_icon"), identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off, handler: removeFromWatchlistOrFavorites)
        return removeFromWatchlistAction
    }
    
    func makeRemoveFromFavoritesAction() -> UIAction {
        let removeFromFavoritesAction = UIAction(title: "Remove from favorites", image: UIImage(named: "remove_from_favorites_icon"), identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off, handler: removeFromWatchlistOrFavorites)
        return removeFromFavoritesAction
    }
}
