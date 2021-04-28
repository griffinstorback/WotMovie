//
//  ListCategoryTableViewCell.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-02-03.
//

import UIKit

class ListCategoryTableViewCell: UITableViewCell {
    
    private var iconImageViewSize: CGSize {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return CGSize(width: 40, height: 40)
        case .pad:
            return CGSize(width: 50, height: 50)
        default:
            return CGSize(width: 40, height: 40)
        }
    }
    
    private let iconImageView: UIImageView
    private let containerView: UIView
    private let categoryLabel: UILabel

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        iconImageView = UIImageView()
        containerView = UIView()
        categoryLabel = UILabel()
        
        // make style value1, to display number on right side by arrow.
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.layer.masksToBounds = true
        
        containerView.clipsToBounds = false
        
        categoryLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        categoryLabel.textColor = .label
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

    func setIconImage(imageName: String, tintColor: UIColor? = nil) {
        iconImageView.image = UIImage(named: imageName)
        
        if let tintColor = tintColor {
            iconImageView.tintColor = tintColor
        }
    }
    
    func setCategoryLabelText(text: String) {
        categoryLabel.text = text
    }
}
