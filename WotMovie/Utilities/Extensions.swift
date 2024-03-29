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
    
    func giveBlurredBackground(style: UIBlurEffect.Style) {
        backgroundColor = .clear
        
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        insertSubview(blurEffectView, at: 0)
    }
    
// MARK: - "Scale down size" animation
    /*
     THIS METHOD SHOULD NOT BE USED - Previously, it was used to only unselect an object if the touch was within bounds of its view,
     but this meant if object was tapped on very edge, it would not detect as within its bounds, because the view shrinks from the tap,
     so the object would remain shrunk after being tapped. There was also no benefit here: there's no point in not unshrinking an object
     after a tap is recognized.
     
     It's commented out now, in case I want to reference it for some reason in the future. But if you're reading this, it likely can be deleted.
     
    func unselectIfTouchWithinBoundsOfView(_ touches: Set<UITouch>) {
        // if touch ended outside this view, ignore.
        guard touchIsWithinBoundsOfView(touches) else {
            return
        }
        
        self.setSelected(false)
    }*/
    
    func setSelectedIfTouchWithinBoundsOfView(_ touches: Set<UITouch>) {
        if touchIsWithinBoundsOfView(touches) {
            setSelected(true)
        } else {
            setSelected(false)
        }
    }
    
    func touchIsWithinBoundsOfView(_ touches: Set<UITouch>) -> Bool {
        if let touchPoint = touches.first?.location(in: self) {
            if self.bounds.contains(touchPoint) {
                return true
            }
        }
        
        return false
    }
    
    func setSelected(_ selected: Bool) {
        if selected {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 3, options: [.curveEaseOut, .allowUserInteraction]) {
                self.transform = CGAffineTransform.identity.scaledBy(x: 0.95, y: 0.95)
            }
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 3, options: [.curveEaseOut, .allowUserInteraction]) {
                self.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
            }
        }
    }
}

// PUT THIS IN ITS OWN VIEW? FOR IMAGE VIEWS TO INHERIT FROM?
extension UIImageView {
    func startPosterImageLoadingAnimation() {
        backgroundColor = .systemGray3
        
        let animation = UIView.animate(withDuration: 0.6, delay: 0, options: [.autoreverse, .repeat]) {
            self.backgroundColor = .systemGray6
        }
    }
    
    func stopPosterImageLoadingAnimation() {
        layer.removeAllAnimations()
        UIView.animate(withDuration: 0.3) {
            self.backgroundColor = .systemGray4
        }
    }
}

extension UIViewController {
    func addChildViewController(_ child: UIViewController) {
        guard !children.contains(child) else {
            return
        }
        
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func removeChildViewController(_ child: UIViewController) {
        guard child.parent != nil else {
            return
        }
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
}

extension UIAlertController {
    static func actionSheetWithItems<A: Equatable>(controllerTitle: String, items: [(title: String, value: A)], currentSelection: A? = nil, action: @escaping (A) -> Void) -> UIAlertController {
        let alertController = UIAlertController(title: controllerTitle, message: nil, preferredStyle: .actionSheet)
        
        for (var title, value) in items {
            if let selection = currentSelection, value == selection {
                title = "✔︎ " + title
            }
            
            alertController.addAction(UIAlertAction(title: title, style: .default) { _ in
                action(value)
            })
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alertController.view.tintColor = UIColor(named: "AccentColor") ?? Constants.Colors.defaultBlue
        
        return alertController
    }
}

extension UICollectionView {
    static func createHorizontalLayout(absoluteHeight: CGFloat = 0) -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize: NSCollectionLayoutSize
        if absoluteHeight == 0 { // no height was provided, make it fill
            groupSize = NSCollectionLayoutSize(widthDimension: .absolute(100), heightDimension: .fractionalHeight(1))
        } else {
            groupSize = NSCollectionLayoutSize(widthDimension: .absolute(100), heightDimension: .absolute(absoluteHeight))
        }

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 5
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .horizontal
        
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: config)
        return layout
    }
}

// TODO: Trying to compare two arrays, returning indices where they differ, for reloading collection views (like in GuessGridPresenter)
/*extension Array<T> {
    func differentIndices<T>(_ array1: [T], _ array2: [T]) where T:Comparable {
        var changedIndices: [Int] = []
        for index in 0..<count {
            if index + 1 > array2.count {
                changedIndices.append(index)
                continue
            }
            if self.[index] != array2[index] {
                changedIndices.append(index)
            }
        }
    }
}
*/

// MARK: - NOTIFICATIONS

extension Notification.Name {
    // send from UpgradePresenter when user upgrades - receive wherever upgrade status affects view
    static let WMUserDidUpgrade = Notification.Name("WMUserDidUpgradeNotification")
}
