//
//  CardCollectionViewCell.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-11-14.
//

import UIKit

class CardCollectionViewCell: UICollectionViewCell {
    
    func resetTransform() {
        transform = .identity
    }
    
    /*override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        setSelected(true)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        setSelectedIfTouchWithinBoundsOfView(touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        unselectIfTouchWithinBoundsOfView(touches)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        setSelected(false)
    }*/
}
