//
//  TitleDetailViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-11-06.
//

import UIKit

class TitleDetailViewController: GuessDetailViewController {

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
                
                detailOverviewView.removePosterImageBlurEffectOverlay(animated: true)
                detailOverviewView.setTitle(guessDetailViewPresenter.getTitle())     //   // TODO *** animate this
                detailOverviewView.setOverviewText(guessDetailViewPresenter.getOverview()) // uncensor title name from overview
            }
        }
    }
    
    // stackview items
    private let detailOverviewView: DetailOverviewView!
    private let castCollectionView: HorizontalCollectionViewController!
    private let crewTableView: PeopleTableViewController!
    
    override init(item: Entity) {
        detailOverviewView = DetailOverviewView(frame: .zero)
        castCollectionView = HorizontalCollectionViewController(title: "Cast")
        crewTableView = PeopleTableViewController()
        
        super.init(item: item)
        
        guessDetailViewPresenter.setViewDelegate(guessDetailViewDelegate: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guessDetailViewPresenter.loadCredits()
        
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        // set detailOverviewView values
        guessDetailViewPresenter.loadPosterImage(completion: detailOverviewView.setPosterImage)
        guessDetailViewPresenter.getGenres(completion: detailOverviewView.setGenreList)
        detailOverviewView.setOverviewText(guessDetailViewPresenter.getOverviewCensored())
        detailOverviewView.setReleaseDate(dateString: guessDetailViewPresenter.getReleaseDate())
        
        castCollectionView.setDelegate(self)
        crewTableView.setDelegate(self)
    }
    
    private func layoutViews() {
        addViewToStackView(detailOverviewView)
        
        switch state {
        case .fullyHidden:
            addShowHintButton()
        case .hintShown, .revealed:
            addInfo()
        }
    }
    
    private func addInfo() {
        addChildToStackView(castCollectionView)
        addChildToStackView(crewTableView)
    }
}

extension TitleDetailViewController: HorizontalCollectionViewDelegate {
    func getNumberOfItems() -> Int {
        return guessDetailViewPresenter.getCastCount()
    }
    
    func getTitleFor(index: Int) -> String {
        return guessDetailViewPresenter.getCastMember(for: index)?.name ?? ""
    }
    
    func loadImageFor(index: Int, completion: @escaping (_ image: UIImage?) -> Void) {
        guessDetailViewPresenter.loadCastPersonImage(index: index, completion: completion)
        return
    }
}

extension TitleDetailViewController: PeopleTableViewDelegate {
    
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

extension TitleDetailViewController: GuessDetailViewDelegate {
    func displayError() {
        print("error loading detail view")
    }
    
    func reloadData() {
        castCollectionView.reloadData()
        crewTableView.reloadData()
    }
}
