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
    
    // checkmark icon that is shown when correctly guessed
    private let checkMarkIconImageView: UIImageView
    
    // needs container because contentstackview.alignment == .fill
    private let showHintButtonContainer: UIView
    private let showHintButton: ShrinkOnTouchButton
    
    // enter guess field at bottom
    private let enterGuessViewController: EnterGuessViewController
    private let enterGuessContainerView: UIView
    private var enterGuessContainerViewTopConstraint: NSLayoutConstraint!
    
    init(item: Entity, posterImageView: PosterImageView, startHidden: Bool, fromGuessGrid: Bool, presenter: GuessDetailPresenterProtocol) {
        if startHidden {
            state = .fullyHidden
        } else {
            
            // only show next button if being presented from guess grid view
            if fromGuessGrid {
                state = .revealed
            } else {
                state = .revealedWithNoNextButton
            }
        }
        
        guessDetailViewPresenter = presenter
        
        checkMarkIconImageView = UIImageView(image: UIImage(named: "guessed_correct_icon"))
        
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
    
    @objc func showHintButtonPressed() {
        guessDetailViewPresenter.hintWasShown()
        state = .hintShown
    }
    
    private func setupViews() {
        checkMarkIconImageView.contentMode = .scaleAspectFit
        checkMarkIconImageView.isHidden = true
        checkMarkIconImageView.alpha = 0
        
        showHintButton.setTitle("Show hint", for: .normal)
        showHintButton.backgroundColor = Constants.Colors.defaultBlue
        showHintButton.titleLabel?.textColor = .white
        showHintButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        showHintButton.addTarget(self, action: #selector(showHintButtonPressed), for: .touchUpInside)
        
        enterGuessViewController.setDelegate(self)
        enterGuessContainerView.giveBlurredBackground(style: .systemThickMaterialLight)
    }
    
    private func layoutViews() {
        addCheckMarkIconView()
        
        addEnterGuessView()
        
        // if state starts as revealed don't show "Enter movie name" field
        if state == .revealed {
            enterGuessViewController.setAnswerRevealed()
        } else if state == .revealedWithNoNextButton {
            enterGuessViewController.setNoNextButton()
        }
    }
    
    private func addCheckMarkIconView() {
        view.addSubview(checkMarkIconImageView)
        checkMarkIconImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 0), size: CGSize(width: 40, height: 40))
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
