//
//  PosterImageView.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-19.
//

import UIKit

enum PosterImageViewState {
    case hidden
    case revealed
    case correctlyGuessed
    case correctlyGuessedWithoutCheckmark // This case exists so detailoverviewview and persondetailview can have the
                                          // checkmark in different spot, not on the poster image itself.
    
    case revealWhileDetailOpenButHideOnGrid // This case is used for when presenting a fullyHidden Person entity (b.c. user guesses based on the image)
    
    // When initializing from a detail view controller, check should not be shown on Image itself, but rather somewhere
    // on the detail view controller (as of now, top left)
    init(guessDetailState: GuessDetailViewState) {
        switch guessDetailState {
        case .fullyHidden, .hintShown:
            self = .hidden
        case .revealed, .revealedWithNoNextButton:
            self = .revealed
        case .correct, .correctWithNoNextButton:
            self = .correctlyGuessedWithoutCheckmark
        }
    }
}

class PosterImageView: CardView {

    // don't set state directly, use setState() instance method
    var state: PosterImageViewState = .hidden
    
    private let imageView: UIImageView
    override var bounds: CGRect {
        didSet {
            // update corner radius when bounds change.
            layer.cornerRadius = bounds.height * Constants.imageCornerRadiusRatio
            layer.masksToBounds = true
        }
    }
    
    // lazy because they're completely unneeded if the image is never "anonymized" (blurred out)
    private lazy var blurEffectView: UIVisualEffectView = {
        // Make it MaterialDark (instead of just Material), because the question mark has light tint, and it
        // shows up best on a dark background.
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.isUserInteractionEnabled = false
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        /*  VIBRANCY DOES ABSOLUTELY NOTHING?
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        blurView.contentView.addSubview(vibrancyView)
        //vibrancyView.anchor(top: blurView.contentView.topAnchor, leading: blurView.contentView.leadingAnchor, bottom: blurView.contentView.bottomAnchor, trailing: blurView.contentView.trailingAnchor)
        //vibrancyView.frame = blurView.frame
        */
        
        return blurView
    }()
    private lazy var questionMarkImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "question_mark"))
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0.3
        imageView.isUserInteractionEnabled = false
        
        // make question mark always on top of blur view
        imageView.layer.zPosition = 1
        return imageView
    }()
    private lazy var checkMarkImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "guessed_correct_icon"))
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    convenience init(state: PosterImageViewState) {
        self.init(frame: .zero)
        
        setState(state, animated: false)
    }
    
    override init(frame: CGRect) {
        imageView = UIImageView()
        
        super.init(frame: frame)
        
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        backgroundColor = .systemBackground
        imageView.backgroundColor = .systemGray4
        imageView.startPosterImageLoadingAnimation()
        // should it have border? if so, need to add cornerRadius code here. also, it looks kinda cool with no border
        //imageView.layer.borderWidth = 1
        //imageView.layer.borderColor = UIColor.systemGray4.cgColor
    }
    
    private func layoutViews() {
        // add the image view (where the poster image will be)
        addImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImage(_ image: UIImage?) {
        if let image = image {
            imageView.image = image
        } else {
            // Image was set to nil, meaning the network request failed, or no image exists for this entity. Stop loading animation
            imageView.image = nil
            imageView.stopPosterImageLoadingAnimation()
        }
    }
    
    // for creating copy of posterimageview (specifically, used in dismiss card animator)
    func getImage() -> UIImage? {
        return imageView.image
    }
    
    func addImageView() {
        addSubview(imageView)
        imageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
    }
    
    func setState(_ state: PosterImageViewState, animated: Bool) {
        // NOTE: order of add/removal matters. add question mark AFTER blur effect, but remove it BEFORE.
        switch state {
        case .hidden:
            addBlurEffectOverlay(animated: animated)
            addQuestionMarkOverlay(animated: animated)
            removeCheckMarkOverlay(animated: animated)
            
        case .revealed, .correctlyGuessedWithoutCheckmark, .revealWhileDetailOpenButHideOnGrid:
            removeQuestionMarkOverlay(animated: animated)
            removeBlurEffectOverlay(animated: animated)
            removeCheckMarkOverlay(animated: animated)
            
        case .correctlyGuessed:
            removeQuestionMarkOverlay(animated: animated)
            removeBlurEffectOverlay(animated: animated)
            addCheckMarkOverlay(animated: animated)
        }
        
        self.state = state
    }
    
    private func addBlurEffectOverlay(animated: Bool, duration: Double = 1.5) {
        guard !subviews.contains(blurEffectView) else {
            unhideOverlay(blurEffectView, animated: animated, duration: duration)
            return
        }
        
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
        guard subviews.contains(blurEffectView) else {
            return
        }
        
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
    
    private func addQuestionMarkOverlay(animated: Bool) {
        guard !subviews.contains(questionMarkImageView) else {
            unhideOverlay(questionMarkImageView, animated: animated, toAlpha: 0.3)
            return
        }
        
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
        guard subviews.contains(questionMarkImageView) else {
            return
        }
        
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
    
    private func addCheckMarkOverlay(animated: Bool) {
        guard !subviews.contains(checkMarkImageView) else {
            unhideOverlay(checkMarkImageView, animated: animated)
            return
        }
        
        if animated {
            checkMarkImageView.alpha = 0
            UIView.animate(withDuration: 1.0) {
                self.checkMarkImageView.alpha = 1
            }
        }
        
        addSubview(checkMarkImageView)
        
        // width equal to a third of views width
        checkMarkImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.33).isActive = true
        
        // height equal to width
        NSLayoutConstraint(item: checkMarkImageView, attribute: .height, relatedBy: .equal, toItem: checkMarkImageView, attribute: .width, multiplier: 1, constant: 0).isActive = true
        
        // 10 away from top left
        checkMarkImageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 0))
        
        
        // (NOT NECESSARY?) together, these two constraints hold view in top left.
        /*let aboveYAxisConstraint = NSLayoutConstraint(item: checkMarkImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 0.33, constant: 0)
        let leftOfXAxisConstraint = NSLayoutConstraint(item: checkMarkImageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 0.5, constant: 0)
        NSLayoutConstraint.activate([aboveYAxisConstraint, leftOfXAxisConstraint])*/
    }
    
    private func removeCheckMarkOverlay(animated: Bool) {
        guard subviews.contains(checkMarkImageView) else {
            return
        }
        
        if animated {
            UIView.animate(withDuration: 1.0, animations: {
                self.checkMarkImageView.alpha = 0
            }) { _ in
                self.checkMarkImageView.removeFromSuperview()
            }
        } else {
            checkMarkImageView.removeFromSuperview()
        }
    }
    
    private func hideOverlay(_ overlay: UIView, animated: Bool, duration: Double = 1.0) {
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
    
    private func unhideOverlay(_ overlay: UIView, animated: Bool, duration: Double = 1.0, toAlpha: CGFloat = 1.0) {
        overlay.isHidden = false
        
        if animated {
            UIView.animate(withDuration: duration) {
                overlay.alpha = toAlpha
            }
        } else {
            overlay.alpha = toAlpha
        }
    }
    
    // Decided against having posterimageview be the one to shrink when pressed - it was messing
    // with the collectionview cells.
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
