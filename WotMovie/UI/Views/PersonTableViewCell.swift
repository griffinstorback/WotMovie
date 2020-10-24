//
//  PersonTableViewCell.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-22.
//

import UIKit

class PersonTableViewCell: UITableViewCell {
    
    static let cellHeight: CGFloat = 60
    private let profileImageViewSize = CGSize(width: 50, height: 50)
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        //imageView.layer.cornerRadius = profileImageViewSize.width/2
        //imageView.layer.masksToBounds = true
        //imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.clipsToBounds = false
        return view
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        
        // replace image with N/A image
        setImage(image: UIImage(systemName: "x.circle.fill"))
    }
    
    func setupViews() {
        contentView.addSubview(profileImageView)
        profileImageView.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: nil, padding: UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0), size: CGSize(width: profileImageViewSize.width, height: 0))
        
        contentView.addSubview(containerView)
        containerView.anchor(top: contentView.topAnchor, leading: profileImageView.trailingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor)
        
        containerView.addSubview(nameLabel)
        nameLabel.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, bottom: nil, trailing: containerView.trailingAnchor)
        
        containerView.addSubview(subtitleLabel)
        subtitleLabel.anchor(top: nameLabel.bottomAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        imageView?.image = nil
    }
    
    func setImage(image: UIImage?) {
        if let image = image {
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
