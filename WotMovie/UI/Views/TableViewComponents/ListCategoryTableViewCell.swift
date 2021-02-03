//
//  ListCategoryTableViewCell.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-02-03.
//

import UIKit

class ListCategoryTableViewCell: UITableViewCell {
    
    private let iconImageViewSize = CGSize(width: 40, height: 40)
    
    private let iconImageView: UIImageView
    private let containerView: UIView
    private let categoryLabel: UILabel

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        iconImageView = UIImageView()
        containerView = UIView()
        categoryLabel = UILabel()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.layer.masksToBounds = true
        
        containerView.clipsToBounds = false
        
        categoryLabel.font = UIFont.boldSystemFont(ofSize: 20)
        categoryLabel.textColor = .black
    }
    
    private func layoutViews() {
        contentView.addSubview(iconImageView)
        iconImageView.anchor(top: nil, leading: contentView.leadingAnchor, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0), size: iconImageViewSize)
        iconImageView.anchorToCenter(yAnchor: contentView.centerYAnchor, xAnchor: nil)
        
        contentView.addSubview(containerView)
        containerView.anchor(top: contentView.topAnchor, leading: iconImageView.trailingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0))
        
        containerView.addSubview(categoryLabel)
        categoryLabel.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setIconImage(imageName: String) {
        iconImageView.image = UIImage(named: imageName)
    }
    
    func setCategoryLabelText(text: String) {
        categoryLabel.text = text
    }
}
