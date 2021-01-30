//
//  PosterImageView.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-19.
//

import UIKit

class PosterImageView: CardView {

    var isRevealed: Bool = false
    private let imageView: UIImageView
    
    // lazy because they're completely unneeded if the image is never "anonymized" (blurred out)
    private lazy var blurEffectView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        view.isUserInteractionEnabled = false
        return view
    }()
    private lazy var questionMarkImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "question_mark"))
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0.3
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    convenience init(startHidden: Bool) {
        self.init(frame: .zero)
        
        // add the image view (where the poster image will be)
        addImageView()

        if startHidden {
            isRevealed = false
            
            // Initially starts with blur on. Call removeBlurEffectOverlay when user has guessed it or given up.
            addBlurEffectOverlay(animated: false)
            
            // But animate the question mark on.
            addQuestionMarkOverlay(animated: false)
        }
    }
    
    override init(frame: CGRect) {
        imageView = UIImageView()
        
        super.init(frame: frame)
        
        backgroundColor = .white
    }
    
    func addImageView() {
        addSubview(imageView)
        imageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
    }
    
    func reveal(animated: Bool) {
        hideBlurEffectOverlay(animated: animated)
        hideQuestionMarkOverlay(animated: animated)
        isRevealed = true
    }
    
    func unreveal(animated: Bool) {
        unhideBlurEffectOverlay(animated: animated)
        unhideQuestionMarkOverlay(animated: animated)
        isRevealed = false
    }
    
    func hideBlurEffectOverlay(animated: Bool, duration: Double = 1.0) {
        hideOverlay(blurEffectView, animated: animated, duration: duration)
    }
    
    func hideQuestionMarkOverlay(animated: Bool, duration: Double = 1.0) {
        hideOverlay(questionMarkImageView, animated: animated, duration: duration)
    }
    
    func unhideBlurEffectOverlay(animated: Bool, duration: Double = 1.0) {
        unhideOverlay(blurEffectView, animated: animated, duration: duration)
    }
    
    func unhideQuestionMarkOverlay(animated: Bool, duration: Double = 1.0) {
        unhideOverlay(questionMarkImageView, animated: animated, duration: duration, toAlpha: 0.3)
    }
    
    func hideOverlay(_ overlay: UIView, animated: Bool, duration: Double = 1.0) {
        if animated {
            UIView.animate(withDuration: duration, animations:({
                overlay.alpha = 0
            })) { _ in
                overlay.isHidden = true
            }
        } else {
            overlay.alpha = 0
            overlay.isHidden = true
        }
    }
    
    func unhideOverlay(_ overlay: UIView, animated: Bool, duration: Double = 1.0, toAlpha: CGFloat = 1.0) {
        overlay.isHidden = false
        
        if animated {
            UIView.animate(withDuration: duration) {
                overlay.alpha = toAlpha
            }
        } else {
            overlay.alpha = toAlpha
        }
    }
    
    private func addBlurEffectOverlay(animated: Bool, duration: Double = 1.5) {
        if animated {
            blurEffectView.alpha = 0
            UIView.animate(withDuration: duration) {
                self.blurEffectView.alpha = 1.0
            }
        }
        
        addSubview(blurEffectView)
        blurEffectView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
    }
    
    private func removeBlurEffectOverlay(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 1.5, animations: {
                self.blurEffectView.alpha = 0
            }) { _ in
                self.blurEffectView.removeFromSuperview()
            }
        } else {
            blurEffectView.removeFromSuperview()
        }
        
        removeQuestionMarkOverlay(animated: true)
    }
    
    private func addQuestionMarkOverlay(animated: Bool) {
        if animated {
            questionMarkImageView.alpha = 0
            UIView.animate(withDuration: 1.5) {
                self.questionMarkImageView.alpha = 0.3
            }
        }
        
        addSubview(questionMarkImageView)
        questionMarkImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true
        questionMarkImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5).isActive = true
        questionMarkImageView.anchorToCenter(yAnchor: centerYAnchor, xAnchor: centerXAnchor)
    }
    
    private func removeQuestionMarkOverlay(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 1.0, animations: {
                self.questionMarkImageView.alpha = 0
            }) { _ in
                self.questionMarkImageView.removeFromSuperview()
            }
        } else {
            questionMarkImageView.removeFromSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImage(_ image: UIImage?) {
        imageView.image = image
    }
    
    // for creating copy of posterimageview (specifically, used in dismiss card animator)
    func getImage() -> UIImage? {
        return imageView.image
    }
    
    /*override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        print("touch began")
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
