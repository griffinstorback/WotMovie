//
//  GuessDetailViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-13.
//

import UIKit

enum GuessDetailViewState {
    case fullyHidden
    case hintShown
    case revealed
    case revealedWithNoNextButton
    case correct
    case correctWithNoNextButton
}

protocol EnterGuessProtocol: NSObjectProtocol {
    func showResults(animated: Bool)
    func hideResults(animated: Bool)
    func revealAnswer()
    func revealAsCorrect()
    func addToFavoritesOrWatchlist()
    func removeFromFavoritesOrWatchlist()
    func nextQuestion()
}

// this protocol is implemented by subclasses of GuessDetailVC (TitleDetailVC and PersonDetailVC)
protocol GuessDetailViewDelegate: NSObjectProtocol {
    func displayErrorLoadingCredits()
    func reloadData()
    func updateItemOnEnterGuessView()
    func answerWasRevealedDuringAttemptToDismiss()
}

class GuessDetailViewController: DetailViewController {
    
    let guessDetailViewPresenter: GuessDetailPresenterProtocol
    //var state: GuessDetailViewState -- this now resides in parent, DetailViewController, but can be overriden here for didSet functionality
        
    // checkmark icon that is shown when correctly guessed
    private let checkMarkIconImageView: UIImageView
    private let checkMarkIconContainerView: UIView
    
    // needs container because contentstackview.alignment == .fill
    private let showHintButtonContainer: UIView
    private let showHintButton: ShrinkOnTouchButton
    
    // should be shown before info is added (to show network is loading, and also it should be there until view appears to prevent weird view size calculation of info views)
    private let loadingIndicatorOrErrorView: LoadingIndicatorOrErrorView
    
    // enter guess field at bottom
    private let enterGuessViewController: EnterGuessViewController
    private let enterGuessContainerView: UIView
    private var enterGuessContainerViewTopConstraint: NSLayoutConstraint!
    
    init(item: Entity, posterImageView: PosterImageView, state: GuessDetailViewState, presenter: GuessDetailPresenterProtocol) {
        //self.state = state // state is now held in parent, DetailViewController
        
        guessDetailViewPresenter = presenter
        
        checkMarkIconImageView = UIImageView(image: UIImage(named: "guessed_correct_icon"))
        checkMarkIconContainerView = UIView()
        
        showHintButtonContainer = UIView()
        showHintButton = ShrinkOnTouchButton()
        showHintButton.layer.cornerRadius = 10
        
        loadingIndicatorOrErrorView = LoadingIndicatorOrErrorView(state: .loading)
        
        enterGuessViewController = EnterGuessViewController(item: item)
        enterGuessContainerView = UIView()
        
        super.init(entityType: item.type, posterImageView: posterImageView, state: state, presenter: presenter)
        
        setupViews()
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reload item from core data - so that if item was added to watchlist or favorites in different modal, and that was dismissed to this one,
        // changes will be reflected.
        if state != .fullyHidden {
            let shouldSetLastViewedDate = state != .hintShown // don't set last viewed date if .hintshown
            guessDetailViewPresenter.reloadItemFromCoreData(shouldSetLastViewedDate: shouldSetLastViewedDate)
        }
    }
    
    @objc func showHintButtonPressed() {
        guessDetailViewPresenter.hintWasShown()
        state = .hintShown
    }
    
    private func setupViews() {
        navigationItem.largeTitleDisplayMode = .never
        self.title = "?"
        view.backgroundColor = .systemBackground
        
        checkMarkIconImageView.contentMode = .scaleAspectFit
        checkMarkIconImageView.isHidden = true
        checkMarkIconImageView.alpha = 0
        
        showHintButton.setTitle("Show hint", for: .normal)
        showHintButton.backgroundColor = UIColor(named: "AccentColor") ?? Constants.Colors.defaultBlue
        showHintButton.titleLabel?.textColor = .white
        showHintButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        showHintButton.addTarget(self, action: #selector(showHintButtonPressed), for: .touchUpInside)
        
        enterGuessViewController.setDelegate(self)
        enterGuessContainerView.giveBlurredBackground(style: .systemMaterial)
    }
    
    private func layoutViews() {
        addCheckMarkIconView()
        
        addEnterGuessView()
        
        // if state starts as revealed or correct, don't show "Enter movie name" field
        if state == .revealed || state == .correct {
            enterGuessViewController.setAnswerRevealed()
        } else if state == .revealedWithNoNextButton || state == .correctWithNoNextButton{
            enterGuessViewController.setNoNextButton()
        }
    }
    
    private func addCheckMarkIconView() {
        contentStackView.addArrangedSubview(checkMarkIconContainerView)
        checkMarkIconContainerView.anchor(top: nil, leading: nil, bottom: nil, trailing: nil)
        
        checkMarkIconContainerView.addSubview(checkMarkIconImageView)
        checkMarkIconImageView.anchor(top: checkMarkIconContainerView.topAnchor, leading: checkMarkIconContainerView.leadingAnchor, bottom: checkMarkIconContainerView.bottomAnchor, trailing: nil, padding: UIEdgeInsets(top: 5, left: 10, bottom: 0, right: 0), size: CGSize(width: 40, height: 40))
    }
    
    private func addEnterGuessView() {
        view.addSubview(enterGuessContainerView)
        enterGuessContainerViewTopConstraint = enterGuessContainerView.topAnchor.constraint(equalTo: statusBarCoverView.bottomAnchor)
        enterGuessContainerView.anchor(top: nil, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        addChild(enterGuessViewController)
        enterGuessContainerView.addSubview(enterGuessViewController.view)
        enterGuessViewController.view.anchor(top: enterGuessContainerView.topAnchor, leading: enterGuessContainerView.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: enterGuessContainerView.trailingAnchor)
        enterGuessViewController.didMove(toParent: self)
    }
    
    func addShowHintButton() {
        guard !contentStackView.arrangedSubviews.contains(showHintButtonContainer) else { return }
        
        // can't have loading indicator and show hint button on page at the same time
        //removeLoadingIndicator()
        
        contentStackView.addArrangedSubview(showHintButtonContainer)
        
        showHintButtonContainer.addSubview(showHintButton)
        showHintButton.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: CGSize(width: 160, height: 50))
        showHintButton.anchorToCenter(yAnchor: showHintButtonContainer.centerYAnchor, xAnchor: showHintButtonContainer.centerXAnchor)
        
        showHintButtonContainer.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: CGSize(width: 0, height: 60))
    }
    
