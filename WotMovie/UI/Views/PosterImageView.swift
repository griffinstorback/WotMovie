//
//  PosterImageView.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-19.
//

import UIKit

class PosterImageView: CardView {

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
    
    func addBlurEffectOverlay(animated: Bool) {
        if animated {
            blurEffectView.alpha = 0
            UIView.animate(withDuration: 1.5) {
                self.blurEffectView.alpha = 1.0
            }
        }
        
        addSubview(blurEffectView)
        blurEffectView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
    }
    
    func removeBlurEffectOverlay(animated: Bool) {
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
    
    func addQuestionMarkOverlay(animated: Bool) {
        if animated {
            questionMarkImageView.alpha = 0
            UIView.animate(withDuration: 1.5) {
                self.questionMarkImageView.alpha = 0.3
            }
        }
        
        addSubview(questionMarkImageView)
        questionMarkImageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 50, left: 35, bottom: 50, right: 35))
    }
    
    func removeQuestionMarkOverlay(animated: Bool) {
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
