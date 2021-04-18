//
//  ButtonScrollView.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-04-16.
//

import UIKit

/*
 
 USED IN DetailViewController.

 makes it so that pressing down on a button and then draggin initiates scrolling
 (default functionality is the button press cancels all scrolling until lift finger)
 
 */

class ButtonScrollView: UIScrollView {
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view.isKind(of: UIButton.self) {
            return true
        }
        
        return super.touchesShouldCancel(in: view)
    }
}
