//
//  RecentlyViewedCollectionViewHeader.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-01-26.
//

import Foundation
import UIKit

// used in WatchlistViewController
class RecentlyViewedCollectionViewHeader: UICollectionReusableView {
    
    // displays categories to select at the top, e.g. "Guessed", "Watchlist", "Favorites"
    // make sure to set delegate from calling class
    let categoryTableView: ContentSizedTableView
    let recentlyViewedTitle: UILabel
    
    override init(frame: CGRect) {
        categoryTableView = ContentSizedTableView()
        recentlyViewedTitle = UILabel()
        
        super.init(frame: .zero)
        
        categoryTableView.delaysContentTouches = false
        categoryTableView.isScrollEnabled = false
        categoryTableView.backgroundColor = .green
        recentlyViewedTitle.text = "Recently viewed"
        recentlyViewedTitle.font = UIFont.systemFont(ofSize: 20)
        
        layoutViews()
    }
    
    private func layoutViews() {
        addSubview(categoryTableView)
        categoryTableView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor)
        
        addSubview(recentlyViewedTitle)
        recentlyViewedTitle.anchor(top: categoryTableView.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 20, left: 10, bottom: 0, right: 10))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
