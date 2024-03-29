//
//  PersonOverviewView.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-11-06.
//

import Foundation
import UIKit

class PersonOverviewView: UIView {
        
    let posterImageView: PosterImageView
    
    // stack view containing poster image in middle, with spacing on either side.
    // (This is a ridiculous solutionbut it is the only way i could get it to work correctly with the custom dismissal animation;
    //   what kept happening was the poster image would suddenly teleport to the right edge as it was dismissing)
    private lazy var posterImageVerticalContainerStackView: UIStackView = {
        let stackView = UIStackView()
        
        let innerHorizontalStackView = UIStackView()
        innerHorizontalStackView.addArrangedSubview(UIView())
        innerHorizontalStackView.addArrangedSubview(posterImageView)
        innerHorizontalStackView.addArrangedSubview(UIView())
        innerHorizontalStackView.axis = .horizontal
        
        stackView.addArrangedSubview(innerHorizontalStackView)
        
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "?"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    // is hidden while person is not revealed
    private lazy var metaInfoStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.addArrangedSubview(overviewTextView)
        stackView.addArrangedSubview(birthdayLabel)
        stackView.addArrangedSubview(deathdayLabel)
        stackView.addArrangedSubview(showMoreOrLessInfoButton)
        
        stackView.axis = .vertical
        return stackView
    }()
    private lazy var overviewTextView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = false
        textView.isEditable = false
        textView.backgroundColor = .systemBackground
        textView.font = UIFont.systemFont(ofSize: 17.0)
        textView.textContainer.maximumNumberOfLines = 3
        textView.textContainer.lineBreakMode = .byTruncatingTail
        return textView
    }()
    private lazy var birthdayLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    private lazy var deathdayLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    // if less info is shown, only show first couple lines of persons Bio - otherwise show whole bio, birthday and deathday
    private var moreInfoIsShowing: Bool = false // start off showing less info.
    private lazy var showMoreOrLessInfoButton: UIButton = {
        let button = UIButton()
        button.setTitle("Show more", for: .normal)
        button.setTitleColor(UIColor(named: "AccentColor") ?? Constants.Colors.defaultBlue, for: .normal)
        button.addTarget(self, action: #selector(showMoreOrLessInfoButtonPressed), for: .touchUpInside)
        button.isHidden = true // start off as hidden - when overview is set, if there is an overview, it will unhide.
        return button
    }()
    @objc private func showMoreOrLessInfoButtonPressed() {
        if moreInfoIsShowing {
            // show less info
            overviewTextView.textContainer.maximumNumberOfLines = 3
            overviewTextView.textContainer.lineBreakMode = .byTruncatingTail
            overviewTextView.invalidateIntrinsicContentSize()
            birthdayLabel.isHidden = true
            deathdayLabel.isHidden = true
            
            showMoreOrLessInfoButton.setTitle("Show more", for: .normal)
            moreInfoIsShowing = false
        } else {
            // show more info
            overviewTextView.textContainer.maximumNumberOfLines = 0
            overviewTextView.invalidateIntrinsicContentSize()
            if let birthday = birthdayLabel.text, !birthday.isEmpty { birthdayLabel.isHidden = false }
            if let deathday = deathdayLabel.text, !deathday.isEmpty { deathdayLabel.isHidden = false }
            
            showMoreOrLessInfoButton.setTitle("Show less", for: .normal)
            moreInfoIsShowing = true
        }
    }
    
    // contains all info except the poster image
    private lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(metaInfoStackView)
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.backgroundColor = .systemBackground
        stackView.alignment = .fill
        
        return stackView
    }()
    
    init(frame: CGRect, guessState: GuessDetailViewState) {
        posterImageView = PosterImageView(state: PosterImageViewState(guessDetailState: guessState))
        posterImageView.layer.cornerRadius = Constants.PersonOverviewPosterImage.size.height * Constants.imageCornerRadiusRatio
        posterImageView.layer.masksToBounds = true
        
        super.init(frame: frame)
        
        setupViews()
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .systemBackground
    }
    
    private func layoutViews() {
        addSubview(posterImageVerticalContainerStackView)
        posterImageVerticalContainerStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor)
        
        posterImageView.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: Constants.PersonOverviewPosterImage.size)
        
        // image aspect ratio will change and look wonky while being presented if we don't have this aspect ratio constraint
        posterImageView.widthAnchor.constraint(equalTo: posterImageView.heightAnchor, multiplier: 2/3).isActive = true
        
        // centerXAnchor solutions for this layout kept causing image to teleport to right edge as it was being dismissed (custom dismissal animation)
        //posterImageView.anchorToCenter(yAnchor: nil, xAnchor: centerXAnchor)
        
        addSubview(verticalStackView)
        verticalStackView.anchor(top: posterImageVerticalContainerStackView.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 5, left: 10, bottom: 0, right: 10))
    }
    
    public func setName(_ text: String) {
        nameLabel.text = text
    }
    
    // don't need to deal with image loading animation here, its handled in PosterImageView
    public func setPosterImage(_ image: UIImage?, _ imagePath: String?) {
        posterImageView.setImage(image)
    }
    
    public func setOverviewText(_ text: String) {
        // if there is any overview, add the "show more info button" which show the rest of the overview/birthday and deathday
        if text.isEmpty {
            showMoreOrLessInfoButton.isHidden = true
        } else {
            showMoreOrLessInfoButton.isHidden = false
        }
        
        overviewTextView.text = text
    }
    
    public func setBirthday(_ text: String?) {
        birthdayLabel.text = text
    }
    
    public func setDeathday(_ text: String?) {
        deathdayLabel.text = text
    }
    
    public func setPosterImageState(_ state: PosterImageViewState, animated: Bool) {
        posterImageView.setState(state, animated: animated)
    }
}

