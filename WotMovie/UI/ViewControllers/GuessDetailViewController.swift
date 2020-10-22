//
//  GuessDetailViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-13.
//

import UIKit

// TODO: Delete and rename GuessTitleDetailViewController
class GuessDetailViewController: UIViewController {
    
    private let guessDetailViewPresenter: GuessDetailPresenter
    
    private let scrollView: UIScrollView!
    private let contentStackView: UIStackView!
    
    // buttons which remain at top of screen
    private let closeButton: UIButton!
    private let revealButton: UIButton!
    
    // stackview items
    private var detailOverviewView: DetailOverviewView!
    private let peopleTableView: PeopleTableViewController!
    
    init(title: Title) {
        guessDetailViewPresenter = GuessDetailPresenter(networkManager: NetworkManager.shared, imageDownloadManager: ImageDownloadManager.shared, title: title)
        
        scrollView = UIScrollView()
        contentStackView = UIStackView()
        
        closeButton = UIButton()
        revealButton = UIButton()
        
        detailOverviewView = DetailOverviewView(frame: .zero)
        peopleTableView = PeopleTableViewController(guessDetailPresenter: guessDetailViewPresenter)
        
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
        
        guessDetailViewPresenter.setViewDelegate(guessDetailViewDelegate: self)
        
        setupViews()
        layoutViews()
        
        guessDetailViewPresenter.loadCredits()
    }
    
    @objc func closeButtonPressed() {
        self.dismiss(animated: true)
    }
    
    @objc func revealButtonPressed() {
        detailOverviewView.removePosterImageBlurEffectOverlay(animated: true)
        detailOverviewView.setTitle(text: guessDetailViewPresenter.getTitle())
    }
    
    private func setupViews() {
        scrollView.isUserInteractionEnabled = true
        
        contentStackView.axis = .vertical
        contentStackView.spacing = 20
        contentStackView.layoutMargins = UIEdgeInsets(top: 50, left: 0, bottom: 200, right: 0)
        contentStackView.isLayoutMarginsRelativeArrangement = true
        
        // set poster image
        guessDetailViewPresenter.loadPosterImage(completion: detailOverviewView.setPosterImage)

        // set overview text
        detailOverviewView.setOverviewText(text: guessDetailViewPresenter.getOverview())
        
        // if hasBeenGuessed
        //titleLabel.text = guessDetailViewPresenter.getTitle()
        // else
        
        closeButton.setImage(UIImage(systemName: "x.circle.fill"), for: .normal)
        closeButton.tintColor = .gray
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        
        revealButton.setTitle("Reveal", for: .normal)
        revealButton.backgroundColor = .blue
        revealButton.titleLabel?.textColor = .white
        revealButton.addTarget(self, action: #selector(revealButtonPressed), for: .touchUpInside)
    }
    
    private func layoutViews() {
        
        view.addSubview(scrollView)
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor)
        
        scrollView.addSubview(contentStackView)
        contentStackView.anchor(top: scrollView.topAnchor, leading: scrollView.leadingAnchor, bottom: scrollView.bottomAnchor, trailing: scrollView.trailingAnchor)
        contentStackView.anchorSize(height: nil, width: view.safeAreaLayoutGuide.widthAnchor)
        
        // add the stack view items
        contentStackView.addArrangedSubview(detailOverviewView)
        addChildToStackView(peopleTableView)
        
        // add the top buttons (reveal, and close)
        view.addSubview(closeButton)
        closeButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: nil, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, size: CGSize(width: 44, height: 44))
        
        view.addSubview(revealButton)
        revealButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: nil, size: CGSize(width: 60, height: 44))
    }
}

extension GuessDetailViewController: GuessDetailViewDelegate {
    func displayErrorLoadingDetail() {
        print("error loading detail view")
    }
    
    func reloadCreditsData() {
        peopleTableView.reloadTableViewData()
    }
}

extension GuessDetailViewController {
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
