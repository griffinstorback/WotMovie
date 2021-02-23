//
//  EntityTableSectionHeaderView.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-27.
//

import UIKit

class EntityTableSectionHeaderView: UITableViewHeaderFooterView {
    static let height: CGFloat = 50
    
    private let title: UILabel!

    override init(reuseIdentifier: String?) {
        title = UILabel()
        title.font = UIFont.boldSystemFont(ofSize: 20)
        
        super.init(reuseIdentifier: reuseIdentifier)

        contentView.backgroundColor = .systemBackground
        layoutView()
    }
    
    private func layoutView() {
        addSubview(title)
        title.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
    }
    
    public func setTitle(_ text: String?) {
        title.text = text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
