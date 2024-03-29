//
//  DismissCardAnimator.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-11-13.
//

import UIKit

class DismissCardAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    //static let relativeDurationBeforeNonInteractive: TimeInterval = 0.5
    //static let minimumScaleBeforeNonInteractive: CGFloat = 0.8
    
    static let dismissalAnimationDuration: TimeInterval = 0.5
    
    private let parameters: CardTransitionParameters
    
    private var transitionDriver: DismissCardTransitionDriver?
    
    init(parameters: CardTransitionParameters) {
        self.parameters = parameters
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return DismissCardAnimator.dismissalAnimationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        transitionDriver = DismissCardTransitionDriver(parameters: parameters, transitionContext: transitionContext)
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        transitionDriver = nil
    }
}

final class DismissCardTransitionDriver {
    
    let parameters: CardTransitionParameters
    let context: UIViewControllerContextTransitioning
    let container: UIView
    
    let screens: (presented: DetailViewController, presenter: DetailPresenterViewController?)
    
    let animatedContainerView: UIView
    let animatedContainerTopConstraint: NSLayoutConstraint
    let animatedContainerLeadingConstraint: NSLayoutConstraint
    let animatedContainerWidthConstraint: NSLayoutConstraint
    let animatedContainerHeightConstraint: NSLayoutConstraint
    
    let cardDetailView: UIView
    //let stretchCardToFillBottom: NSLayoutConstraint
    
    let cardDetailPosterImageViewCopy: PosterImageView
    
    init(parameters: CardTransitionParameters, transitionContext: UIViewControllerContextTransitioning, baseAnimator: UIViewPropertyAnimator? = nil) {
        self.parameters = parameters
        context = transitionContext
        container = transitionContext.containerView
        
        screens = (
            context.viewController(forKey: .from) as! DetailViewController,
            context.viewController(forKey: .to) as? DetailPresenterViewController
        )
        
        // Basically, use the state of the poster image view on detail screen, but if it is 'correctlyGuessedWithoutCheckmark'
        // change it to 'correctlyGuessed' so that checkmark will show on transition to grid
        let posterImageState: PosterImageViewState = screens.presented.posterImageView.state == .correctlyGuessedWithoutCheckmark ? .correctlyGuessed : screens.presented.posterImageView.state
        //print("***** presented detail poster image state: \(screens.presented.posterImageView.state), while computed state: \(posterImageState)")
        cardDetailPosterImageViewCopy = PosterImageView(state: posterImageState)
        
        // If a person type was presented, and was not guessed or revealed, it needs to animate back to a hidden state while on the grid.
        if screens.presented.posterImageView.state == .revealWhileDetailOpenButHideOnGrid {
            cardDetailPosterImageViewCopy.setState(.hidden, animated: false)
        }
        
        cardDetailPosterImageViewCopy.setImage(screens.presented.posterImageView.getImage())
        cardDetailPosterImageViewCopy.frame = screens.presented.posterImageView.convert(screens.presented.posterImageView.frame, to: container)
        cardDetailPosterImageViewCopy.layer.cornerRadius = cardDetailPosterImageViewCopy.frame.height * Constants.imageCornerRadiusRatio
        cardDetailPosterImageViewCopy.layer.masksToBounds = true
        
        //print("&&& cardDetailPosterImageViewCopy: ", cardDetailPosterImageViewCopy)
        
        // hide actual image view of modal were dismissing (replaced by copy)
        screens.presented.posterImageView.setImage(nil)
        screens.presented.posterImageView.backgroundColor = .white
                
        // take snapshot of view to animate away, and immediately hide original view
        cardDetailView = container.snapshotView(afterScreenUpdates: false)!
        //cardDetailView = context.view(forKey: .from)!.snapshotView(afterScreenUpdates: true)!
        context.view(forKey: .from)!.isHidden = true
        
        animatedContainerView = UIView()
        
        // debug
        /*animatedContainerView.layer.borderColor = UIColor.yellow.cgColor
        animatedContainerView.layer.borderWidth = 4
        cardDetailView.layer.borderColor = UIColor.red.cgColor
        cardDetailView.layer.borderWidth = 2
        cardDetailPosterImageViewCopy.layer.borderWidth = 3
        cardDetailPosterImageViewCopy.layer.borderColor = UIColor.blue.cgColor*/
        
        container.removeConstraints(container.constraints)
        
        // layout contraints
        container.addSubview(animatedContainerView)
        animatedContainerView.addSubview(cardDetailView)
        cardDetailView.anchor(top: animatedContainerView.topAnchor, leading: animatedContainerView.leadingAnchor, bottom: animatedContainerView.bottomAnchor, trailing: animatedContainerView.trailingAnchor)
        animatedContainerView.anchorToCenter(yAnchor: nil, xAnchor: animatedContainerView.centerXAnchor)
        animatedContainerTopConstraint = animatedContainerView.topAnchor.constraint(equalTo: container.topAnchor, constant: 0)
        animatedContainerLeadingConstraint = animatedContainerView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 0)
        animatedContainerWidthConstraint = animatedContainerView.widthAnchor.constraint(equalToConstant: cardDetailView.frame.width)
        animatedContainerHeightConstraint = animatedContainerView.heightAnchor.constraint(equalToConstant: cardDetailView.frame.height)
        NSLayoutConstraint.activate([animatedContainerTopConstraint,animatedContainerLeadingConstraint,animatedContainerWidthConstraint,animatedContainerHeightConstraint])
        
                
        // add posterimageview copy
        animatedContainerView.addSubview(cardDetailPosterImageViewCopy)
        
