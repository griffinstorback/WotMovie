//
//  GuessViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-13.
//

import UIKit

protocol GuessViewDelegate: NSObjectProtocol {
    func reloadData()
    func presentBriefAlertThatUserUnlockedPersonGuessing()
}

class GuessViewController: UIViewController {
    
    private let guessViewPresenter: GuessPresenterProtocol
    
    private let statusBarCoverView: UIView
    private let scrollView: UIScrollView
    
    private let titleLabel: UILabel
    
    private let guessCategoryStackViewContainer: UIView
    private let guessCategoryStackView: UIStackView
    private var guessCategoryViews: [GuessCategoryView]
    
    init(presenter: GuessPresenterProtocol? = nil) {
        // use presenter if provided, otherwise use default
        guessViewPresenter = presenter ?? GuessPresenter()
        
        statusBarCoverView = UIView()
        scrollView = UIScrollView()
        
        titleLabel = UILabel()
        
        guessCategoryStackViewContainer = UIView()
        guessCategoryStackView = UIStackView()
        guessCategoryViews = []
        
        super.init(nibName: nil, bundle: nil)
        
        setupViews()
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // hide nav bar on this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        guessViewPresenter.updateGuessedCounts()
        
        // only update progress number if the person category hasn't been unlocked yet (obviously)
        if guessViewPresenter.isPersonCategoryLocked() {
            guessViewPresenter.updateUnlockProgress()
        }
    }
    
    func setupViews() {
        guessViewPresenter.setViewDelegate(guessViewDelegate: self)
        view.backgroundColor = .systemBackground
        
        // Navigation view controller
        //navigationItem.title = "WotMovie"
        //navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = UIBarButtonItem(image: UIImage(named: "question_mark"), style: .plain, target: nil, action: nil)
        
        scrollView.isUserInteractionEnabled = true
        scrollView.delaysContentTouches = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.delegate = self
        statusBarCoverView.giveBlurredBackground(style: .systemMaterial)
        statusBarCoverView.alpha = 0
        
        titleLabel.text = "WotMovie"
        titleLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        guessCategoryStackView.axis = .vertical
        guessCategoryStackView.alignment = .fill
        guessCategoryStackView.spacing = 20
        guessCategoryStackView.layoutMargins = UIEdgeInsets(top: 30, left: 0, bottom: 30, right: 0)
        guessCategoryStackView.isLayoutMarginsRelativeArrangement = true
        
        // add categories to guessCategoryViews list
        var categoryView: GuessCategoryView
        if let movieCategory = guessViewPresenter.getCategoryFor(type:.movie) {
            categoryView = GuessCategoryView(category: movieCategory)
            categoryView.setDelegate(self)
            guessCategoryViews.append(categoryView)
        }
        if let tvShowCategory = guessViewPresenter.getCategoryFor(type:.tvShow) {
            categoryView = GuessCategoryView(category: tvShowCategory)
            categoryView.setDelegate(self)
            guessCategoryViews.append(categoryView)
        }
        if let personCategory = guessViewPresenter.getCategoryFor(type: .person) {
            categoryView = GuessCategoryView(category: personCategory, categoryIsLocked: guessViewPresenter.isPersonCategoryLocked())
            categoryView.setDelegate(self)
            guessCategoryViews.append(categoryView)
        }
        if let statsCategory = guessViewPresenter.getCategoryFor(type:.stats) {
            categoryView = GuessCategoryView(category: statsCategory)
            categoryView.setDelegate(self)
            guessCategoryViews.append(categoryView)
        }
    }
    
    func layoutViews() {
        view.addSubview(scrollView)
        scrollView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        
        scrollView.addSubview(guessCategoryStackViewContainer)
        guessCategoryStackViewContainer.anchor(top: scrollView.topAnchor, leading: scrollView.leadingAnchor, bottom: scrollView.bottomAnchor, trailing: scrollView.trailingAnchor)
        guessCategoryStackViewContainer.anchorSize(height: nil, width: scrollView.widthAnchor)
        
        guessCategoryStackViewContainer.addSubview(guessCategoryStackView)
        //guessCategoryStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        //guessCategoryStackView.trailingAnchor.constraint(equalToSystemSpacingAfter: scrollView.trailingAnchor, multiplier: 0.1).isActive = true
        //guessCategoryStackView.anchorSize(height: nil, width: scrollView.widthAnchor)
        guessCategoryStackView.anchor(top: guessCategoryStackViewContainer.topAnchor, leading: nil, bottom: guessCategoryStackViewContainer.bottomAnchor, trailing: nil)
        guessCategoryStackView.anchorToCenter(yAnchor: nil, xAnchor: guessCategoryStackViewContainer.centerXAnchor)
        guessCategoryStackView.widthAnchor.constraint(equalTo: guessCategoryStackViewContainer.widthAnchor, multiplier: 0.9).isActive = true
                
        guessCategoryStackView.addArrangedSubview(titleLabel)
        
        for categoryView in guessCategoryViews {
            guessCategoryStackView.addArrangedSubview(categoryView)
        }
        
        scrollView.addSubview(statusBarCoverView)
        statusBarCoverView.anchor(top: scrollView.topAnchor, leading: scrollView.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: scrollView.trailingAnchor)
    }
}

extension GuessViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y
        
        // hide or unhide the opaque view under status bar, depending on if scrolled to top or not.
        if contentOffset <= 5 {
            statusBarCoverView.alpha = max(min(contentOffset/5, 1), 0)
        } else {
            statusBarCoverView.alpha = 1
        }
    }
}

extension GuessViewController: GuessCategoryViewDelegate {
    func categoryWasSelected(_ type: GuessCategory) {        
        let guessGridViewController = GuessGridViewController(for: type)
        navigationController?.pushViewController(guessGridViewController, animated: true)
    }
    
    func upgradeButtonPressed() {
        let upgradeViewController = UpgradeViewController()
        let navigationController = UINavigationController(rootViewController: upgradeViewController)
        navigationController.modalPresentationStyle = .pageSheet
        
        present(navigationController, animated: true)
    }
}

extension GuessViewController: GuessViewDelegate {
    func reloadData() {
        // reload guessed counts for each category
        for categoryView in guessCategoryViews {
            if let category = guessViewPresenter.getCategoryFor(type: categoryView.category.type) {
                categoryView.category = category
                
                // update purchase status for person category
                if category.type == .person {
                    categoryView.setCategoryIsLocked(to: guessViewPresenter.isPersonCategoryLocked())
                }
            }
        }
    }
    
    func presentBriefAlertThatUserUnlockedPersonGuessing() {
        // TODO: MAKE THE BRIEF ALERT DO HAPTIC SUCCESS
        BriefAlertView(title: "Congratulations!\nYou've unlocked People").present(duration: 4.0)
    }
}
