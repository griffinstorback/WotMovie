//
//  RecentlyViewedCollectionViewHeader.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-01-26.
//

import Foundation
import UIKit

// used in ListViewController
class RecentlyViewedCollectionViewHeader: UICollectionReusableView {
    
    // These are static so they can be used in other classes (specifically ListViewController) to
    // calculate header height.
    static let categoryTableViewCellHeight: CGFloat = 80 // multiply this by # cells to get tableview height
    static let recentlyViewedTitleHeight: CGFloat = 80
    static let spaceFromTop: CGFloat = 10
    
    // displays categories to select at the top, e.g. "Guessed", "Watchlist", "Favorites"
    // make sure to set delegate from calling class
    let categoryTableView: ContentSizedTableView
    
    let recentlyViewedTitleContainer: UIView
    let recentlyViewedTitle: UILabel
    
    override init(frame: CGRect) {
        categoryTableView = ContentSizedTableView()
        
        recentlyViewedTitleContainer = UIView()
        recentlyViewedTitle = UILabel()
        
        super.init(frame: .zero)
        
        categoryTableView.delaysContentTouches = false
        categoryTableView.isScrollEnabled = false
        categoryTableView.tableFooterView = UIView()
        
        recentlyViewedTitle.text = "Recently viewed"
        //recentlyViewedTitle.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        recentlyViewedTitle.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        //recentlyViewedTitle.font = UIFont.boldSystemFont(ofSize: 24)
        
        layoutViews()
    }
    
    private func layoutViews() {
        addSubview(categoryTableView)
        categoryTableView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: UIEdgeInsets(top: RecentlyViewedCollectionViewHeader.spaceFromTop, left: 0, bottom: 0, right: 0))
        
        addSubview(recentlyViewedTitleContainer)
        recentlyViewedTitleContainer.anchor(top: categoryTableView.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, size: CGSize(width: 0, height: RecentlyViewedCollectionViewHeader.recentlyViewedTitleHeight))
        
        recentlyViewedTitleContainer.addSubview(recentlyViewedTitle)
        recentlyViewedTitle.anchor(top: nil, leading: recentlyViewedTitleContainer.leadingAnchor, bottom: recentlyViewedTitleContainer.bottomAnchor, trailing: recentlyViewedTitleContainer.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 10, bottom: 5, right: 10))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
