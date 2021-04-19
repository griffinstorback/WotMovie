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
                addLoadingIndicatorOrErrorView()
                addInfo()
                
            case .revealed, .revealedWithNoNextButton, .correct, .correctWithNoNextButton:
                removeShowHintButton()
                addInfo()
                
                // scroll to top of view to show title being revealed
                scrollToTop()
                
                detailOverviewView.setTitle(String(titleDetailViewPresenter.getID()) + ": " + titleDetailViewPresenter.getName())    //(UNCOMMENT THIS WHEN LOOKING FOR BAD DESCRIPTIONS - SHOWS THE ITEM ID FOR EASY REFERENCE)
                //detailOverviewView.setTitle(titleDetailViewPresenter.getName())     //   // TODO *** animate this
                detailOverviewView.setOverviewText(titleDetailViewPresenter.getOverview()) // uncensor title name from overview
                detailOverviewView.addRating(rating: titleDetailViewPresenter.getRating())
            
                // depending if correct or not, reflect in state of poster image view
                if state == .revealed || state == .revealedWithNoNextButton {
                    detailOverviewView.setPosterImageState(.revealed, animated: true)
                } else if state == .correct || state == .correctWithNoNextButton {
                    detailOverviewView.setPosterImageState(.correctlyGuessedWithoutCheckmark, animated: true)
                }
            }
        }
    }
    
    // stackview items
    private let detailOverviewView: DetailOverviewView
    private let castCollectionView: HorizontalCollectionViewController
    private let crewListViewController: CrewListViewController
    
    init(item: Entity, state: GuessDetailViewState, presenter: TitleDetailPresenterProtocol? = nil) {
        // use passed in presenter if provided (used in tests)
        titleDetailViewPresenter = presenter ?? TitleDetailPresenter(item: item)
        
        detailOverviewView = DetailOverviewView(frame: .zero, guessState: state, typeString: titleDetailViewPresenter.getTypeString())
        castCollectionView = HorizontalCollectionViewController(title: "Cast")
        crewListViewController = CrewListViewController()
        
        super.init(item: item, posterImageView: detailOverviewView.posterImageView, state: state, presenter: titleDetailViewPresenter)
        
        setupViews()
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        titleDetailViewPresenter.setViewDelegate(detailViewDelegate: self)
        titleDetailViewPresenter.loadCredits()
        
        // set detailOverviewView values
        titleDetailViewPresenter.loadPosterImage(completion: detailOverviewView.setPosterImage)
        titleDetailViewPresenter.getGenres(completion: detailOverviewView.setGenreList)
        detailOverviewView.setOverviewText(titleDetailViewPresenter.getOverviewCensored())
        detailOverviewView.setReleaseDate(dateString: titleDetailViewPresenter.getReleaseDate())
        
        // set self as delegate for the loading indicator/error view, to receive events like 'retry button pressed'
        setLoadingIndicatorOrErrorViewDelegate(self)
        
        castCollectionView.setDelegate(self)
        crewListViewController.setDelegate(self)
    }
    
    private func layoutViews() {
        addViewToStackView(detailOverviewView)
        
        switch state {
        case .fullyHidden:
            addShowHintButton()
        case .hintShown:
            addLoadingIndicatorOrErrorView()
        case .revealed, .revealedWithNoNextButton, .correct, .correctWithNoNextButton:
            addLoadingIndicatorOrErrorView()
            
            detailOverviewView.setTitle(String(titleDetailViewPresenter.getID()) + ": " + titleDetailViewPresenter.getName())    //(UNCOMMENT THIS WHEN LOOKING FOR BAD DESCRIPTIONS - SHOWS THE ITEM ID FOR EASY REFERENCE)
            //detailOverviewView.setTitle(titleDetailViewPresenter.getName())
            detailOverviewView.setOverviewText(titleDetailViewPresenter.getOverview()) // uncensor title name from overview
            
            // if item was correctly guessed, show check at top left
            if state == .correct || state == .correctWithNoNextButton {
                addCheckMarkIcon(animated: false)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // only add info if credits have loaded. otherwise, wait until presenter tells us to reload.
        if titleDetailViewPresenter.creditsHaveLoaded() {
            if state != .fullyHidden {
                addInfo()
            }
        }
    }
    
    var infoHasBeenAdded: Bool = false
    private func addInfo() {
        guard state != .fullyHidden else {
            print("** WARNING: in TitleDetail, addInfo() was attempted while state was still .fullyHidden.")
            return
        }
        
        // remove show hint button for sure - only remove loading indicator/error if credits have actually loaded.
        if titleDetailViewPresenter.creditsHaveLoaded() {
            removeLoadingIndicatorOrErrorView()
        }
        removeShowHintButton()
        
        // if collectionview items haven't been revealed (cast member names and their characters names), reveal them.
        if castCollectionView.state == .namesHidden && state != .hintShown {
            castCollectionView.state = .itemIsRevealedOrGuessed
        }
        
        // don't add/reload info views if they have already been added (otherwise will cause views to flash, annoyingly)
        guard !infoHasBeenAdded else { return }
        
        addChildToStackView(castCollectionView)
        addChildToStackView(crewListViewController)
        
        // reload cast collection view (fixes bug where cells sometimes wrong size, or missing labels after being added)
        castCollectionView.reloadData()
        
        infoHasBeenAdded = true
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

extension TitleDetailViewController: CrewListViewDelegate {
    func getCrewTypeStringToDisplay(for section: CrewTypeSection) -> String? {
        titleDetailViewPresenter.getCrewTypeStringToDisplay(for: section)
    }
    
    func getDirectors() -> [CrewMember] {
        titleDetailViewPresenter.getDirectors()
    }
    
    func getProducers() -> [CrewMember] {
        titleDetailViewPresenter.getProducers()
    }
    
    func getWriters() -> [CrewMember] {
        titleDetailViewPresenter.getWriters()
    }
    
    func loadImage(for index: Int, section: CrewTypeSection, completion: @escaping (UIImage?) -> Void) {
        titleDetailViewPresenter.loadCrewMemberImageFor(index: index, section: section, completion: completion)
    }
    
    func getCrewMember(for index: Int, section: CrewTypeSection) -> CrewMember? {
        return titleDetailViewPresenter.getCrewMember(for: index, section: section)
    }
}

extension TitleDetailViewController: GuessDetailViewDelegate {
    func displayErrorLoadingCredits() {
        print("** error loading detail view")
        displayErrorInLoadingIndicatorOrErrorView()
    }
    
    func reloadData() {
        if titleDetailViewPresenter.creditsHaveLoaded() {
            
            // we set content length (movie length in mins or tv show length in episodes) as soon as possible, even if item is hidden
            detailOverviewView.setContentLength(contentLengthString: titleDetailViewPresenter.getContentLength())
            
            // we don't want to show rating until it has been revealed/guessed
            if state != .fullyHidden && state != .hintShown {
                detailOverviewView.addRating(rating: titleDetailViewPresenter.getRating())
            }
            
            // don't add info yet as the item hasn't been revealed, even though it has been loaded. (this prevents flash of all imageviews which looks jarring)
            if state != .fullyHidden && !infoHasBeenAdded {
                addInfo()
            }
        }
        
        castCollectionView.reloadData()
        crewListViewController.reloadData()
        updateItemOnEnterGuessView() // this is defined in parent class GuessDetailVC
        
        print("*** RELOADING DATA in TitleDetailVC: item: \(guessDetailViewPresenter.item)")
        
        // don't set state if it was presented from a non guess grid (i.e. Watching or Favorites)
        if state == .revealedWithNoNextButton || state == .correctWithNoNextButton {
            return
        }
        
        // SETTING STATE
        if guessDetailViewPresenter.isAnswerCorrectlyGuessed() {
            state = .correct
            return
        }
        if guessDetailViewPresenter.isAnswerRevealed() {
            state = .revealed
            return
        }
        if guessDetailViewPresenter.isHintShown() {
            state = .hintShown
        }
    }
    
    // FOLLOWING TWO METHODS ARE PART OF GuessDetailViewDelegate, but are satisfied in super class GuessDetailViewController (so don't implement here)
    // func updateItemOnEnterGuessView()
    // func answerWasRevealedDuringAttemptToDismiss()
}

extension TitleDetailViewController: LoadingIndicatorOrErrorViewDelegate {
    func retryButtonPressed() {
        titleDetailViewPresenter.loadCredits()
    }
}
