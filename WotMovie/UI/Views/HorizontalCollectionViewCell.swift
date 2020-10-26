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
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .gray
        
        nameLabel = UILabel()
        nameLabel.numberOfLines = 0
        nameLabel.font = UIFont.systemFont(ofSize: 14.0)
        nameLabel.textAlignment = .center
        
        subtitleLabel = UILabel()
        subtitleLabel.numberOfLines = 0
        subtitleLabel.font = UIFont.systemFont(ofSize: 13.0)
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = .gray
        
        if Bool.random() {
            subtitleLabel.text = "Character blah akjg oiwi wpopw qllkf jg oioif  nbbvbv dhhe ytyytyt shbg ytaoo ppppooppppp wkejhkjh po  o oooooooooo poopp po po po pOOP"
        } else {
            subtitleLabel.text = "Character blah"
        }
        layoutViews()
    }
    
    private func layoutViews() {
        addSubview(imageView)
        imageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, size: CGSize(width: 0, height: 150))
        
        addSubview(nameLabel)
        nameLabel.anchor(top: imageView.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor)
        
        addSubview(subtitleLabel)
        subtitleLabel.anchor(top: nameLabel.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor)
        
        // bottom constraint is less than or equal to so that label text appears at top (instead of being centered)
        subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -5).isActive = true
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
