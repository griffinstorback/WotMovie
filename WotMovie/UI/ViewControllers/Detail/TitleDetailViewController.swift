//
//  TitleDetailViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-11-06.
//

import UIKit

class TitleDetailViewController: GuessDetailViewController {
    
    let titleDetailViewPresenter: TitleDetailPresenterProtocol

    override var state: GuessDetailViewState {
        didSet {
            // don't re-run didSet operations if they've already been run
            guard state != oldValue else {
                 return
            }
            
            switch state {
            case .fullyHidden:
                addShowHintButton()
                
            case .hintShown:
                removeShowHintButton()
                addInfo()
                
            case .revealed, .revealedWithNoNextButton:
                removeShowHintButton()
                addInfo()
                
                // scroll to top of view to show title being revealed
                scrollToTop()
                
                detailOverviewView.removePosterImageBlurEffectOverlay(animated: true)
                detailOverviewView.setTitle(titleDetailViewPresenter.getTitle())     //   // TODO *** animate this
                detailOverviewView.setOverviewText(titleDetailViewPresenter.getOverview()) // uncensor title name from overview
            
                // if item was correctly guessed, show check at top left
                if titleDetailViewPresenter.item.correctlyGuessed {
                    addCheckMarkIcon(animated: true)
                }
            }
        }
    }
    
    // stackview items
    private let detailOverviewView: DetailOverviewView!
    private let castCollectionView: HorizontalCollectionViewController!
    private let crewTableView: EntityTableViewController!
    
    init(item: Entity, startHidden: Bool, fromGuessGrid: Bool, presenter: TitleDetailPresenterProtocol? = nil) {
        // use passed in presenter if provided (used in tests)
        titleDetailViewPresenter = presenter ?? TitleDetailPresenter(item: item)
        
        detailOverviewView = DetailOverviewView(frame: .zero, startHidden: startHidden)
        castCollectionView = HorizontalCollectionViewController(title: "Cast")
        crewTableView = EntityTableViewController()
        
        super.init(item: item, posterImageView: detailOverviewView.posterImageView, startHidden: startHidden, fromGuessGrid: false, presenter: titleDetailViewPresenter)
        
        titleDetailViewPresenter.setViewDelegate(detailViewDelegate: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleDetailViewPresenter.loadCredits()
        
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        // set detailOverviewView values
        titleDetailViewPresenter.loadPosterImage(completion: detailOverviewView.setPosterImage)
        titleDetailViewPresenter.getGenres(completion: detailOverviewView.setGenreList)
        detailOverviewView.setOverviewText(titleDetailViewPresenter.getOverviewCensored())
        detailOverviewView.setReleaseDate(dateString: titleDetailViewPresenter.getReleaseDate())
        
        castCollectionView.setDelegate(self)
        crewTableView.setDelegate(self)
    }
    
    private func layoutViews() {
        addViewToStackView(detailOverviewView)
        
        switch state {
        case .fullyHidden:
            addShowHintButton()
        case .hintShown:
            addInfo()
        case .revealed, .revealedWithNoNextButton:
            addInfo()
            detailOverviewView.removePosterImageBlurEffectOverlay(animated: false)
            detailOverviewView.setTitle(titleDetailViewPresenter.getTitle())
            
            // if item was correctly guessed, show check at top left
            addCheckMarkIcon(animated: false)
        }
    }
    
    private func addInfo() {
        addChildToStackView(castCollectionView)
        addChildToStackView(crewTableView)
    }
}

// collectionView for cast of this title
extension TitleDetailViewController: HorizontalCollectionViewDelegate {
    func getNumberOfItems(_ horizontalCollectionViewController: HorizontalCollectionViewController) -> Int {
        return titleDetailViewPresenter.getCastCount()
    }
    
    func getItemFor(_ horizontalCollectionViewController: HorizontalCollectionViewController, index: Int) -> Entity? {
        return titleDetailViewPresenter.getCastMember(for: index)
    }
    
    func getSubtitleFor(_ horizontalCollectionViewController: HorizontalCollectionViewController, index: Int) -> String? {
        return titleDetailViewPresenter.getCharacterForCastMember(for: index)
    }
    
    func loadImageFor(_ horizontalCollectionViewController: HorizontalCollectionViewController, index: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void) {
        titleDetailViewPresenter.loadCastPersonImage(index: index, completion: completion)
        return
    }
}

extension TitleDetailViewController: EntityTableViewDelegate {
    
    func getSectionsCount() -> Int {
        return titleDetailViewPresenter.getCrewTypesToDisplayCount()
    }
    
    func getCountForSection(section: Int) -> Int {
        return titleDetailViewPresenter.getCrewCountForType(section: section)
    }

    func getSectionTitle(for index: Int) -> String? {
        return titleDetailViewPresenter.getCrewTypeToDisplay(for: index)
    }
    
    func getItem(for index: Int, section: Int) -> Entity? {
        return titleDetailViewPresenter.getCrewMember(for: index, section: section)
    }
    
    func loadImage(for index: Int, section: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void) {
        titleDetailViewPresenter.loadCrewPersonImage(index: index, section: section, completion: completion)
    }
}

extension TitleDetailViewController: GuessDetailViewDelegate {
    func displayError() {
        print("error loading detail view")
    }
    
    func reloadData() {
        castCollectionView.reloadData()
        crewTableView.reloadData()
        
        if guessDetailViewPresenter.isAnswerRevealed() || guessDetailViewPresenter.isAnswerCorrectlyGuessed() {
            print("** guess detail view delegate: setting state to .revealed")
            state = .revealed
            return
        }
        if guessDetailViewPresenter.isHintShown() {
            print("** guess detail view delegate: setting state to .hintShown")
            state = .hintShown
        }
    }
}
