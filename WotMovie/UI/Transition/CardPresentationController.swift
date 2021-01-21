//
//  CardPresentationController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-11-13.
//

import UIKit

class CardPresentationController: UIPresentationController {
    
    private lazy var blurView = UIVisualEffectView(effect: nil)
    
    override var shouldRemovePresentersView: Bool {
        return false
    }
    
    override func presentationTransitionWillBegin() {
        let container = containerView!
        
        container.addSubview(blurView)
        blurView.anchor(top: container.topAnchor, leading: container.leadingAnchor, bottom: container.bottomAnchor, trailing: container.trailingAnchor)
        blurView.alpha = 0
        
        presentingViewController.beginAppearanceTransition(false, animated: false)
        
        presentedViewController.transitionCoordinator!.animate { context in
            UIView.animate(withDuration: 0.5) {
                self.blurView.effect = UIBlurEffect(style: .light)
                self.blurView.alpha = 1
            }
        }
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        presentingViewController.endAppearanceTransition()
    }
    
    override func dismissalTransitionWillBegin() {
        presentingViewController.beginAppearanceTransition(true, animated: true)
        
        // does this do anything? doesnt seem like it.
        //presentedViewController.transitionCoordinator!.animate { context in
            self.blurView.alpha = 0
        //}
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        presentingViewController.endAppearanceTransition()
        if completed {
            blurView.removeFromSuperview()
        }
    }
}