    func removeShowHintButton() {
        guard contentStackView.arrangedSubviews.contains(showHintButtonContainer) else { return }
        
        contentStackView.removeArrangedSubview(showHintButtonContainer)
        showHintButtonContainer.removeFromSuperview()
        
        // Add the loading indicator immediately, to show info is loading. in most all cases, loading indicator will only show for a glimpse,
        // but if there is a network error, its important that the indicator be there.
        //addLoadingIndicator()
    }
    
    // Call this from subclasses (title and person detail VC) so that they are sent info like 'Retry button was pressed'
    func setLoadingIndicatorOrErrorViewDelegate(_ delegate: LoadingIndicatorOrErrorViewDelegate) {
        loadingIndicatorOrErrorView.setDelegate(delegate)
    }
    
    func addLoadingIndicatorOrErrorView() {
        // don't add loading indicator if it has already been added - also, don't add if show hint button is present
        guard !contentStackView.arrangedSubviews.contains(loadingIndicatorOrErrorView) && !contentStackView.arrangedSubviews.contains(showHintButtonContainer) else { return }
        
        contentStackView.addArrangedSubview(loadingIndicatorOrErrorView)
    }
    
    func displayErrorInLoadingIndicatorOrErrorView() {
        loadingIndicatorOrErrorView.state = .error
    }
    
    func removeLoadingIndicatorOrErrorView() {
        guard contentStackView.arrangedSubviews.contains(loadingIndicatorOrErrorView) else { return }
        
        loadingIndicatorOrErrorView.state = .loaded
        contentStackView.removeArrangedSubview(loadingIndicatorOrErrorView)
    }
    
    func addCheckMarkIcon(animated: Bool, duration: Double = 0.5) {
        if animated {
            checkMarkIconImageView.isHidden = false
            UIView.animate(withDuration: duration, animations:({
                self.checkMarkIconImageView.alpha = 1
            }))
        } else {
            checkMarkIconImageView.isHidden = false
            checkMarkIconImageView.alpha = 1
        }
    }
    
    // this generally shouldn't have to be used, but created it just in case
    func removeCheckMarkIcon(animated: Bool, duration: Double = 0.5) {
        if animated {
            UIView.animate(withDuration: duration, animations:({
                self.checkMarkIconImageView.alpha = 0
            })) { _ in
                self.checkMarkIconImageView.isHidden = true
            }
        } else {
            checkMarkIconImageView.alpha = 0
            checkMarkIconImageView.isHidden = true
        }
    }
    
    
    // --- FOLLOWING TWO METHODS satisfy conformance to GuessDetailViewDelegate, so subclasses (title, person detail vc) need not implement.
    // Call this when reloading from title/person detail presenter.
    func updateItemOnEnterGuessView() {
        enterGuessViewController.updateItem(item: guessDetailViewPresenter.item)
    }
    // (NOT USED ANYMORE) Call this from presenter when super class (DetailViewController) wants to reveal answer (because user tried to dismiss without revealing/guessing)
    func answerWasRevealedDuringAttemptToDismiss() {
        revealAnswer()
    }
}

extension GuessDetailViewController: EnterGuessProtocol {
    func showResults(animated: Bool) {
        enterGuessContainerViewTopConstraint.isActive = true
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func hideResults(animated: Bool) {
        enterGuessContainerViewTopConstraint.isActive = false
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func revealAnswer() {
        state = .revealed
        guessDetailViewPresenter.answerWasRevealed()
        enterGuessViewController.setAnswerRevealed()
        
        transitionPresenter?.setEntityAsRevealed(id: guessDetailViewPresenter.getID(), isCorrect: false)
    }
    
    func revealAsCorrect() {
        state = .correctWithNoNextButton
        guessDetailViewPresenter.answerWasRevealedAsCorrect()
        enterGuessViewController.setAnswerRevealed()
        addCheckMarkIcon(animated: true)
        
        transitionPresenter?.setEntityAsRevealed(id: guessDetailViewPresenter.getID(), isCorrect: true)
    }
    
    func addToFavoritesOrWatchlist() {
        transitionPresenter?.setEntityAsFavorite(id: guessDetailViewPresenter.getID(), entityWasAdded: true)
    }
    
    func removeFromFavoritesOrWatchlist() {
        transitionPresenter?.setEntityAsFavorite(id: guessDetailViewPresenter.getID(), entityWasAdded: false)
    }
    
    func nextQuestion() {
        self.dismiss(animated: true) {
            DispatchQueue.main.async {
                self.transitionPresenter?.presentNextQuestion(currentQuestionID: self.guessDetailViewPresenter.getID())
            }
        }
    }
}
