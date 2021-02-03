//
//  ListCategoryTableViewCell.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-02-03.
//

import UIKit

class ListCategoryTableViewCell: UITableViewCell {
    
    private let iconImageView: UIImageView

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        iconImageView = UIImageView()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        
    }
    
    private func layoutViews() {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
