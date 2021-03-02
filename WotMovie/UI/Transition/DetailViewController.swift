//
//  DetailViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-11-14.
//

import UIKit
import Appodeal

// Detail modal must extend this class
class DetailViewController: UIViewController {
    
    weak var transitionPresenter: TransitionPresenterProtocol?
    
    // amount view will change when dragging down or on screen edge
    static let targetShrinkScale: CGFloat = 0.85
    static let targetCornerRadius: CGFloat = 20
    
    let scrollView: UIScrollView
    
    let statusBarCoverView: UIView
    var topBannerAdView: UIView
    var displayingTopBanner: Bool = false
    
    // space from top is needed when a banner ad is visible.
    let spacingFromTop: UIView
    var spacingFromTopHeightConstraint: NSLayoutConstraint?
    
    let contentStackView: UIStackView
    let posterImageView: PosterImageView // keep reference to poster image, as its different if TitleDetail vs PersonDetail (so we can animate dismissal where the poster image returns to where it was on parent)
    
    private let closeButton: UIButton!
    @objc func closeButtonPressed() {
        self.dismiss(animated: true)
    }
    
    //var cardBottomToRootBottomConstraint: NSLayoutConstraint!
    
    var isDraggingDownToDismiss = false
    var interactiveStartingPoint: CGPoint?
    var dismissalAnimator: UIViewPropertyAnimator?
    func didCancelDismissalTransition() {
        interactiveStartingPoint = nil
        dismissalAnimator = nil
        isDraggingDownToDismiss = false
    }
    
    
    
    private lazy var dismissalPanGesture: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer()
        pan.maximumNumberOfTouches = 1
        return pan
    }()
    private lazy var dismissalScreenEdgePanGesture: UIScreenEdgePanGestureRecognizer = {
        let edgePan = UIScreenEdgePanGestureRecognizer()
        edgePan.edges = .left
        return edgePan
    }()
    
    init(posterImageView: PosterImageView) {
        scrollView = UIScrollView()
        
        statusBarCoverView = UIView()
        topBannerAdView = UIView()
        
        spacingFromTop = UIView()
        
        contentStackView = UIStackView()
        self.posterImageView = posterImageView
        
        closeButton = UIButton()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupGestures()
        layoutViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addTopBannerAd()
    }
    
    private func addTopBannerAd() {
        displayingTopBanner = true
        
        if let banner = Appodeal.banner() {
            let bannerHeight = banner.frame.height
            print("*** ADDING BANNER, SIZE: \(banner.frame)")
            // add the banner view
            topBannerAdView = banner
            statusBarCoverView.addSubview(topBannerAdView)
            topBannerAdView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: statusBarCoverView.leadingAnchor, bottom: statusBarCoverView.bottomAnchor, trailing: statusBarCoverView.trailingAnchor, size: CGSize(width: 0, height: bannerHeight))

            // add spacing to top of scrollview content, so that banner doesnt overlay the checkmark/title
            spacingFromTop.isHidden = false
            spacingFromTopHeightConstraint?.constant = bannerHeight
        } else {
            print("**** NO BANNER returned from Appodeal.banner()")
        }
        
        /*DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.removeTopBannerAd()
        }*/
    }
    
    private func removeTopBannerAd() {
        displayingTopBanner = false
        
        print("*** REMOVING BANNER")
        
        // remove the banner, and hide the extra space in scrollview content
        topBannerAdView.removeFromSuperview()
        spacingFromTop.isHidden = true
        
        /*DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.addTopBannerAd()
        }*/
    }
    
    private func setupViews() {
        Appodeal.setBannerDelegate(self)
        
        scrollView.delegate = self
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.isUserInteractionEnabled = true
        scrollView.delaysContentTouches = true
        scrollView.alwaysBounceVertical = true
        
        statusBarCoverView.giveBlurredBackground(style: .systemMaterial)
        //statusBarCoverView.alpha = 0
        
        contentStackView.axis = .vertical
        contentStackView.alignment = .fill
        contentStackView.spacing = 20
        contentStackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 150, right: 0)
        contentStackView.isLayoutMarginsRelativeArrangement = true
        
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.imageView?.contentMode = .scaleAspectFit
        closeButton.tintColor = .systemGray
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
    }
    
    private func setupGestures() {
        dismissalPanGesture.addTarget(self, action: #selector(handleDismissalPan(gesture:)))
        dismissalPanGesture.delegate = self
        
        dismissalScreenEdgePanGesture.addTarget(self, action: #selector(handleDismissalPan(gesture:)))
        dismissalScreenEdgePanGesture.delegate = self
        
        // make (drag down pan gesture) and (scrollview scroll down gesture) wait for (screen edge pan gesture) to fail
        dismissalPanGesture.require(toFail: dismissalScreenEdgePanGesture)
        scrollView.panGestureRecognizer.require(toFail: dismissalScreenEdgePanGesture)
        
        loadViewIfNeeded()
        view.addGestureRecognizer(dismissalPanGesture)
        view.addGestureRecognizer(dismissalScreenEdgePanGesture)
    }
    
    private func layoutViews() {
        view.addSubview(scrollView)
        // must anchor to view.top, not safearea, so that statusBarCoverView covers status bar
        scrollView.anchor(top: view.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor)
        
        scrollView.addSubview(contentStackView)
        contentStackView.anchor(top: scrollView.topAnchor, leading: scrollView.leadingAnchor, bottom: scrollView.bottomAnchor, trailing: scrollView.trailingAnchor)
        contentStackView.anchorSize(height: nil, width: scrollView.widthAnchor)
        
        // init spacing from top to 50, but change when ad is displayed if its larger/smaller (e.g. ipad ad height is 70)
        contentStackView.addArrangedSubview(spacingFromTop)
        spacingFromTop.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: CGSize(width: 0, height: 50))
        spacingFromTopHeightConstraint = spacingFromTop.heightAnchor.constraint(equalToConstant: 70)
        spacingFromTopHeightConstraint?.isActive = true
        spacingFromTop.isHidden = true
        
        // add the status bar cover view, which will contain the banner ad
        scrollView.addSubview(statusBarCoverView)
        statusBarCoverView.anchor(top: scrollView.topAnchor, leading: scrollView.leadingAnchor, bottom: nil, trailing: scrollView.trailingAnchor)
        let statusBarCoverBottomConstraint = statusBarCoverView.bottomAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor)
        statusBarCoverBottomConstraint.isActive = true
        
        // add close button to top right corner
        scrollView.addSubview(closeButton)
        closeButton.anchor(top: statusBarCoverView.bottomAnchor, leading: nil, bottom: nil, trailing: scrollView.trailingAnchor, size: CGSize(width: 54, height: 54))
    }
    
    @objc func handleDismissalPan(gesture: UIPanGestureRecognizer) {
        let isScreenEdgePan = gesture.isKind(of: UIScreenEdgePanGestureRecognizer.self)
        if !isScreenEdgePan && !isDraggingDownToDismiss {
            return
        }
        
        let targetAnimatedView = gesture.view!
        let currentLocation = gesture.location(in: nil)
        let startingPoint: CGPoint
        
        if let interactiveStartingPoint = interactiveStartingPoint {
            startingPoint = interactiveStartingPoint
        } else {
            startingPoint = currentLocation
            interactiveStartingPoint = startingPoint
        }
        
        let progress = isScreenEdgePan ? gesture.translation(in: targetAnimatedView).x / 100 : (currentLocation.y - startingPoint.y) / 100
        
        switch gesture.state {
        case .began:
            dismissalAnimator = createInteractiveDismissalAnimatorIfNeeded(targetAnimatedView, progress: progress)
        case .changed:
            dismissalAnimator = createInteractiveDismissalAnimatorIfNeeded(targetAnimatedView, progress: progress)
            dismissalAnimator?.fractionComplete = progress
            
            let isDismissalSuccess = progress >= 1.0
            if isDismissalSuccess {
                dismissalAnimator?.stopAnimation(false)
                dismissalAnimator?.addCompletion { [weak self] position in
                    switch position {
                    case .end:
                        self?.dismiss(animated: true)
                    default:
                        print("ERROR: Must finish dismissal at end!")
                    }
                }
                dismissalAnimator?.finishAnimation(at: .end)
            }
            
        case .ended, .cancelled:
            if dismissalAnimator == nil {
                print("ERROR: Gesture was too quick, there's no animator")
                didCancelDismissalTransition()
                return
            }
            
            // animate back to start
            dismissalAnimator?.pauseAnimation()
            dismissalAnimator?.isReversed = true
            
            // disable gesture until animation back to start finishes
            gesture.isEnabled = false
            dismissalAnimator?.addCompletion { [weak self] position in
                self?.didCancelDismissalTransition()
                gesture.isEnabled = true
            }
            
            dismissalAnimator?.startAnimation()
        default:
            print("ERROR: Impossible gesture state: ", gesture.state.rawValue)
        }
    }
    
    func createInteractiveDismissalAnimatorIfNeeded(_ targetAnimatedView: UIView, progress: CGFloat) -> UIViewPropertyAnimator {
        if let animator = dismissalAnimator {
            return animator
        } else {
            let animator = UIViewPropertyAnimator(duration: 0, curve: .linear) {
                targetAnimatedView.transform = .init(scaleX: DetailViewController.targetShrinkScale, y: DetailViewController.targetShrinkScale)
                targetAnimatedView.layer.cornerRadius = DetailViewController.targetCornerRadius
            }
            animator.isReversed = false
            animator.pauseAnimation()
            animator.fractionComplete = progress
            return animator
        }
    }
}

