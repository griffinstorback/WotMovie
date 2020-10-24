//
//  HorizontalCollectionViewCell.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-23.
//

import UIKit

class HorizontalCollectionViewCell: UICollectionViewCell {
    
    private var imageView: UIImageView!
    private var nameLabel: UILabel!
    private var subtitleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        nameLabel = UILabel()
        nameLabel.numberOfLines = 0
        nameLabel.font = UIFont.systemFont(ofSize: 14.0)
        subtitleLabel = UILabel()
        
        layoutViews()
    }
    
    private func layoutViews() {
        addSubview(imageView)
        imageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor)
        
        addSubview(nameLabel)
        nameLabel.anchor(top: imageView.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor)
        
        addSubview(subtitleLabel)
        subtitleLabel.anchor(top: nameLabel.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setImage(_ image: UIImage?) {
        imageView.image = image
    }
    
    public func setName(_ text: String) {
        nameLabel.text = text
    }
    
    public func setSubtitle(_ text: String) {
        subtitleLabel.text = text
    }
}
