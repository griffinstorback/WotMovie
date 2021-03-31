//
//  LoadingIndicatorOrErrorView.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-03-31.
//

import UIKit

enum LoadingIndicatorOrErrorViewState {
    case loading
    case loaded
    case error
}

protocol LoadingIndicatorOrErrorViewDelegate: NSObjectProtocol {
    func retryButtonPressed()
}

class LoadingIndicatorOrErrorView: UIView {
    var state: LoadingIndicatorOrErrorViewState {
        didSet {
            switch state {
            case .loading:
                addLoadingIndicatorAndRemoveError()
            case .error:
                addErrorAndRemoveLoadingIndicator()
            case .loaded:
                removeBothErrorAndRemoveLoadingIndicator()
            }
        }
    }
    
    weak var delegate: LoadingIndicatorOrErrorViewDelegate?
    public func setDelegate(_ delegate: LoadingIndicatorOrErrorViewDelegate) {
        self.delegate = delegate
    }
    
    private let loadingAndErrorContainer: UIView
    private let loadingIndicator: UIActivityIndicatorView
    private let errorText: UILabel
    private let errorRetryButton: UIButton

    init(state: LoadingIndicatorOrErrorViewState = .loading) {
        self.state = state
        
        loadingAndErrorContainer = UIView()
        loadingIndicator = UIActivityIndicatorView(style: .large)
        errorText = UILabel()
        errorRetryButton = UIButton()
        
        super.init(frame: .zero)
        
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        loadingIndicator.hidesWhenStopped = true
        errorText.text = "Error loading credits. Check your network connection and try again."
        errorText.textAlignment = .center
        errorText.textColor = .secondaryLabel
        errorText.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        errorText.numberOfLines = 0
        errorRetryButton.setTitle("Retry", for: .normal)
        errorRetryButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        errorRetryButton.setTitleColor(UIColor(named: "AccentColor") ?? Constants.Colors.defaultBlue, for: .normal)
        errorRetryButton.addTarget(self, action: #selector(retryLoadingCredits), for: .touchUpInside)
    }
    
    private func layoutViews() {
        switch state {
        case .loading:
            addLoadingIndicatorAndRemoveError()
        case .error:
            addErrorAndRemoveLoadingIndicator()
        case .loaded:
            break
        }
    }
    
    private func addLoadingIndicatorAndRemoveError() {
        if subviews.contains(errorText) {
            errorText.removeFromSuperview()
        }
        if subviews.contains(errorRetryButton) {
            errorRetryButton.removeFromSuperview()
        }
        
        guard !subviews.contains(loadingIndicator) else { return }
        
        addSubview(loadingIndicator)
        loadingIndicator.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        
        loadingIndicator.startAnimating()
    }
    
    private func addErrorAndRemoveLoadingIndicator() {
        if subviews.contains(loadingIndicator) {
            loadingIndicator.stopAnimating()
            loadingIndicator.removeFromSuperview()
        }
        
        addSubview(errorText)
        errorText.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 20))
        //errorText.anchorToCenter(yAnchor: nil, xAnchor: centerXAnchor)
        
        addSubview(errorRetryButton)
        errorRetryButton.anchor(top: errorText.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, size: CGSize(width: 0, height: 50))
        //errorRetryButton.anchorToCenter(yAnchor: nil, xAnchor: centerXAnchor)
    }
    
    private func removeBothErrorAndRemoveLoadingIndicator() {
        errorText.removeFromSuperview()
        errorRetryButton.removeFromSuperview()
        loadingIndicator.removeFromSuperview()
    }
    
    @objc func retryLoadingCredits() {        
        guard let delegate = delegate else {
            print("** ERROR: Credits were attempted to be reloaded, but no delegate was set in LoadingIndicatorOrErrorView.")
            return
        }
        
        state = .loading
        delegate.retryButtonPressed()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
