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
    let guessDetailPresenter: GuessDetailPresenterProtocol // CURRENTLY NOT BEING USED. Is a ref here necessary?
    let entityType: EntityType
    var state: GuessDetailViewState
    
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
    func closeAll(_ action: UIAction) {
        UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController?.dismiss(animated: true)
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
    
    init(entityType: EntityType, posterImageView: PosterImageView, state: GuessDetailViewState, presenter: GuessDetailPresenterProtocol) {
        self.entityType = entityType
        self.state = state
        
        guessDetailPresenter = presenter
        
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
        //guard !displayingTopBanner else { return }
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
        
        // For testing if adding/removing ad causes any weird display issues in VC
        /*DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.removeTopBannerAd()
        }*/
    }
    
    private func removeTopBannerAd() {
        //guard displayingTopBanner else { return }
        displayingTopBanner = false
        
        print("*** REMOVING BANNER")
        
        // remove the banner, and hide the extra space in scrollview content
        topBannerAdView.removeFromSuperview()
        spacingFromTop.isHidden = true
        
        // For testing if adding/removing ad causes any weird display issues in VC
        /*DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.addTopBannerAd()
        }*/
    }
    
    private func setupViews() {
        Appodeal.setBannerDelegate(self)
        
        scrollView.delegate = self
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.isUserInteractionEnabled = true
        scrollView.delaysContentTouches = false
        scrollView.alwaysBounceVertical = true
        
        statusBarCoverView.giveBlurredBackground(style: .systemMaterial)
        //statusBarCoverView.alpha = 0
        
        contentStackView.axis = .vertical
        contentStackView.alignment = .fill
        contentStackView.spacing = 20
        contentStackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 150, right: 0)
        contentStackView.isLayoutMarginsRelativeArrangement = true
        
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)), for: .normal)
        closeButton.imageView?.contentMode = .scaleAspectFit
        closeButton.tintColor = .systemGray
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        
        let interaction = UIContextMenuInteraction(delegate: self)
        closeButton.addInteraction(interaction)
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
        scrollView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        
        scrollView.addSubview(contentStackView)
        contentStackView.anchor(top: scrollView.topAnchor, leading: scrollView.leadingAnchor, bottom: scrollView.bottomAnchor, trailing: scrollView.trailingAnchor)
        contentStackView.anchorSize(height: nil, width: scrollView.widthAnchor)
        
        // init spacing from top to 50, but change when ad is displayed if its larger/smaller (e.g. ipad ad height is 70)
        contentStackView.addArrangedSubview(spacingFromTop)
        spacingFromTopHeightConstraint = spacingFromTop.heightAnchor.constraint(equalToConstant: 50)
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
                //if guessDetailPresenter.item.isRevealed || guessDetailPresenter.item.correctlyGuessed {
                if state != .fullyHidden && state != .hintShown {
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
                } else {
                    cancelGesture(gesture)
                    cancelCurrentScroll()
                    presentRevealAndDismissConfirmation()
                }
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
    
    // optionally wait a specified amount of time before reenabling the gesture
    func cancelGesture(_ gesture: UIGestureRecognizer, reEnableAfter delay: TimeInterval? = nil) {
        gesture.isEnabled = false
        
        if let delay = delay {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                gesture.isEnabled = true
            }
        } else {
            gesture.isEnabled = true
        }
    }
    
    // makes it so user has to lift their finger and press again, to begin scrolling again.
    func cancelCurrentScroll() {
        scrollView.isScrollEnabled = false
        scrollView.isScrollEnabled = true
    }
    
    // called when user tries to dismiss detail view without revealing/guessing
    func presentRevealAndDismissConfirmation() {
        
        switch entityType {
        case .movie:
            BriefAlertView(title: "Guess or reveal the Movie before closing").present(duration: 2.0)
        case .tvShow:
            BriefAlertView(title: "Guess or reveal the TV Show before closing").present(duration: 2.0)
        case .person:
            BriefAlertView(title: "Guess or reveal the Person before closing").present(duration: 2.0)
        }
    
        /* OLD WAY not used now, because a single brief message is better:
                - This way, user doesn't feel burdened by an immediate choice: Give up or cancel.
                - Also, getting the user familiar with the "Reveal" button at the bottom left, instead of in an alert, will prepare
                        them better for next guess view they open.
         
        let alertController = UIAlertController(title: "Reveal", message: "Are you sure you want to reveal the answer?", preferredStyle: .alert)
        
        // do nothing on cancel, just return to guess detail view
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alertController.addAction(UIAlertAction(title: "Reveal", style: .default) { [weak self] _ in
            self?.guessDetailPresenter.answerWasRevealedDuringAttemptToDismiss()
        })
        
        self.present(alertController, animated: true)*/
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

// Allows user to hold down the X button at top right, to close all modals (if they have say 15 open, they shouldn't have to close each one by one)
extension DetailViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in
            let closeAllAction = self.makeCloseAllAction()
            return UIMenu(title: "", children: [closeAllAction])
        })
    }
    
    func makeCloseAllAction() -> UIAction {
        let closeAllAction = UIAction(title: "Close all", image: nil, identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off, handler: closeAll)
        return closeAllAction
    }
}

extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// main stack view methods
extension DetailViewController {
    func addViewToStackView(_ view: UIView) {
        contentStackView.addArrangedSubview(view)
    }
    
    func addChildToStackView(_ child: UIViewController) {
        guard !children.contains(child) else {
            return
        }
        
        addChild(child)
        contentStackView.addArrangedSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func removeChildFromStackView(_ child: UIViewController) {
        guard child.parent != nil else {
            return
        }
        child.willMove(toParent: nil)
        contentStackView.removeArrangedSubview(child.view)
        child.view.removeFromSuperview()
        child.removeFromParent()
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
