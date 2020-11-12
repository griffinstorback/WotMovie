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

class GuessDetailViewController: UIViewController {
    
    let guessDetailViewPresenter: GuessDetailPresenter
    var state: GuessDetailViewState = .fullyHidden
    
    private let scrollView: UIScrollView!
    private let contentStackView: UIStackView!
    
    private let closeButton: UIButton!
    
    // needs container because contentstackview.alignment == .fill
    private let showHintButtonContainer: UIView!
    private let showHintButton: ShrinkOnTouchButton!
    
    // enter guess field at bottom
    private let enterGuessViewController: EnterGuessViewController!
    private let enterGuessContainerView: UIView!
    private var enterGuessContainerViewTopConstraint: NSLayoutConstraint!
    
    init(item: Entity) {
        guessDetailViewPresenter = GuessDetailPresenter(networkManager: NetworkManager.shared, imageDownloadManager: ImageDownloadManager.shared, item: item)
        
        scrollView = UIScrollView()
        contentStackView = UIStackView()
        
        closeButton = UIButton()
        
        showHintButtonContainer = UIView()
        showHintButton = ShrinkOnTouchButton()
        showHintButton.layer.cornerRadius = 10
        
        enterGuessViewController = EnterGuessViewController(item: item)
        enterGuessContainerView = UIView()
        
        super.init(nibName: nil, bundle: nil)
        
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
    
    @objc func closeButtonPressed() {
        self.dismiss(animated: true)
    }
    
    @objc func revealButtonPressed() {
        state = .revealed
    }
    
    @objc func showHintButtonPressed() {
        state = .hintShown
    }
    
    private func setupViews() {
        scrollView.isUserInteractionEnabled = true
        scrollView.delaysContentTouches = false
        
        contentStackView.axis = .vertical
        contentStackView.alignment = .fill
        contentStackView.spacing = 20
        contentStackView.layoutMargins = UIEdgeInsets(top: 60, left: 0, bottom: 150, right: 0)
        contentStackView.isLayoutMarginsRelativeArrangement = true
        
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.imageView?.contentMode = .scaleAspectFill
        closeButton.tintColor = .gray
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        
        showHintButton.setTitle("Show hint", for: .normal)
        showHintButton.backgroundColor = Constants.Colors.defaultBlue
        showHintButton.titleLabel?.textColor = .white
        showHintButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        showHintButton.addTarget(self, action: #selector(showHintButtonPressed), for: .touchUpInside)
        
        enterGuessViewController.setDelegate(self)
        enterGuessContainerView.giveBlurredBackground(style: .systemThickMaterialLight)
    }
    
    private func layoutViews() {
        
        view.addSubview(scrollView)
        // must anchor to safeAreaLayoutguide top and bottom. tried to go to view.top but kept freezing.
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor)
        
        scrollView.addSubview(contentStackView)
        contentStackView.anchor(top: scrollView.topAnchor, leading: scrollView.leadingAnchor, bottom: scrollView.bottomAnchor, trailing: scrollView.trailingAnchor)
        contentStackView.anchorSize(height: nil, width: scrollView.widthAnchor)
        
        addCloseButton()
        addEnterGuessView()
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
    
    private func addCloseButton() {
        view.addSubview(closeButton)
        closeButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: nil, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, size: CGSize(width: 54, height: 54))
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
    
    func scrollToTop() {
        scrollView.setContentOffset(.zero, animated: true)
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
        enterGuessViewController.setAnswerRevealed()
    }
    
    func nextQuestion() {
        self.dismiss(animated: true)
    }
    
    func checkAnswer(id: Int) -> Bool {
        return id == guessDetailViewPresenter.getID()
    }
}

extension GuessDetailViewController {
    func addViewToStackView(_ view: UIView) {
        contentStackView.addArrangedSubview(view)
    }
    
    func addChildToStackView(_ child: UIViewController) {
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
