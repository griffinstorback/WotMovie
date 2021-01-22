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
    private var delegate: EnterGuessControlsDelegate?
    
    // holds both horizontal stackviews
    private let containerStackView: UIStackView!
    
    // stackview shown when answer is still hidden
    private let currentlyGuessingStackView: UIStackView!
    private let enterGuessField: UISearchBar!
    private let revealButton: ShrinkOnTouchButton!
    
    // stackview shown when answer has been revealed
    private let answerRevealedStackView: UIStackView!
    private let nextButton: ShrinkOnTouchButton!
    private let addToWatchlistButton: ShrinkOnTouchButton!
    
    init() {
        containerStackView = UIStackView()
        
        enterGuessField = UISearchBar()
        enterGuessField.delegate = delegate
        revealButton = ShrinkOnTouchButton()
        currentlyGuessingStackView = UIStackView()
        
        nextButton = ShrinkOnTouchButton()
        addToWatchlistButton = ShrinkOnTouchButton()
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
        enterGuessField.tintColor = Constants.Colors.defaultBlue
        
        let enterGuessFieldIcon = UIImage(named: "question_mark")?.withTintColor(Constants.Colors.defaultBlue, renderingMode: .alwaysOriginal)
        enterGuessField.setImage(enterGuessFieldIcon, for: .search, state: .normal)
        
        revealButton.setTitle("Reveal", for: .normal)
        revealButton.setTitleColor(.white, for: .normal)
        revealButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        revealButton.backgroundColor = Constants.Colors.defaultBlue
        revealButton.layer.cornerRadius = 10
        revealButton.addTarget(self, action: #selector(revealButtonPressed), for: .touchUpInside)
        
        
        answerRevealedStackView.axis = .horizontal
        answerRevealedStackView.spacing = 10
        answerRevealedStackView.distribution = .fillEqually
        
        nextButton.setTitle("Next", for: .normal)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        nextButton.backgroundColor = Constants.Colors.defaultBlue
        nextButton.layer.cornerRadius = 10
        nextButton.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
        
        addToWatchlistButton.setTitle("Add to Watchlist", for: .normal)
        addToWatchlistButton.setTitleColor(.white, for: .normal)
        addToWatchlistButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
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
        containerStackView.removeArrangedSubview(currentlyGuessingStackView)
        currentlyGuessingStackView.removeFromSuperview()
        containerStackView.addArrangedSubview(answerRevealedStackView)
    }
    
    public func setEnterGuessFieldPlaceholder(text: String) {
        enterGuessField.placeholder = text
    }
    
    public func setWatchlistButtonText(text: String) {
        addToWatchlistButton.setTitle(text, for: .normal)
    }
    
    public func setShowsEnterGuessFieldCancelButton(_ showsCancelButton: Bool, animated: Bool) {
        enterGuessField.setShowsCancelButton(showsCancelButton, animated: animated)
    }
    
    public func setShowsRevealButton(_ showsRevealButton: Bool, animated: Bool) {
        if showsRevealButton {
            revealButton.isHidden = false
        } else {
            revealButton.isHidden = true
        }
    }
    
    public func shouldResignFirstReponder() {
        enterGuessField.resignFirstResponder()
    }
}