        container.layoutIfNeeded()
        
        // force card filling bottom?
        //stretchCardToFillBottom = screens.presented.posterImageView.bottomAnchor.constraint(equalTo: cardDetailView.bottomAnchor)
        
        UIView.animate(withDuration: DismissCardAnimator.dismissalAnimationDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: []) {
            self.animateCardViewBackToPlace()
        } completion: { _ in
            self.completion()
        }
        
        UIView.animate(withDuration: DismissCardAnimator.dismissalAnimationDuration * 0.6) {
            self.screens.presented.scrollView.contentOffset = .zero
        }
    }
    
    func animateCardViewBackToPlace() {
        //stretchCardToFillBottom.isActive = true
        //screens.presented.isFontStateHighlighted = false
        
        //cardDetailPosterImageViewCopy.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: parameters.fromView.frame.size)
        
        /*print("&&& animateCardViewBackToPlace parameters.fromView.frame: \(parameters.fromView.frame)")
        print("&&& animateCardViewBackToPlace parameters.fromCardFrameWithoutTransform.frame: \(parameters.fromCardFrameWithoutTransform)")*/
        
        cardDetailPosterImageViewCopy.frame = CGRect(x: 0, y: 0, width: parameters.fromView.frame.width, height: parameters.fromView.frame.height)
        cardDetailPosterImageViewCopy.layer.cornerRadius = parameters.fromView.layer.cornerRadius
        
        cardDetailView.layer.cornerRadius = parameters.fromView.layer.cornerRadius
        cardDetailView.layer.masksToBounds = true
        
        // back to identity
        cardDetailView.transform = CGAffineTransform.identity
        animatedContainerTopConstraint.constant = parameters.fromCardFrameWithoutTransform.minY
        animatedContainerLeadingConstraint.constant = parameters.fromCardFrameWithoutTransform.minX
        animatedContainerWidthConstraint.constant = parameters.fromCardFrameWithoutTransform.width
        animatedContainerHeightConstraint.constant = parameters.fromCardFrameWithoutTransform.height
        container.layoutIfNeeded()
    }
    
    func completion() {
        animatedContainerView.removeFromSuperview()

        let success = !context.transitionWasCancelled
        
        if success {
            cardDetailView.removeFromSuperview()
            parameters.fromView.isHidden = false
        } else {
            //screens.presented.isFontStateHighlighted = true
            
            //topTemporaryFix.isActive = false
            //stretchCardToFillBottom.isActive = false
            
            //cardDetailView.removeConstraint(topTemporaryFix)
            //cardDetailView.removeConstraint(stretchCardToFillBottom)
            
            // reset container constraints
            container.removeConstraints(container.constraints)
            cardDetailView.anchor(top: container.topAnchor, leading: container.leadingAnchor, bottom: container.bottomAnchor, trailing: container.trailingAnchor)
        }
        
        context.completeTransition(success)
    }
}
