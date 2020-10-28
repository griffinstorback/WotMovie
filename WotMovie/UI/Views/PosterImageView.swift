//
//  PosterImageView.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-19.
//

import UIKit

class PosterImageView: UIImageView {

    // lazy because they're completely unneeded if the image is never "anonymized" (blurred out)
    private lazy var blurEffectView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        return view
    }()
    private lazy var questionMarkImageView: UIImageView = {
        return UIImageView() // TODO: - make question mark png - UIImageView(image: UIImage(named: "question_mark.png"))
    }()
    
    convenience init(startHidden: Bool) {
        self.init(frame: .zero)
        
        if startHidden {
            // Initially starts with blur on. Call removeBlurEffectOverlay when user has guessed it or given up.
            addBlurEffectOverlay(animated: false)
            
            // But animate the question mark on.
            //addQuestionMarkOverlay(animated: true)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
    }
    
    func addQuestionMarkOverlay(animated: Bool) {
        if animated {
            questionMarkImageView.alpha = 0
            UIView.animate(withDuration: 1.5) {
                self.questionMarkImageView.alpha = 1
            }
        }
        
        addSubview(questionMarkImageView)
        questionMarkImageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
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
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
