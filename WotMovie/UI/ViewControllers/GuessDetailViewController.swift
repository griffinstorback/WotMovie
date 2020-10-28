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
    
    private let guessDetailViewPresenter: GuessDetailPresenter
    private var state: GuessDetailViewState = .fullyHidden {
        didSet {
            print("didset \(state)")
            switch state {
            case .fullyHidden:
                addShowHintButton()
            case .hintShown:
                removeShowHintButton()
                showInfo()
            case .revealed:
                removeShowHintButton()
                showInfo()
                revealButton.isHidden = true
                addCloseButton()
                
                detailOverviewView.removePosterImageBlurEffectOverlay(animated: true)
                detailOverviewView.setTitle(guessDetailViewPresenter.getTitle())     //   // TODO *** animate this
            }
        }
    }
    
    private let scrollView: UIScrollView!
    private let contentStackView: UIStackView!
    
    // buttons which remain at top of screen
    private let closeButton: UIButton!
    private let revealButton: UIButton!
    
    // needs container becuase stackview.alignment == .fill
    private let showHintButtonContainer: UIView!
    private let showHintButton: UIButton!
    
    // stackview items
    private let detailOverviewView: DetailOverviewView!
    private let castCollectionView: HorizontalCollectionViewController!
    private let crewTableView: PeopleTableViewController!
    
    init(title: Title) {
        guessDetailViewPresenter = GuessDetailPresenter(networkManager: NetworkManager.shared, imageDownloadManager: ImageDownloadManager.shared, title: title)
        
        scrollView = UIScrollView()
        contentStackView = UIStackView()
        
        closeButton = UIButton()
        revealButton = UIButton()
        revealButton.layer.cornerRadius = 10
        
        showHintButtonContainer = UIView()
        showHintButton = UIButton()
        showHintButton.layer.cornerRadius = 10
        
        detailOverviewView = DetailOverviewView(frame: .zero)
        castCollectionView = HorizontalCollectionViewController(title: "Cast")
        crewTableView = PeopleTableViewController()
        
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
        state = .revealed
    }
    
    @objc func showHintButtonPressed() {
        state = .hintShown
    }
    
    private func setupViews() {
        scrollView.isUserInteractionEnabled = true
        
        contentStackView.axis = .vertical
        contentStackView.alignment = .fill
        contentStackView.spacing = 20
        contentStackView.layoutMargins = UIEdgeInsets(top: 60, left: 0, bottom: 0, right: 0)
        contentStackView.isLayoutMarginsRelativeArrangement = true
        
        // set poster image
        guessDetailViewPresenter.loadPosterImage(completion: detailOverviewView.setPosterImage)
        // set overview text
        detailOverviewView.setOverviewText(guessDetailViewPresenter.getOverview())
        
        castCollectionView.setDelegate(self)
        crewTableView.setDelegate(self)
        
        // if hasBeenGuessed
        //titleLabel.text = guessDetailViewPresenter.getTitle()
        // else
        
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.imageView?.contentMode = .scaleAspectFill
        closeButton.tintColor = .gray
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        
        revealButton.setTitle("Reveal", for: .normal)
        revealButton.backgroundColor = .systemBlue
        revealButton.titleLabel?.textColor = .white
        revealButton.addTarget(self, action: #selector(revealButtonPressed), for: .touchUpInside)
        
        showHintButton.setTitle("Show hint", for: .normal)
        showHintButton.backgroundColor = .systemBlue
        showHintButton.titleLabel?.textColor = .white
        showHintButton.addTarget(self, action: #selector(showHintButtonPressed), for: .touchUpInside)
    }
    
    private func layoutViews() {
        
        view.addSubview(scrollView)
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor)
        
        scrollView.addSubview(contentStackView)
        contentStackView.anchor(top: scrollView.topAnchor, leading: scrollView.leadingAnchor, bottom: scrollView.bottomAnchor, trailing: scrollView.trailingAnchor)
        contentStackView.anchorSize(height: nil, width: view.safeAreaLayoutGuide.widthAnchor)
        
        // add the stack view items
        contentStackView.addArrangedSubview(detailOverviewView)
        
        // add show hint button or show info
        switch state {
        case .fullyHidden:
            addShowHintButton()
            addRevealButton()
        case .hintShown:
            showInfo()
            addRevealButton()
        case .revealed:
            showInfo()
            addCloseButton()
        }
    }
    
    private func addCloseButton() {
        view.addSubview(closeButton)
        closeButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: nil, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, size: CGSize(width: 44, height: 44))
    }
    
    private func addRevealButton() {
        view.addSubview(revealButton)
        revealButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: nil, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 10), size: CGSize(width: 66, height: 44))
    }
    
    private func addShowHintButton() {
        contentStackView.addArrangedSubview(showHintButtonContainer)
        
        showHintButtonContainer.addSubview(showHintButton)
        showHintButton.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: CGSize(width: 160, height: 50))
        showHintButton.anchorToCenter(yAnchor: showHintButtonContainer.centerYAnchor, xAnchor: showHintButtonContainer.centerXAnchor)
        
        showHintButtonContainer.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: CGSize(width: 0, height: 60))
    }
    
    private func removeShowHintButton() {
        contentStackView.removeArrangedSubview(showHintButtonContainer)
        showHintButtonContainer.removeFromSuperview()
    }
    
    private func showInfo() {
        addChildToStackView(castCollectionView)
        addChildToStackView(crewTableView)
    }
    
    private func removeInfo() {
        removeChildFromStackView(castCollectionView)
        removeChildFromStackView(crewTableView)
    }
}

extension GuessDetailViewController: HorizontalCollectionViewDelegate {
    func getNumberOfItems() -> Int {
        return guessDetailViewPresenter.getCastCount()
    }
    
    func getNameForPersonAt(index: Int) -> String {
        return guessDetailViewPresenter.getCastMember(for: index)?.name ?? ""
    }
    
    func loadImageFor(index: Int, completion: @escaping (_ image: UIImage?) -> Void) {
        guessDetailViewPresenter.loadCastPersonImage(index: index, completion: completion)
        return
    }
}

extension GuessDetailViewController: PeopleTableViewDelegate {
    
    func getSectionsCount() -> Int {
        return guessDetailViewPresenter.getCrewTypesToDisplayCount()
    }
    
    func getCountForSection(section: Int) -> Int {
        return guessDetailViewPresenter.getCrewCountForType(section: section)
    }

    func getSectionTitle(for index: Int) -> String? {
        return guessDetailViewPresenter.getCrewTypeToDisplay(for: index)
    }
    
    func getName(for index: Int, section: Int) -> String? {
        return guessDetailViewPresenter.getCrewMember(for: index, section: section)?.name
    }
    
    func loadImage(for index: Int, section: Int, completion: @escaping (UIImage?) -> Void) {
        guessDetailViewPresenter.loadCrewPersonImage(index: index, section: section, completion: completion)
    }
}

extension GuessDetailViewController: GuessDetailViewDelegate {
    func displayErrorLoadingDetail() {
        print("error loading detail view")
    }
    
    func reloadCreditsData() {
        castCollectionView.reloadData()
        crewTableView.reloadData()
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
