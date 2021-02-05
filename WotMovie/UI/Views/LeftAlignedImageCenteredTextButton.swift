//
//  LeftAlignedImageCenteredTextButton.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-02-04.
//

import UIKit

class LeftAlignedImageCenteredTextButton: ShrinkOnTouchButton {
    private let leftAlignedImageView: UIImageView
    private let centeredTextLabel: UILabel
    private let rightAlignedEmptySpacingView: UIView
    
    init() {
        leftAlignedImageView = UIImageView()
        centeredTextLabel = UILabel()
        rightAlignedEmptySpacingView = UIView()
        
        super.init(frame: .zero)
        
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        leftAlignedImageView.tintColor = .white
        leftAlignedImageView.contentMode = .scaleAspectFit
        
        centeredTextLabel.textColor = .white
        centeredTextLabel.font = UIFont.boldSystemFont(ofSize: 18)
        centeredTextLabel.adjustsFontSizeToFitWidth = true
        centeredTextLabel.textAlignment = .center
        centeredTextLabel.numberOfLines = 2
    }
    
    private func layoutViews() {
        addSubview(leftAlignedImageView)
        leftAlignedImageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: nil, padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), size: CGSize(width: 30, height: 0))
        
        addSubview(centeredTextLabel)
        centeredTextLabel.anchor(top: topAnchor, leading: leftAlignedImageView.trailingAnchor, bottom: bottomAnchor, trailing: nil, padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
        
        addSubview(rightAlignedEmptySpacingView)
        rightAlignedEmptySpacingView.anchor(top: topAnchor, leading: centeredTextLabel.trailingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
        rightAlignedEmptySpacingView.anchorSize(height: nil, width: leftAlignedImageView.widthAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setImageViewImage(imageName: String) {
        leftAlignedImageView.image = UIImage(named: imageName)?.withTintColor(.white)
    }
    
    public func setLabelText(text: String) {
        centeredTextLabel.text = text
    }
}
