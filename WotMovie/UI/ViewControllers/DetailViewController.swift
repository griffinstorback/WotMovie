//
//  DetailViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-11-14.
//

import UIKit

class DetailViewController: UIViewController {
    
    // amount view will change when dragging down or on screen edge
    static let targetShrinkScale: CGFloat = 0.85
    static let targetCornerRadius: CGFloat = 15
    
    let scrollView: UIScrollView
    let contentStackView: UIStackView
    let posterImageView: PosterImageView
    
    var cardBottomToRootBottomConstraint: NSLayoutConstraint!
    
    var isDraggingDownToDismiss = false
    var interactiveStartingPoint: CGPoint?
    var dismissalAnimator: UIViewPropertyAnimator?
    func didCancelDismissalTransition() {
        interactiveStartingPoint = nil
        dismissalAnimator = nil
        isDraggingDownToDismiss = false
    }
    
    private let closeButton: UIButton!
    @objc func closeButtonPressed() {
        self.dismiss(animated: true)
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
    
    private func setupViews() {
        scrollView.delegate = self
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.isUserInteractionEnabled = true
        scrollView.delaysContentTouches = false
        scrollView.alwaysBounceVertical = true
        
        contentStackView.axis = .vertical
        contentStackView.alignment = .fill
        contentStackView.spacing = 20
        contentStackView.layoutMargins = UIEdgeInsets(top: 60, left: 0, bottom: 150, right: 0)
        contentStackView.isLayoutMarginsRelativeArrangement = true
        
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.imageView?.contentMode = .scaleAspectFill
        closeButton.tintColor = .gray
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
        // must anchor to safeAreaLayoutguide top and bottom. tried to go to view.top but kept freezing.
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor)
        
        scrollView.addSubview(contentStackView)
        contentStackView.anchor(top: scrollView.topAnchor, leading: scrollView.leadingAnchor, bottom: scrollView.bottomAnchor, trailing: scrollView.trailingAnchor)
        contentStackView.anchorSize(height: nil, width: scrollView.widthAnchor)
        
        // add close button to top right corner
        view.addSubview(closeButton)
        closeButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: nil, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, size: CGSize(width: 54, height: 54))
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
        if isDraggingDownToDismiss || (scrollView.isTracking && scrollView.contentOffset.y < 0) {
            isDraggingDownToDismiss = true
            scrollView.contentOffset = .zero
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
