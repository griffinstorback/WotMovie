//
//  HorizontalCollectionViewCell.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-23.
//

import UIKit

class HorizontalCollectionViewCell: ShrinkOnTouchCollectionViewCell {
    
    static let cellHeight: CGFloat = 150
    
    private var imagePath: String = ""
        
    var imageView: UIImageView!
    
    private var labelStackView: UIStackView!
    private var nameLabel: UILabel!
    private var subtitleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .systemGray4
        imageView.layer.cornerRadius = HorizontalCollectionViewCell.cellHeight * Constants.imageCornerRadiusRatio
        imageView.layer.masksToBounds = true
        
        nameLabel = UILabel()
        nameLabel.numberOfLines = 0
        nameLabel.textAlignment = .center
        
        subtitleLabel = UILabel()
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = .secondaryLabel
        
        let emptySpacingView = UIView()
        emptySpacingView.backgroundColor = .clear
        labelStackView = UIStackView(arrangedSubviews: [nameLabel, subtitleLabel, emptySpacingView])
        labelStackView.axis = .vertical
        
        // for testing multiple line support of labels.
        /*if Bool.random() {
            subtitleLabel.text = "Super long text because character name could be long, but likely won't be this long - really just testing what happens when subtitle label is too long"
        } else {
            subtitleLabel.text = "Character blah"
        }*/
        layoutViews()
    }
    
    private func layoutViews() {
        anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        
        addSubview(imageView)
        imageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, size: CGSize(width: 0, height: HorizontalCollectionViewCell.cellHeight))
        
        addSubview(labelStackView)
        labelStackView.anchor(top: imageView.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        
        /*addSubview(nameLabel)
        nameLabel.anchor(top: imageView.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor)
        addSubview(subtitleLabel)
        subtitleLabel.anchor(top: nameLabel.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor)*/
        
        // bottom constraint is less than or equal to so that label text appears at top (instead of being centered)
        //subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -5).isActive = true
        //subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
        self.imagePath = ""
    }
    
    public func setImagePath(path: String) {
        self.imagePath = path
    }
    
    public func setImage(_ image: UIImage?, _ imagePath: String?) {
        // if image came back, we need to first make sure it matches imagePath that was set on this cell
        // (otherwise, cells occasionally flash the wrong image  - due to glitches with reusable cells)
        if let image = image, let imagePath = imagePath, self.imagePath == imagePath {
            imageView.image = image
            return
        }
        
        // if nil image was sent back, we need to set the image view accordingly, so it can stop its loading animation.
        if image == nil {
            imageView.stopPosterImageLoadingAnimation()
            imageView.image = nil
        }
    }
    
    public func setName(_ text: String) {
        nameLabel.text = text
        nameLabel.font = UIFont.systemFont(ofSize: 14.0)
    }
    
    public func setNameHidden() {
        nameLabel.text = "?"
        nameLabel.font = UIFont.systemFont(ofSize: 18.0, weight: .medium)
    }
    
    public func setSubtitle(_ text: String) {
        subtitleLabel.text = text
        subtitleLabel.font = UIFont.systemFont(ofSize: 13.0)
    }
}
