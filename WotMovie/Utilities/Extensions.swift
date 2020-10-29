//
//  Extensions.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-13.
//

import Foundation
import UIKit

// MARK:- Extensions for layout

extension UIView {
    // returns a collection of constraints to anchor bounds of given view inside current view
    func constraintsForAnchoringTo(boundsOf view: UIView) -> [NSLayoutConstraint] {
        return [
            topAnchor.constraint(equalTo: view.topAnchor),
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor)
        ]
    }
    
    func anchor(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, trailing: NSLayoutXAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
        }
        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
    
    func anchorSize(height: NSLayoutDimension?, width: NSLayoutDimension?) {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let heightConstraint = height {
            heightAnchor.constraint(equalTo: heightConstraint).isActive = true
        }
        if let widthConstraint = width {
            widthAnchor.constraint(equalTo: widthConstraint).isActive = true
        }
    }
    
    func anchorToCenter(yAnchor: NSLayoutYAxisAnchor?, xAnchor: NSLayoutXAxisAnchor?) {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let yAnchor = yAnchor {
            centerYAnchor.constraint(equalTo: yAnchor).isActive = true
        }
        if let xAnchor = xAnchor {
            centerXAnchor.constraint(equalTo: xAnchor).isActive = true
        }
    }
}

extension NSLayoutConstraint {
    // more readable way of changing constraint priority
    func usingPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}


// MARK:- Appearance

extension UIView {
    // Give and update shadows
    func giveShadow(radius: CGFloat = 5.0) {
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.clear.cgColor

        layer.shadowColor = UIColor.separator.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2.0)
        layer.shadowRadius = radius
        layer.shadowOpacity = 1.0
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }
    func updateShadow() {
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }
}
