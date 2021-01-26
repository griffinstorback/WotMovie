//
//  ContentSizedTableView.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-21.
//

import UIKit

// use this instead of tableview when you want tableview to resize its height according to its cells

class ContentSizedTableView: UITableView {
    
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
    
    override var style: UITableView.Style {
        return .plain
    }
}

class ContentSizedCollectionView: UICollectionView {
    
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}
