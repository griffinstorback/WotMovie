//
//  PersonDetailViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-11-06.
//

import UIKit

class PersonDetailViewController: GuessDetailViewController {
    
    let personDetailViewPresenter: PersonDetailPresenterProtocol
    
    override var state: GuessDetailViewState {
        didSet {
            switch state {
            case .fullyHidden:
                addShowHintButton()
                
            case .hintShown:
                removeShowHintButton()
                addInfo()
                
            case .revealed:
                removeShowHintButton()
                addInfo()
                
                // scroll to top of view to show title being revealed
                scrollToTop()
                
                personOverviewView.setName(personDetailViewPresenter.getTitle())     //   // TODO *** animate this
                //personOverviewView.setOverviewText(personDetailViewPresenter.getOverview())
            }
        }
    }
    
    // stackview items
    private let personOverviewView: PersonOverviewView!
    private let knownForCollectionView: HorizontalCollectionViewController!

    private let actorInCollectionView: HorizontalCollectionViewController!
    private let directedCollectionView: HorizontalCollectionViewController!
    private let producedCollectionView: HorizontalCollectionViewController!
    private let wroteCollectionView: HorizontalCollectionViewController!
    
    init(item: Entity, startHidden: Bool, presenter: PersonDetailPresenterProtocol? = nil) {
        // use passed in presenter if provided (used in tests)
        personDetailViewPresenter = presenter ?? PersonDetailPresenter(item: item)
        
        personOverviewView = PersonOverviewView(frame: .zero)
        knownForCollectionView = HorizontalCollectionViewController(title: "Known for")
        knownForCollectionView.restorationIdentifier = "Known for"
        
        actorInCollectionView = HorizontalCollectionViewController(title: "Actor")
        actorInCollectionView.restorationIdentifier = "Actor"
        directedCollectionView = HorizontalCollectionViewController(title: "Director")
        directedCollectionView.restorationIdentifier = "Director"
        producedCollectionView = HorizontalCollectionViewController(title: "Producer")
        producedCollectionView.restorationIdentifier = "Producer"
        wroteCollectionView = HorizontalCollectionViewController(title: "Writer")
        wroteCollectionView.restorationIdentifier = "Writer"
        
        super.init(item: item, posterImageView: personOverviewView.posterImageView, startHidden: startHidden, presenter: personDetailViewPresenter)
        
        personDetailViewPresenter.setViewDelegate(detailViewDelegate: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        personDetailViewPresenter.loadCredits()
        
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        // set person overview view values
        personDetailViewPresenter.loadPosterImage(completion: personOverviewView.setPosterImage)
        //personOverviewView.setOverviewText(personDetailViewPresenter.getOverview())
        
        knownForCollectionView.setDelegate(self)
        actorInCollectionView.setDelegate(self)
        directedCollectionView.setDelegate(self)
        producedCollectionView.setDelegate(self)
        wroteCollectionView.setDelegate(self)
    }
    
    private func layoutViews() {
        addViewToStackView(personOverviewView)
        
        switch state {
        case .fullyHidden:
            addShowHintButton()
        case .hintShown:
            addInfo()
        case .revealed:
            addInfo()
            personOverviewView.setName(personDetailViewPresenter.getTitle())
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        personOverviewView.removePosterImageBlurEffectOverlay(animated: true)
    }
    
    private func addInfo() {
        addChildToStackView(knownForCollectionView)
        addChildToStackView(actorInCollectionView)
        addChildToStackView(directedCollectionView)
        addChildToStackView(producedCollectionView)
        addChildToStackView(wroteCollectionView)
    }
}

extension PersonDetailViewController: HorizontalCollectionViewDelegate {
    func getNumberOfItems(_ horizontalCollectionViewController: HorizontalCollectionViewController) -> Int {
        switch horizontalCollectionViewController.restorationIdentifier {
        case "Known for":
            return personDetailViewPresenter.getKnownForCount()
        case "Actor":
            return personDetailViewPresenter.getActorInCount()
        case "Director":
            return personDetailViewPresenter.getCountForJob(section: 0)
        case "Producer":
            return personDetailViewPresenter.getCountForJob(section: 1)
        case "Writer":
            return personDetailViewPresenter.getCountForJob(section: 2)
        default:
            return 0
        }
    }
    
    func getItemFor(_ horizontalCollectionViewController: HorizontalCollectionViewController, index: Int) -> Entity? {
        switch horizontalCollectionViewController.restorationIdentifier {
        case "Known for":
            return personDetailViewPresenter.getKnownForTitle(for: index)
        case "Actor":
            return personDetailViewPresenter.getActorInTitle(for: index)
        case "Director":
            return personDetailViewPresenter.getJobForTitle(for: index, section: 0)
        case "Producer":
            return personDetailViewPresenter.getJobForTitle(for: index, section: 1)
        case "Writer":
            return personDetailViewPresenter.getJobForTitle(for: index, section: 2)
        default:
            return nil
        }
    }
    
    func loadImageFor(_ horizontalCollectionViewController: HorizontalCollectionViewController, index: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void) {
        switch horizontalCollectionViewController.restorationIdentifier {
        case "Known for":
            personDetailViewPresenter.loadKnownForTitleImage(index: index, completion: completion)
        case "Actor":
            personDetailViewPresenter.loadActorInTitleImage(index: index, completion: completion)
        case "Director":
            personDetailViewPresenter.loadJobForTitleImage(index: index, section: 0, completion: completion)
        case "Producer":
            personDetailViewPresenter.loadJobForTitleImage(index: index, section: 1, completion: completion)
        case "Writer":
            personDetailViewPresenter.loadJobForTitleImage(index: index, section: 2, completion: completion)
        default:
            return
        }
    }
}

extension PersonDetailViewController: GuessDetailViewDelegate {
    func displayError() {
        print("error loading detail view")
    }
    
    func reloadData() {
        knownForCollectionView.reloadData()
        actorInCollectionView.reloadData()
        directedCollectionView.reloadData()
        producedCollectionView.reloadData()
        wroteCollectionView.reloadData()
    }
}
