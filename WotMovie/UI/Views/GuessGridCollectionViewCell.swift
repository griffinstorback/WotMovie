//
//  GuessGridCollectionViewCell.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-16.
//

import UIKit

class GuessGridCollectionViewCell: UICollectionViewCell {
    
    private var posterImageView: PosterImageView!
    
    private var hasBeenGuessed = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        posterImageView = PosterImageView(startHidden: true)        
        addSubview(posterImageView)
        posterImageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        
        if !hasBeenGuessed {
            posterImageView.removeBlurEffectOverlay(animated: true)
        }
    }
    
    func setCornerRadius() {
        posterImageView.layer.cornerRadius = posterImageView.frame.height * Constants.imageCornerRadiusRatio
        posterImageView.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.posterImageView.image = nil
    }
    
    func imageDataReceived(image: UIImage?) {
        guard let image = image else {
            // TODO
            //imageView.image = UIImage(named: "N/A")
            print("ERROR: image came back nil")
            return
        }
        
        setCornerRadius()
        posterImageView.image = image
    }
}
