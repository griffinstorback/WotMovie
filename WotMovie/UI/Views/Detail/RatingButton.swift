//
//  RatingButton.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-04-14.
//

import UIKit

class RatingButton: UIView {
    
    let ratingLabel: UILabel
    let onTMDbLabel: UILabel
    
    /*override var intrinsicContentSize: CGSize {
        let labelSize = titleLabel?.sizeThatFits(CGSize(width: frame.size.width, height: CGFloat.greatestFiniteMagnitude)) ?? .zero
        let desiredButtonSize = CGSize(width: labelSize.width + titleEdgeInsets.left + titleEdgeInsets.right, height: labelSize.height + titleEdgeInsets.top + titleEdgeInsets.bottom)

        return desiredButtonSize
    }*/
    
    init() {
        ratingLabel = UILabel()
        onTMDbLabel = UILabel()
        
        super.init(frame: .zero)
        
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        ratingLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        onTMDbLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        onTMDbLabel.text = " on TMDb"
    }
    
    private func layoutViews() {
        addSubview(ratingLabel)
        ratingLabel.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: nil, padding: UIEdgeInsets(top: 3, left: 5, bottom: 3, right: 0))
        
        addSubview(onTMDbLabel)
        onTMDbLabel.anchor(top: topAnchor, leading: ratingLabel.trailingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 5))
    }
    
    public func setRating(rating: Double) {
        ratingLabel.text = String(format: "%.1f", rating)
    }
    
    public func setOnTMDbText(text: String) {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
