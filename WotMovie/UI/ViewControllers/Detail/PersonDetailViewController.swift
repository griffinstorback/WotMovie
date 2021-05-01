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
                
            case .revealed, .revealedWithNoNextButton, .correct, .correctWithNoNextButton:
                removeShowHintButton()
                addInfo()
                
                // scroll to top of view to show title being revealed
                scrollToTop()
                
                personOverviewView.setName(personDetailViewPresenter.getName())     //   // TODO *** animate this
                personOverviewView.setOverviewText(personDetailViewPresenter.getOverview())
                personOverviewView.setBirthday(personDetailViewPresenter.getBirthdayText())
                personOverviewView.setDeathday(personDetailViewPresenter.getDeathdayText())
            
                // depending if correct or not, reflect in state of poster image view
                if state == .revealed || state == .revealedWithNoNextButton {
                    personOverviewView.setPosterImageState(.revealed, animated: true)
                } else if state == .correct || state == .correctWithNoNextButton {
                    personOverviewView.setPosterImageState(.correctlyGuessedWithoutCheckmark, animated: true)
                }
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
    
    init(item: Entity, state: GuessDetailViewState, presenter: PersonDetailPresenterProtocol? = nil) {
        // use passed in presenter if provided (used in tests)
        personDetailViewPresenter = presenter ?? PersonDetailPresenter(item: item)
        
        personOverviewView = PersonOverviewView(frame: .zero, guessState: state)
        
        // no point in hiding names in horizontal collection view items, even when item is still hidden - the movie title is usually visible in image anyways
        knownForCollectionView = HorizontalCollectionViewController(title: "Known for", state: .namesShownButItemIsStillHidden)
        knownForCollectionView.restorationIdentifier = "Known for"
        
        actorInCollectionView = HorizontalCollectionViewController(title: "Actor", state: .namesShownButItemIsStillHidden)
        actorInCollectionView.restorationIdentifier = "Actor"
        directedCollectionView = HorizontalCollectionViewController(title: "Director", state: .namesShownButItemIsStillHidden)
        directedCollectionView.restorationIdentifier = "Director"
        wroteCollectionView = HorizontalCollectionViewController(title: "Writer", state: .namesShownButItemIsStillHidden)
        wroteCollectionView.restorationIdentifier = "Writer"
        producedCollectionView = HorizontalCollectionViewController(title: "Producer", state: .namesShownButItemIsStillHidden)
        producedCollectionView.restorationIdentifier = "Producer"
        
        //super.init(item: item, posterImageView: personOverviewView.posterImageView, startHidden: startHidden, fromGuessGrid: false, presenter: personDetailViewPresenter)
        super.init(item: item, posterImageView: personOverviewView.posterImageView, state: state, presenter: personDetailViewPresenter)
        
        personDetailViewPresenter.setViewDelegate(detailViewDelegate: self)
        personDetailViewPresenter.loadCredits()
        
        setupViews()
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // set person overview view values
        personDetailViewPresenter.loadPosterImage(completion: personOverviewView.setPosterImage)
        //personOverviewView.setOverviewText(personDetailViewPresenter.getOverview())
        
        // subscribe to posterimageviews taps
        personOverviewView.posterImageView.tapDelegate = self
        
        // set self as delegate for the loading indicator/error view, to receive events like 'retry button pressed'
        setLoadingIndicatorOrErrorViewDelegate(self)
        
        knownForCollectionView.setDelegate(self)
        actorInCollectionView.setDelegate(self)
        directedCollectionView.setDelegate(self)
        producedCollectionView.setDelegate(self)
        wroteCollectionView.setDelegate(self)
    }
    
    private func layoutViews() {
        addViewToStackView(personOverviewView)
        
        
        switch self.state {
        case .fullyHidden:
            addShowHintButton()
        case .hintShown:
            addLoadingIndicatorOrErrorView()
        case .revealed, .revealedWithNoNextButton, .correct, .correctWithNoNextButton:
            addLoadingIndicatorOrErrorView()
            
            personOverviewView.setName(personDetailViewPresenter.getName())
            personOverviewView.setOverviewText(personDetailViewPresenter.getOverview())
            
            // if item was correctly guessed, show check at top left
            if state == .correct || state == .correctWithNoNextButton {
                addCheckMarkIcon(animated: false)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Set correct poster image state, based on guess state
        switch state {
        case .correct, .correctWithNoNextButton:
            personOverviewView.setPosterImageState(.correctlyGuessedWithoutCheckmark, animated: true)
        case .revealed, .revealedWithNoNextButton:
            personOverviewView.setPosterImageState(.revealed, animated: true)
        case .fullyHidden, .hintShown:
            personOverviewView.setPosterImageState(.revealWhileDetailOpenButHideOnGrid, animated: true)
        }
        
        if personDetailViewPresenter.creditsHaveLoaded() {
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
        if personDetailViewPresenter.creditsHaveLoaded() {
            removeLoadingIndicatorOrErrorView()
        }
        removeShowHintButton()
        
        // if collectionview items haven't been revealed (allowing them to be opened in modals), reveal them.
        if state != .hintShown {
            if knownForCollectionView.state == .namesHidden || knownForCollectionView.state == .namesShownButItemIsStillHidden { knownForCollectionView.state = .itemIsRevealedOrGuessed }
            if actorInCollectionView.state == .namesHidden || actorInCollectionView.state == .namesShownButItemIsStillHidden { actorInCollectionView.state = .itemIsRevealedOrGuessed }
            if directedCollectionView.state == .namesHidden || directedCollectionView.state == .namesShownButItemIsStillHidden { directedCollectionView.state = .itemIsRevealedOrGuessed }
            if wroteCollectionView.state == .namesHidden || wroteCollectionView.state == .namesShownButItemIsStillHidden { wroteCollectionView.state = .itemIsRevealedOrGuessed }
            if producedCollectionView.state == .namesHidden || producedCollectionView.state == .namesShownButItemIsStillHidden { producedCollectionView.state = .itemIsRevealedOrGuessed }
        }
        
        // if horizontal collectionview items haven't been revealed, reveal them.
        revealHorizontalCollectionViewCellsIfStateIsHidden(knownForCollectionView)
        revealHorizontalCollectionViewCellsIfStateIsHidden(actorInCollectionView)
        revealHorizontalCollectionViewCellsIfStateIsHidden(directedCollectionView)
        revealHorizontalCollectionViewCellsIfStateIsHidden(wroteCollectionView)
        revealHorizontalCollectionViewCellsIfStateIsHidden(producedCollectionView)
        
        // don't add/reload info collection views if they've already been added (otherwise will cause views to flash, annoyingly)
        guard !infoHasBeenAdded else { return }
        
        addChildToStackView(knownForCollectionView)
        
        // first section after 'knownFor' should be the department the Person is known for (knownForDepartment)
        if personDetailViewPresenter.personIsKnownForDirecting() {
            addChildToStackView(directedCollectionView)
            addChildToStackView(wroteCollectionView)
            addChildToStackView(actorInCollectionView)
            addChildToStackView(producedCollectionView)
            return
        } else if personDetailViewPresenter.personIsKnownForProducing() {
            addChildToStackView(producedCollectionView)
            addChildToStackView(directedCollectionView)
            addChildToStackView(wroteCollectionView)
            addChildToStackView(actorInCollectionView)
            return
        } else if personDetailViewPresenter.personIsKnownForWriting() {
            addChildToStackView(wroteCollectionView)
            addChildToStackView(directedCollectionView)
            addChildToStackView(actorInCollectionView)
            addChildToStackView(producedCollectionView)
            return
        }
        
        // if person is known for acting, OR if the knownForDepartment is null or there is some other error, show acting credits first.
        addChildToStackView(actorInCollectionView)
        addChildToStackView(directedCollectionView)
        addChildToStackView(wroteCollectionView)
        addChildToStackView(producedCollectionView)
        
        // refresh and reload all the collection views. This fixes bug where collection view cells are sometimes wrong size/no label after being added
        reloadInfoCollectionViews()
        
        infoHasBeenAdded = true
    }
    
    // makes addInfo() more readable, saves some lines
    func revealHorizontalCollectionViewCellsIfStateIsHidden(_ horizontalCollectionView: HorizontalCollectionViewController) {
        if horizontalCollectionView.state == .namesHidden && state != .hintShown {
            horizontalCollectionView.state = .itemIsRevealedOrGuessed
        }
    }
    
    // this method is called multiple times throughout the layout process, because the sizing of the collection views within the stack view can be buggy
    func reloadInfoCollectionViews() {
        knownForCollectionView.reloadData()
        actorInCollectionView.reloadData()
        directedCollectionView.reloadData()
        wroteCollectionView.reloadData()
        producedCollectionView.reloadData()
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
        case "Writer":
            return personDetailViewPresenter.getCountForJob(section: 1)
        case "Producer":
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
        case "Writer":
            return personDetailViewPresenter.getJobForTitle(for: index, section: 1)
        case "Producer":
            return personDetailViewPresenter.getJobForTitle(for: index, section: 2)
        default:
            return nil
        }
    }
    
    func getSubtitleFor(_ horizontalCollectionViewController: HorizontalCollectionViewController, index: Int) -> String? {
        switch horizontalCollectionViewController.restorationIdentifier {
        case "Actor":
            return personDetailViewPresenter.getActorInSubtitle(for: index)
        case "Known for", "Director", "Producer", "Writer":
            return nil
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
        case "Writer":
            personDetailViewPresenter.loadJobForTitleImage(index: index, section: 1, completion: completion)
        case "Producer":
            personDetailViewPresenter.loadJobForTitleImage(index: index, section: 2, completion: completion)
        default:
            return
        }
    }
    
    func cancelLoadImageRequestFor(imagePath: String) {
        personDetailViewPresenter.cancelLoadImageRequestFor(imagePath: imagePath)
    }
}

extension PersonDetailViewController: GuessDetailViewDelegate {
    func displayErrorLoadingCredits() {
        displayErrorInLoadingIndicatorOrErrorView()
    }
    
    func reloadData() {
        if personDetailViewPresenter.creditsHaveLoaded() {
            
            // TODO: Move setOverviewText out here too - then add little bit of state to PersonOverviewView, and deal with hiding there.
            personOverviewView.setBirthday(personDetailViewPresenter.getBirthdayText())
            personOverviewView.setDeathday(personDetailViewPresenter.getDeathdayText())
            
            // only show overview when fully revealed - don't show as hint
            if state != .fullyHidden && state != .hintShown {
                personOverviewView.setOverviewText(personDetailViewPresenter.getOverview())
            }
            
            // add info if hint hasn't been shown and still guessing - also don't call addinfo more than once.
            if state != .fullyHidden && !infoHasBeenAdded {
                addInfo()
            }
        }
        
        knownForCollectionView.reloadData()
        actorInCollectionView.reloadData()
        directedCollectionView.reloadData()
        wroteCollectionView.reloadData()
        producedCollectionView.reloadData()
        updateItemOnEnterGuessView() // this is defined in parent class GuessDetailVC
        view.layoutIfNeeded()
                
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

// when poster image tapped, present full screen image view controller.
extension PersonDetailViewController: PosterImageViewTapDelegate {
    func tapped() {
        let fullScreenImageViewController = FullScreenImageViewController(item: personDetailViewPresenter.item)
        fullScreenImageViewController.modalPresentationStyle = .overFullScreen
        fullScreenImageViewController.modalTransitionStyle = .crossDissolve
        present(fullScreenImageViewController, animated: true)
    }
}

extension PersonDetailViewController: LoadingIndicatorOrErrorViewDelegate {
    func retryButtonPressed() {
        personDetailViewPresenter.loadCredits()
        
        personDetailViewPresenter.loadPosterImage(completion: personOverviewView.setPosterImage)
    }
}
