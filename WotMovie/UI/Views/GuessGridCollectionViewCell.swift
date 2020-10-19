//
//  GuessGridCollectionViewCell.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-16.
//

import UIKit

class GuessGridCollectionViewCell: UICollectionViewCell {
    
    private var imageView: UIImageView!
    private var blurEffectView: UIVisualEffectView!
    
    private var hasBeenGuessed = Bool.random()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView()
        addSubview(imageView)
        imageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        
        if !hasBeenGuessed {
            blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
            addSubview(blurEffectView)
            blurEffectView?.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        //self.imageView?.removeFromSuperview()
        //self.imageView = nil
        self.imageView.image = nil
    }
    
    // this function passed as closure to GuessGridPresenter in cellForItemAt
    func imageDataReceived(image: UIImage?) {
        guard let image = image else {
            //imageView.image = UIImage(named: "N/A")
            print("ERROR: image came back nil")
            return
        }
        
        imageView.image = image
    }
}
