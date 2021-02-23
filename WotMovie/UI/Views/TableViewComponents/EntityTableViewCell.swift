//
//  EntityTableViewCell.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-22.
//

import UIKit

class EntityTableViewCell: UITableViewCell {
    
    static let cellHeight: CGFloat = 80
    private let profileImageViewSize = CGSize(width: 50, height: 75)
    
    // stored to compare against incoming images in setImage (make sure they are correct image for path)
    private var imagePath: String = ""
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = EntityTableViewCell.cellHeight * Constants.imageCornerRadiusRatio
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.clipsToBounds = false
        return view
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .label
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layoutViews()
        
        // TODO replace image with N/A image
        //setImage(image: UIImage(systemName: "x.circle.fill"))
        profileImageView.backgroundColor = .lightGray
    }
    
    func layoutViews() {
        contentView.addSubview(profileImageView)
        profileImageView.anchor(top: nil, leading: contentView.leadingAnchor, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0), size: profileImageViewSize)
        profileImageView.anchorToCenter(yAnchor: contentView.centerYAnchor, xAnchor: nil)
        
        contentView.addSubview(containerView)
        containerView.anchor(top: contentView.topAnchor, leading: profileImageView.trailingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
        
        containerView.addSubview(nameLabel)
        nameLabel.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor)
        
        //containerView.addSubview(subtitleLabel)
        //subtitleLabel.anchor(top: nameLabel.bottomAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        profileImageView.image = nil
        imagePath = ""
    }
    
    func setImagePath(imagePath: String) {
        self.imagePath = imagePath
    }
    
    func setImage(image: UIImage?, imagePath: String?) {
        if let image = image, let imagePath = imagePath, self.imagePath == imagePath {
            profileImageView.image = image
        }
    }
    
    func setName(text: String) {
        nameLabel.text = text
    }
    
    func setSubtitle(text: String) {
        subtitleLabel.text = text
    }
}
