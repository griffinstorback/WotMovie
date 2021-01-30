//
//  DetailPresenterViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-11-13.
//

import UIKit

// Any class which presents detail modal must extend this class.
class DetailPresenterViewController: UIViewController {
    
    private var transition: CardTransition?
    
    func present(_ viewController: UIViewController, fromCard: UIView, startHidden: Bool, presenter: TransitionPresenterProtocol?, entityID: Int) {
        
        // Freeze highlighted state or else it will bounce back??
        //cell.freezeAnimations()
        
        // get current frame on screen
        let currentCardFrame = fromCard.layer.presentation()!.frame
        
        // convert current frame to screen's coordinates
        let cardPresentationFrameOnScreen = fromCard.superview!.convert(currentCardFrame, to: nil)
        
        // get card frame without transform in screen's coordinates (for dismissing back to original location later)
        let cardFrameWithoutTransform = { () -> CGRect in
            let center = fromCard.center
            let size = fromCard.bounds.size
            let r = CGRect(
                x: center.x - size.width/2,
                y: center.y - size.height/2,
                width: size.width,
                height: size.height
            )
            return fromCard.superview!.convert(r, to: nil)
        }()
        
        let parameters = CardTransitionParameters(fromCardFrame: cardPresentationFrameOnScreen, fromCardFrameWithoutTransform: cardFrameWithoutTransform, fromView: fromCard, startHidden: startHidden, presenter: presenter, entityID: entityID)
        transition = CardTransition(parameters: parameters)
        viewController.transitioningDelegate = transition
        //viewController.modalPresentationCapturesStatusBarAppearance = true
        viewController.modalPresentationStyle = .custom
        
        present(viewController, animated: true) { [weak fromCard] in
            //cell.unfreezeAnimations
        }
    }
    
    // should be overriden and implemented in calling VC, so that if card is revealed in detail, presenter will show changes too.
    /*func setEntityAsRevealed(id: Int, isRevealed: Bool) {
        print("*** DetailPresenterVC: setEntity with id \(id) as \(isRevealed ? "revealed" : "NOT revealed")")
    }*/
    
    /*func present(_ viewController: UIViewController, fromCard: UIView, fromView: UIView, startHidden: Bool) {
        
        // Freeze highlighted state or else it will bounce back??
        //cell.freezeAnimations()
        
        // get current frame on screen
        let currentCardFrame = fromView.layer.presentation()!.frame
        
        // convert current frame to screen's coordinates
        let cardPresentationFrameOnScreen = fromView.superview!.convert(currentCardFrame, to: nil)
        
        // get card frame without transform in screen's coordinates (for dismissing back to original location later)
        let cardFrameWithoutTransform = { () -> CGRect in
            let center = fromView.center
            let size = fromView.bounds.size
            let r = CGRect(
                x: center.x - size.width/2,
                y: center.y - size.height/2,
                width: size.width,
                height: size.height
            )
            return fromView.superview!.convert(r, to: nil)
        }()
        
        let parameters = CardTransitionParameters(fromCardFrame: cardPresentationFrameOnScreen, fromCardFrameWithoutTransform: cardFrameWithoutTransform, fromView: fromCard, startHidden: startHidden)
        transition = CardTransition(parameters: parameters)
        viewController.transitioningDelegate = transition
        //viewController.modalPresentationCapturesStatusBarAppearance = true
        viewController.modalPresentationStyle = .custom
        
        present(viewController, animated: true) { [weak fromCard] in
            //cell.unfreezeAnimations
        }
    }*/
}
