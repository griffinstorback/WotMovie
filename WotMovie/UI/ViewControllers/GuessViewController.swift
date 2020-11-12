//
//  GuessViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-13.
//

import UIKit

class GuessViewController: UIViewController {
    
    private let guessViewPresenter = GuessPresenter(networkManager: NetworkManager.shared)
    
    private let scrollView: UIScrollView
    
    private let guessCategoryStackView: UIStackView
    private var guessCategoryViews: [GuessCategoryView]
    
    init() {
        scrollView = UIScrollView()
        
        guessCategoryStackView = UIStackView()
        guessCategoryViews = []
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guessViewPresenter.setViewDelegate(guessViewDelegate: self)
        
        view.backgroundColor = .white
        
        setupViews()
        layoutViews()
    }
    
    func setupViews() {
        // navigation view controller
        navigationItem.title = "WotMovie"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        scrollView.isUserInteractionEnabled = true
        scrollView.delaysContentTouches = false
        
        guessCategoryStackView.axis = .vertical
        guessCategoryStackView.alignment = .fill
        guessCategoryStackView.spacing = 20
        guessCategoryStackView.layoutMargins = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
        guessCategoryStackView.isLayoutMarginsRelativeArrangement = true
        
        // add categories to guessCategoryViews list
        for category in guessViewPresenter.categories {
            let categoryView = GuessCategoryView(category: category)
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
        print("SELECTED TYPE \(type)")
        
        let guessGridViewController = GuessGridViewController(for: type)
        navigationController?.pushViewController(guessGridViewController, animated: true)
    }
}

extension GuessViewController: GuessViewDelegate {
    func presentGuessGridView(for genre: Genre) {
        //let guessGridViewController = GuessGridViewController(for: genre)
        
        //navigationController?.pushViewController(guessGridViewController, animated: true)
    }
    
    func displayErrorLoadingGenres() {
        print("displayErrorLoadingGenres")
    }
    
    func reloadData() {
        //tableView.reloadData()
    }
}
