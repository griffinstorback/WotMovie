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
}

protocol EnterGuessProtocol {
    func showResults()
    func hideResults()
    func revealAnswer()
    func revealAsCorrect()
    func nextQuestion()
}

protocol GuessDetailViewDelegate: NSObjectProtocol {
    func displayError()
    func reloadData()
}

class GuessDetailViewController: DetailViewController {
    
    let guessDetailViewPresenter: GuessDetailPresenterProtocol
    var state: GuessDetailViewState
    
    var parentPresenter: TransitionPresenterProtocol?
    
    // needs container because contentstackview.alignment == .fill
    private let showHintButtonContainer: UIView!
    private let showHintButton: ShrinkOnTouchButton!
    
    // enter guess field at bottom
    private let enterGuessViewController: EnterGuessViewController!
    private let enterGuessContainerView: UIView!
    private var enterGuessContainerViewTopConstraint: NSLayoutConstraint!
    
    init(item: Entity, posterImageView: PosterImageView, startHidden: Bool, presenter: GuessDetailPresenterProtocol) {
        if startHidden {
            state = .fullyHidden
        } else {
            state = .revealed
        }
        
        guessDetailViewPresenter = presenter
        
        showHintButtonContainer = UIView()
        showHintButton = ShrinkOnTouchButton()
        showHintButton.layer.cornerRadius = 10
        
        enterGuessViewController = EnterGuessViewController(item: item)
        enterGuessContainerView = UIView()
        
        super.init(posterImageView: posterImageView, startHidden: startHidden)
        
        navigationItem.largeTitleDisplayMode = .never
        self.title = "?"
        view.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        layoutViews()
    }
    
    /*@objc func revealButtonPressed() {
        guessDetailViewPresenter.answerWasRevealed()
        state = .revealed
    }*/
    
    @objc func showHintButtonPressed() {
        guessDetailViewPresenter.hintWasShown()
        state = .hintShown
    }
    
    private func setupViews() {
        showHintButton.setTitle("Show hint", for: .normal)
        showHintButton.backgroundColor = Constants.Colors.defaultBlue
        showHintButton.titleLabel?.textColor = .white
        showHintButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        showHintButton.addTarget(self, action: #selector(showHintButtonPressed), for: .touchUpInside)
        
        enterGuessViewController.setDelegate(self)
        enterGuessContainerView.giveBlurredBackground(style: .systemThickMaterialLight)
    }
    
    private func layoutViews() {
        addEnterGuessView()
        
        // if state starts as revealed don't show "Enter movie name" field
        if state == .revealed {
            enterGuessViewController.setAnswerRevealed()
        }
    }
    
    private func addEnterGuessView() {
        view.addSubview(enterGuessContainerView)
        enterGuessContainerViewTopConstraint = enterGuessContainerView.topAnchor.constraint(equalTo: view.topAnchor)
        enterGuessContainerView.anchor(top: nil, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        addChild(enterGuessViewController)
        enterGuessContainerView.addSubview(enterGuessViewController.view)
        enterGuessViewController.view.anchor(top: enterGuessContainerView.topAnchor, leading: enterGuessContainerView.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: enterGuessContainerView.trailingAnchor)
        enterGuessViewController.didMove(toParent: self)
    }
    
    func addShowHintButton() {
        contentStackView.addArrangedSubview(showHintButtonContainer)
        
        showHintButtonContainer.addSubview(showHintButton)
        showHintButton.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: CGSize(width: 160, height: 50))
        showHintButton.anchorToCenter(yAnchor: showHintButtonContainer.centerYAnchor, xAnchor: showHintButtonContainer.centerXAnchor)
        
        showHintButtonContainer.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: CGSize(width: 0, height: 60))
    }
    
    func removeShowHintButton() {
        if contentStackView.subviews.contains(showHintButtonContainer) {
            contentStackView.removeArrangedSubview(showHintButtonContainer)
            showHintButtonContainer.removeFromSuperview()
        }
    }
}

extension GuessDetailViewController: EnterGuessProtocol {
    func showResults() {
        enterGuessContainerViewTopConstraint.isActive = true
    }
    
    func hideResults() {
        enterGuessContainerViewTopConstraint.isActive = false
    }
    
    func revealAnswer() {
        state = .revealed
        guessDetailViewPresenter.answerWasRevealed()
        enterGuessViewController.setAnswerRevealed()
        
        transitionPresenter?.setEntityAsRevealed(id: guessDetailViewPresenter.getID(), isCorrect: false)
    }
    
    func revealAsCorrect() {
        state = .revealed
        guessDetailViewPresenter.answerWasRevealedAsCorrect()
        enterGuessViewController.setAnswerRevealed()
        
        transitionPresenter?.setEntityAsRevealed(id: guessDetailViewPresenter.getID(), isCorrect: true)
    }
    
    func nextQuestion() {
        self.dismiss(animated: true)
    }
}

// main stack view methods
extension GuessDetailViewController {
    func addViewToStackView(_ view: UIView) {
        contentStackView.addArrangedSubview(view)
    }
    
    func addChildToStackView(_ child: UIViewController) {
        guard !children.contains(child) else {
            return
        }
        
        addChild(child)
        contentStackView.addArrangedSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func removeChildFromStackView(_ child: UIViewController) {
        guard child.parent != nil else {
            return
        }
        child.willMove(toParent: nil)
        contentStackView.removeArrangedSubview(child.view)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
}
