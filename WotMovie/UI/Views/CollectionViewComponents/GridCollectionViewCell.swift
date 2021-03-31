//
//  GridCollectionViewCell.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-16.
//

import UIKit

class GridCollectionViewCell: UICollectionViewCell {
    
    var posterImageView: PosterImageView!
        
    // need to keep track of the path for image on this cell, so that cell doesn't receive the wrong image (reusable).
    private var imagePath: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        posterImageView = PosterImageView(state: .hidden)
        addSubview(posterImageView)
        posterImageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
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
    }
    
    func revealAsCorrect(animated: Bool) {
        posterImageView.setState(.correctlyGuessed, animated: animated)
    }
}
