//
//  GuessGridCollectionViewCell.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-16.
//

import UIKit

class GuessGridCollectionViewCell: UICollectionViewCell {
    
    private var posterImageView: PosterImageView!
    private var blurEffectView: UIVisualEffectView!
    
    private var hasBeenGuessed = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        posterImageView = PosterImageView()
        addSubview(posterImageView)
        posterImageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        
        if !hasBeenGuessed {
            posterImageView.removeBlurEffectOverlay(animated: true)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        //self.imageView?.removeFromSuperview()
        //self.imageView = nil
        self.posterImageView.image = nil
    }
    
    // this function passed as closure to GuessGridPresenter in cellForItemAt
    func imageDataReceived(image: UIImage?) {
        guard let image = image else {
            //imageView.image = UIImage(named: "N/A")
            print("ERROR: image came back nil")
            return
        }
        
        posterImageView.image = image
    }
}
