//
//  ExamplePersonGuessView.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-03-23.
//

import UIKit

class ExamplePersonGuessView: UIView {
    private let imageView: UIImageView
    private let questionMarkLabel: UILabel
    
    override init(frame: CGRect) {
        imageView = UIImageView()
        questionMarkLabel = UILabel()
        
        super.init(frame: .zero)
        
        setupViews()
        layoutViews()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        imageView.layer.cornerRadius = imageView.frame.height * Constants.imageCornerRadiusRatio
    }
        
    private func setupViews() {
        backgroundColor = .clear
        
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemGray4
        imageView.layer.masksToBounds = true
        
        questionMarkLabel.text = "?"
        questionMarkLabel.textColor = .label
        questionMarkLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
    }
    
    private func layoutViews() {
        addSubview(imageView)
        imageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor)
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 2/3).isActive = true
        
        addSubview(questionMarkLabel)
        questionMarkLabel.anchor(top: imageView.bottomAnchor, leading: nil, bottom: bottomAnchor, trailing: nil, size: CGSize(width: 0, height: 40))
        questionMarkLabel.anchorToCenter(yAnchor: nil, xAnchor: centerXAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setImage(_ image: UIImage?) {
        if let image = image {
            // if image being set for first time, just set it - otherwise, animate the change in image (to help produce carousel effect in upgrade view)
            if imageView.image == nil {
                imageView.image = image
            } else {
                UIView.transition(with: self, duration: 1.0, options: [.transitionCrossDissolve, .allowUserInteraction]) {
                    self.imageView.image = image
                }
            }
        } else {
            // TODO: SET DEFAULT PERSON IMAGE
            imageView.image = nil
        }
    }
}
