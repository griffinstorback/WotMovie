//
//  LeftAlignedImageCenteredTextButton.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-02-04.
//

import UIKit

/*
 
 Used for watchlist and favorites add/remove buttons in detail (in enter guess view).
 This is needed for formatting to look good, because the button sometimes takes up half
 the screen, and other times takes up the whole width of the screen, depending on whether
 or not user is guessing or just viewing.
 
 */

class LeftAlignedImageCenteredTextButton: ShrinkOnTouchButton {
    private let leftAlignedImageView: UIImageView
    private let centeredTextLabel: UILabel
    private let rightAlignedEmptySpacingView: UIView
    private var rightAlignedEmptySpacingViewWidthConstraint: NSLayoutConstraint!
    
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
        centeredTextLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        centeredTextLabel.adjustsFontSizeToFitWidth = true
        centeredTextLabel.textAlignment = .center
        centeredTextLabel.numberOfLines = 2
        
        rightAlignedEmptySpacingView.isUserInteractionEnabled = false
    }
    
    private func layoutViews() {
        addSubview(leftAlignedImageView)
        leftAlignedImageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: nil, padding: UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10), size: CGSize(width: 40, height: 0))
        
        addSubview(centeredTextLabel)
        centeredTextLabel.anchor(top: topAnchor, leading: leftAlignedImageView.trailingAnchor, bottom: bottomAnchor, trailing: nil, padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
        
        addSubview(rightAlignedEmptySpacingView)
        rightAlignedEmptySpacingView.anchor(top: topAnchor, leading: centeredTextLabel.trailingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
        //rightAlignedEmptySpacingView.anchorSize(height: nil, width: leftAlignedImageView.widthAnchor)
        
        // create the empty right view spacing constraint, then update if necessary
        rightAlignedEmptySpacingViewWidthConstraint = rightAlignedEmptySpacingView.widthAnchor.constraint(equalToConstant: leftAlignedImageView.frame.width)
        updateRightSpacingViewWidthIfNeeded()
        rightAlignedEmptySpacingViewWidthConstraint.isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateRightSpacingViewWidthIfNeeded()
    }
    
    public func setImageViewImage(imageName: String) {
        leftAlignedImageView.image = UIImage(named: imageName)?.withTintColor(.white)
    }
    
    public func setLabelText(text: String) {
        centeredTextLabel.text = text
    }
    
    private func updateRightSpacingViewWidthIfNeeded() {
        // Only update if large change, so that the selection shrinking (button shrinks when tapped) doesn't
        // cause change (don't want buttons display style to change when simply pressing button - this causes
        // it to look glitchy)
        
        if centeredTextLabel.frame.width > 140 {
            
            // center the text because there is enough room
            rightAlignedEmptySpacingViewWidthConstraint.constant = leftAlignedImageView.frame.width
            centeredTextLabel.textAlignment = .center
            
        } else if centeredTextLabel.frame.width < 100 {
            
            // let the text invade the right aligned spacing view, because room is needed
            rightAlignedEmptySpacingViewWidthConstraint.constant = 10
            centeredTextLabel.textAlignment = .left
        }
    }
}
