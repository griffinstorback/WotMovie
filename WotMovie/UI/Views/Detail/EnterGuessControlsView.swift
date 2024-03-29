//
//  EnterGuessControlsView.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-30.
//

import UIKit

protocol EnterGuessControlsDelegate: UISearchBarDelegate {
    func revealButtonPressed()
    func nextButtonPressed()
    func addToWatchlistButtonPressed()
}

class EnterGuessControlsView: UIView {
    private weak var delegate: EnterGuessControlsDelegate?
    
    // holds both horizontal stackviews
    private let containerStackView: UIStackView!
    
    // stackview shown when answer is still hidden
    private let currentlyGuessingStackView: UIStackView!
    private let enterGuessField: UISearchBar!
    private let revealButton: ShrinkOnTouchButton!
    
    // stackview shown when answer has been revealed
    private let answerRevealedStackView: UIStackView!
    private let nextButton: ShrinkOnTouchButton!
    private let addToWatchlistButton: LeftAlignedImageCenteredTextButton!
    
    init() {
        containerStackView = UIStackView()
        
        enterGuessField = UISearchBar()
        enterGuessField.delegate = delegate
        revealButton = ShrinkOnTouchButton()
        currentlyGuessingStackView = UIStackView()
        
        nextButton = ShrinkOnTouchButton()
        addToWatchlistButton = LeftAlignedImageCenteredTextButton()
        answerRevealedStackView = UIStackView()
        
        super.init(frame: .zero)
        
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .clear
        containerStackView.axis = .vertical
        
        
        currentlyGuessingStackView.axis = .horizontal
        currentlyGuessingStackView.spacing = 10
        
        enterGuessField.searchBarStyle = .minimal
        enterGuessField.tintColor = UIColor(named: "AccentColor") ?? Constants.Colors.defaultBlue
        
        let enterGuessFieldIcon = UIImage(named: "question_mark")?.withTintColor(UIColor(named: "AccentColor") ?? Constants.Colors.defaultBlue, renderingMode: .alwaysOriginal)
        enterGuessField.setImage(enterGuessFieldIcon, for: .search, state: .normal)
        
        revealButton.setTitle("Reveal", for: .normal)
        revealButton.setTitleColor(.white, for: .normal)
        revealButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        revealButton.backgroundColor = UIColor(named: "AccentColor") ?? Constants.Colors.defaultBlue
        revealButton.layer.cornerRadius = 10
        revealButton.addTarget(self, action: #selector(revealButtonPressed), for: .touchUpInside)
        
        
        answerRevealedStackView.axis = .horizontal
        answerRevealedStackView.spacing = 10
        answerRevealedStackView.distribution = .fillEqually
        
        nextButton.setTitle("Next", for: .normal)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        nextButton.backgroundColor = UIColor(named: "AccentColor") ?? Constants.Colors.defaultBlue
        nextButton.layer.cornerRadius = 10
        nextButton.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
        
        /*addToWatchlistButton.setTitle("Add to Watchlist", for: .normal)
        addToWatchlistButton.setTitleColor(.white, for: .normal)
        addToWatchlistButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        addToWatchlistButton.titleLabel?.numberOfLines = 2
        addToWatchlistButton.titleEdgeInsets = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 5)
        addToWatchlistButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        addToWatchlistButton.contentHorizontalAlignment = .leading*/
        addToWatchlistButton.backgroundColor = .black
        addToWatchlistButton.layer.cornerRadius = 10
        addToWatchlistButton.addTarget(self, action: #selector(addToWatchlistButtonPressed), for: .touchUpInside)
        
        layoutViews()
    }
    
    private func layoutViews() {
        currentlyGuessingStackView.addArrangedSubview(revealButton)
        revealButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        revealButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        currentlyGuessingStackView.addArrangedSubview(enterGuessField)
        
        answerRevealedStackView.addArrangedSubview(addToWatchlistButton)
        addToWatchlistButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        answerRevealedStackView.addArrangedSubview(nextButton)
        nextButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        addSubview(containerStackView)
        containerStackView.addArrangedSubview(currentlyGuessingStackView)
        containerStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
    }
    
    // pass button taps back to delegate of this view
    @objc func revealButtonPressed() {
        delegate?.revealButtonPressed()
    }
    @objc func nextButtonPressed() {
        delegate?.nextButtonPressed()
    }
    @objc func addToWatchlistButtonPressed() {
        delegate?.addToWatchlistButtonPressed()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public funcs
    
    public func setDelegate(_ delegate: EnterGuessControlsDelegate) {
        self.delegate = delegate
        self.enterGuessField.delegate = delegate
    }
    
    public func setAnswerWasRevealed() {
        currentlyGuessingStackView.removeFromSuperview()
        containerStackView.addArrangedSubview(answerRevealedStackView)
    }
    
    public func removeNextButton() {
        nextButton.removeFromSuperview()
    }
    
    public func setEnterGuessFieldPlaceholder(text: String) {
        enterGuessField.placeholder = text
    }
    
    public func setWatchlistButtonText(text: String) {
        //addToWatchlistButton.setTitle(text, for: .normal)
        addToWatchlistButton.setLabelText(text: text)
    }
    
    public func setWatchlistButtonImage(imageName: String) {
        //addToWatchlistButton.setImage(UIImage(named: imageName)?.withTintColor(.white), for: .normal)
        //addToWatchlistButton.setImage(UIImage(named: imageName)?.withTintColor(.white), for: .selected)
        addToWatchlistButton.setImageViewImage(imageName: imageName)
    }
    
    public func setShowsEnterGuessFieldCancelButton(_ showsCancelButton: Bool, animated: Bool) {
        enterGuessField.setShowsCancelButton(showsCancelButton, animated: animated)
    }
    
    public func setShowsRevealButton(_ showsRevealButton: Bool, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.revealButton.isHidden = !showsRevealButton
            }
        } else {
            revealButton.isHidden = !showsRevealButton
        }
    }
    
    public func shouldResignFirstReponder() {
        enterGuessField.resignFirstResponder()
    }
}