extension DetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y
        
        if isDraggingDownToDismiss || (scrollView.isTracking && contentOffset < 0) {
            isDraggingDownToDismiss = true
            scrollView.contentOffset = .zero
        }
        
        // hide or unhide the opaque view under status bar, depending on if scrolled to top or not.
        if contentOffset <= 20 && !displayingTopBanner {
            statusBarCoverView.alpha = max(min(contentOffset/20, 1), 0)
        } else {
            statusBarCoverView.alpha = 1
        }
                
        scrollView.showsVerticalScrollIndicator = !isDraggingDownToDismiss
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // this prevents scrolling when user drag down and lift finger fast at the top
        if velocity.y > 0 && scrollView.contentOffset.y <= 0 {
            scrollView.contentOffset = .zero
        }
    }
    
    func scrollToTop() {
        scrollView.setContentOffset(.zero, animated: true)
    }
}

extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension DetailViewController: AppodealBannerDelegate {
    func bannerDidLoadAdIsPrecache(_ precache: Bool) {
        print("*** BANNER DID LOAD AD IS PRECACHE")
    }
    
    func bannerDidShow() {
        print("*** BANNER DID SHOW")
    }
    
    // banner failed to load
    func bannerDidFailToLoadAd() {
        print("*** BANNER DID FAIL TO LOAD AD")
    }
    
    // banner was clicked
    func bannerDidClick() {
        print("*** BANNER DID CLICK")
    }
    
    // banner did expire and could not be shown
    func bannerDidExpired() {
        print("*** BANNER DID EXPIRED")
    }
}
