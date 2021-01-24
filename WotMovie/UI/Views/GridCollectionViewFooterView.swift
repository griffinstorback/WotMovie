//
//  GridCollectionViewFooterView.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-24.
//

import UIKit

class GridCollectionViewFooterView: UICollectionReusableView {
    
    private let loadingView: UIActivityIndicatorView!
    
    override init(frame: CGRect) {
        loadingView = UIActivityIndicatorView()
        loadingView.style = .medium
        loadingView.hidesWhenStopped = true
        
        super.init(frame: .zero)
    }
    
    public func startLoadingAnimation() {
        addSubview(loadingView)
        loadingView.anchorToCenter(yAnchor: centerYAnchor, xAnchor: centerXAnchor)
        
        loadingView.startAnimating()
    }
    
    public func stopLoadingAnimation() {
        loadingView.stopAnimating()
        loadingView.removeFromSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
