//
//  FullScreenImageViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-04-28.
//

import UIKit

protocol FullScreenImageViewDelegate: NSObjectProtocol {
    func reloadData()
}

class FullScreenImageViewController: UIViewController {
    
    let fullScreenImagePresenter: FullScreenImagePresenterProtocol

    let scrollView: UIScrollView
    let imageView: UIImageView
    let closeButton: UIButton
    let loadingIndicatorOrErrorView: LoadingIndicatorOrErrorView
    
    init(item: Entity, presenter: FullScreenImagePresenterProtocol? = nil) {
        fullScreenImagePresenter = presenter ?? FullScreenImagePresenter(item: item)
        
        scrollView = UIScrollView()
        imageView = UIImageView()
        closeButton = UIButton()
        loadingIndicatorOrErrorView = LoadingIndicatorOrErrorView(state: .loading)
        
        super.init(nibName: nil, bundle: nil)
        
        setupViews()
        layoutViews()
        
        loadPosterImageFromPresenter()
    }
    
    private func loadPosterImageFromPresenter() {
        fullScreenImagePresenter.loadPosterImage { image in
            if let image = image {
                self.loadingIndicatorOrErrorView.state = .loaded
                self.imageView.image = image
            } else {
                self.loadingIndicatorOrErrorView.state = .error
            }
        }
    }
    
    private func setupViews() {
        fullScreenImagePresenter.setViewDelegate(self)
        
        scrollView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        view.giveBlurredBackground(style: .systemMaterial)
        scrollView.delegate = self
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.maximumZoomScale = 10
        
        imageView.contentMode = .scaleAspectFit
        
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)), for: .normal)
        closeButton.imageView?.contentMode = .scaleAspectFit
        closeButton.tintColor = .systemGray
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        
        loadingIndicatorOrErrorView.setDelegate(self)
        
        // close whenever tapped. this doesnt affect panning, or two finger zooming.
        let scrollViewTap = UITapGestureRecognizer(target: self, action: #selector(closeButtonPressed))
        scrollView.addGestureRecognizer(scrollViewTap)
    }
    
    private func layoutViews() {
        view.addSubview(scrollView)
        scrollView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        
        scrollView.addSubview(imageView)
        //imageView.anchorSize(height: scrollView.heightAnchor, width: scrollView.widthAnchor)
        imageView.heightAnchor.constraint(lessThanOrEqualTo: scrollView.heightAnchor).isActive = true
        imageView.widthAnchor.constraint(lessThanOrEqualTo: scrollView.widthAnchor).isActive = true
        imageView.anchorToCenter(yAnchor: scrollView.centerYAnchor, xAnchor: scrollView.centerXAnchor)
        
        view.addSubview(loadingIndicatorOrErrorView)
        loadingIndicatorOrErrorView.anchorToCenter(yAnchor: view.centerYAnchor, xAnchor: nil)
        loadingIndicatorOrErrorView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
        
        view.addSubview(closeButton)
        closeButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: nil, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, size: CGSize(width: 60, height: 60))
    }
    
    @objc func closeButtonPressed() {
        dismiss(animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FullScreenImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

extension FullScreenImageViewController: LoadingIndicatorOrErrorViewDelegate {
    func retryButtonPressed() {
        loadingIndicatorOrErrorView.state = .loading
        loadPosterImageFromPresenter()
    }
}

extension FullScreenImageViewController: FullScreenImageViewDelegate {
    func reloadData() {
        // not used right now - getting image involves passing a closure to Presenter's loadImage function
    }
}
