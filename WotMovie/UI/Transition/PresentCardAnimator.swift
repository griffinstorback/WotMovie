//
//  PresentCardAnimator.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-11-13.
//

import UIKit

class PresentCardAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let parameters: CardTransitionParameters
    
    private let presentAnimationDuration: TimeInterval
    private let springAnimator: UIViewPropertyAnimator
    private var transitionDriver: PresentCardTransitionDriver?
    
    init(parameters: CardTransitionParameters) {
        self.parameters = parameters
        self.springAnimator = PresentCardAnimator.createBaseSpringAnimator(parameters: parameters)
        self.presentAnimationDuration = springAnimator.duration
        super.init()
    }
    
    private static func createBaseSpringAnimator(parameters: CardTransitionParameters) -> UIViewPropertyAnimator {
        // Damping between 0.7 (far away) and 1.0 (nearer)
        let cardPositionY = parameters.fromCardFrame.minY
        let distanceToBounce = abs(cardPositionY)
        let extentToBounce = cardPositionY < 0 ? parameters.fromCardFrame.height : UIScreen.main.bounds.height
        let dampFactorInterval: CGFloat = 0.3
        let damping = 1.0 - dampFactorInterval * (distanceToBounce/extentToBounce)
        
        // Duration between 0.5 and 0.9
        let baselineDuration: TimeInterval = 0.5
        let maxDuration: TimeInterval = 0.9
        let duration: TimeInterval = baselineDuration + (maxDuration - baselineDuration) * TimeInterval(max(0, distanceToBounce)/UIScreen.main.bounds.height)
        
        let springTiming = UISpringTimingParameters(dampingRatio: damping, initialVelocity: .init(dx: 0, dy: 0))
        return UIViewPropertyAnimator(duration: duration, timingParameters: springTiming)
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return presentAnimationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        transitionDriver = PresentCardTransitionDriver(parameters: parameters, transitionContext: transitionContext, baseAnimator: springAnimator)
        interruptibleAnimator(using: transitionContext).startAnimation()
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        transitionDriver = nil
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        return transitionDriver!.animator
    }
}

final class PresentCardTransitionDriver {
    
    let parameters: CardTransitionParameters
    let animator: UIViewPropertyAnimator
    let context: UIViewControllerContextTransitioning
    let container: UIView
    
    let screens: (presenter: DetailPresenterViewController?, presented: DetailViewController)
    
    let animatedContainerView: UIView
    let animatedContainerVerticalConstraint: NSLayoutConstraint
    let animatedContainerHorizontalConstraint: NSLayoutConstraint
    
    let cardDetailView: UIView
    let fromCardFrame: CGRect
    let cardWidthConstraint: NSLayoutConstraint
    let cardHeightConstraint: NSLayoutConstraint
    
    let cardDetailPosterImageViewCopy: PosterImageView
    
    init(parameters: CardTransitionParameters, transitionContext: UIViewControllerContextTransitioning, baseAnimator: UIViewPropertyAnimator) {
        self.parameters = parameters
        context = transitionContext
        container = context.containerView
        
        screens = (
            context.viewController(forKey: .from) as? DetailPresenterViewController,
            context.viewController(forKey: .to) as! DetailViewController
        )
        
        //cardDetailView = context.view(forKey: .to)!
        cardDetailView = screens.presented.view
        cardDetailPosterImageViewCopy = PosterImageView(startHidden: parameters.startHidden)
        cardDetailPosterImageViewCopy.setImage(screens.presented.posterImageView.getImage())
        cardDetailPosterImageViewCopy.frame = parameters.fromView.frame//.convert(parameters.fromView.frame, to: container)
        cardDetailPosterImageViewCopy.layer.cornerRadius = cardDetailPosterImageViewCopy.frame.height * Constants.imageCornerRadiusRatio
        cardDetailPosterImageViewCopy.layer.masksToBounds = true
        
        fromCardFrame = parameters.fromCardFrame
        
        // temporary container view for animation
        animatedContainerView = UIView()
        
        container.addSubview(animatedContainerView)
        animatedContainerView.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: container.bounds.size)
        animatedContainerVerticalConstraint = animatedContainerView.topAnchor.constraint(equalTo: container.topAnchor, constant: fromCardFrame.minY)
        animatedContainerHorizontalConstraint = animatedContainerView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: fromCardFrame.minX)
        NSLayoutConstraint.activate([animatedContainerVerticalConstraint, animatedContainerHorizontalConstraint])
        
        
        // Layout cardDetailView
        animatedContainerView.addSubview(cardDetailView)
        cardWidthConstraint = cardDetailView.widthAnchor.constraint(equalToConstant: fromCardFrame.width)
        cardHeightConstraint = cardDetailView.heightAnchor.constraint(equalToConstant: fromCardFrame.height)
        cardWidthConstraint.isActive = true
        cardHeightConstraint.isActive = true
        cardDetailView.translatesAutoresizingMaskIntoConstraints = false
        let verticalAnchor = cardDetailView.topAnchor.constraint(equalTo: animatedContainerView.topAnchor, constant: 0)
        verticalAnchor.isActive = true
        
        // add posterimageview copy
        //animatedContainerView.addSubview(cardDetailPosterImageViewCopy)
        
        cardDetailView.layer.cornerRadius = 10
        
        // hide and reset Cell in presenting view
        parameters.fromView.isHidden = true
        parameters.fromView.transform = .identity
        
        container.layoutIfNeeded()
        
        animator = baseAnimator

        animator.addAnimations {
            // spring animation for bouncing up
            self.animateContainerBouncingUp()
            
            // linear animation for expansion
            let cardExpanding = UIViewPropertyAnimator(duration: baseAnimator.duration * 0.6, curve: .linear) {
                self.animateCardDetailViewSizing()
            }
            cardExpanding.startAnimation()
        }
        
        animator.addCompletion { _ in
            self.completion()
        }
    }
    
    func animateContainerBouncingUp() {
        animatedContainerVerticalConstraint.constant = 0
        animatedContainerHorizontalConstraint.constant = 0
        
        /*print("***** screens presented poster : \(screens.presented.posterImageView)")
        print("***** carddetail view: \(cardDetailView)")
        print("***** container: \(container)")
        print("***** converrtted: \(screens.presented.posterImageView.convert(screens.presented.posterImageView.frame, to: cardDetailView))")
        print("***** context view forkey to: \(context.view(forKey: .to)!)")*/
        
        cardDetailPosterImageViewCopy.frame = screens.presented.posterImageView.convert(screens.presented.posterImageView.frame, to: cardDetailView)
        cardDetailPosterImageViewCopy.layer.cornerRadius = screens.presented.posterImageView.layer.cornerRadius
        
        container.layoutIfNeeded()
    }
    
    func animateCardDetailViewSizing() {
        
        
        cardWidthConstraint.constant = animatedContainerView.bounds.width
        cardHeightConstraint.constant = animatedContainerView.bounds.height
        cardDetailView.layer.cornerRadius = 0
        container.layoutIfNeeded()
    }
    
    func completion() {
        // remove temporary animatedContainerView
        animatedContainerView.removeFromSuperview()
        
        container.addSubview(cardDetailView)
        
        cardDetailView.removeConstraints([cardWidthConstraint, cardHeightConstraint])
        cardDetailView.anchor(top: container.topAnchor, leading: container.leadingAnchor, bottom: container.bottomAnchor, trailing: container.trailingAnchor)
                
        //screens.presented.cardBottomToRootBottomConstraint.isActive = false
        screens.presented.scrollView.isScrollEnabled = true
        
        let success = !context.transitionWasCancelled
        context.completeTransition(success)
    }
}
