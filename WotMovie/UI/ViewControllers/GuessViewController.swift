//
//  GuessViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-13.
//

import UIKit

protocol GuessViewDelegate: NSObjectProtocol {
    func reloadData()
}

class GuessViewController: UIViewController {
    
    private let guessViewPresenter: GuessPresenterProtocol
    
    private let scrollView: UIScrollView
    
    private let guessCategoryStackView: UIStackView
    private var guessCategoryViews: [GuessCategoryView]
    
    init(presenter: GuessPresenterProtocol? = nil) {
        // use provider if provided, otherwise use default
        guessViewPresenter = presenter ?? GuessPresenter()
        scrollView = UIScrollView()
        
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
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        guessViewPresenter.updateGuessedCounts()
    }
    
    func setupViews() {
        guessViewPresenter.setViewDelegate(guessViewDelegate: self)
        view.backgroundColor = .systemBackground
        
        // navigation view controller
        navigationItem.title = "WotMovie"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        scrollView.isUserInteractionEnabled = true
        scrollView.delaysContentTouches = false
        
        guessCategoryStackView.axis = .vertical
        guessCategoryStackView.alignment = .fill
        guessCategoryStackView.spacing = 20
        guessCategoryStackView.layoutMargins = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
        guessCategoryStackView.isLayoutMarginsRelativeArrangement = true
        
        // add categories to guessCategoryViews list
        var categoryView: GuessCategoryView
        if let movieCategory = guessViewPresenter.getCategoryFor(type:.movie) {
            categoryView = GuessCategoryView(category: movieCategory)
            categoryView.setDelegate(self)
            guessCategoryViews.append(categoryView)
        }
        if let personCategory = guessViewPresenter.getCategoryFor(type: .person) {
            categoryView = GuessCategoryView(category: personCategory)
            categoryView.setDelegate(self)
            guessCategoryViews.append(categoryView)
        }
        if let tvShowCategory = guessViewPresenter.getCategoryFor(type:.tvShow) {
            categoryView = GuessCategoryView(category: tvShowCategory)
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
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor)
        
        scrollView.addSubview(guessCategoryStackView)
        guessCategoryStackView.anchor(top: scrollView.topAnchor, leading: scrollView.leadingAnchor, bottom: scrollView.bottomAnchor, trailing: scrollView.trailingAnchor)
        guessCategoryStackView.anchorSize(height: nil, width: scrollView.widthAnchor)
        
        for categoryView in guessCategoryViews {
            guessCategoryStackView.addArrangedSubview(categoryView)
        }
    }
}

extension GuessViewController: GuessCategoryViewDelegate {
    func categoryWasSelected(_ type: GuessCategory) {        
        let guessGridViewController = GuessGridViewController(for: type)
        navigationController?.pushViewController(guessGridViewController, animated: true)
    }
}

extension GuessViewController: GuessViewDelegate {
    func reloadData() {
        // reload guessed counts for each category
        for categoryView in guessCategoryViews {
            if let category = guessViewPresenter.getCategoryFor(type: categoryView.category.type) {
                categoryView.category = category
            }
        }
    }
}
