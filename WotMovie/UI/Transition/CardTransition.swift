//
//  CardTransition.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-11-13.
//

import UIKit

struct CardTransitionParameters {
    let fromCardFrame: CGRect
    let fromCardFrameWithoutTransform: CGRect
    let fromView: UIView
}

class CardTransition: NSObject, UIViewControllerTransitioningDelegate {
    let parameters: CardTransitionParameters
    
    init(parameters: CardTransitionParameters) {
        self.parameters = parameters
        super.init()
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentCardAnimator(parameters: parameters)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissCardAnimator(parameters: parameters)
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CardPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
