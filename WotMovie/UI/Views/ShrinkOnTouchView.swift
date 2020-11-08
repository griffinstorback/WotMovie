//
//  ShrinkOnTouchView.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-11-06.
//

import UIKit

class ShrinkOnTouchView: UIView {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        setSelected(true)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        if touchIsWithinBoundsOfView(touches) {
            setSelected(true)
        } else {
            setSelected(false)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        // if touch ended outside this view, ignore.
        guard touchIsWithinBoundsOfView(touches) else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.setSelected(false)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        setSelected(false)
    }
    
    private func touchIsWithinBoundsOfView(_ touches: Set<UITouch>) -> Bool {
        if let touchPoint = touches.first?.location(in: self) {
            if self.bounds.contains(touchPoint) {
                return true
            }
        }
        
        return false
    }
    
    private func setSelected(_ selected: Bool) {
        if selected {
            UIView.animate(withDuration: 0.2) {
                self.transform = CGAffineTransform.identity.scaledBy(x: 0.95, y: 0.95)
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
            }
        }
    }
}
