//
//  PersonDetailViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-11-06.
//

import UIKit

class PersonDetailViewController: GuessDetailViewController {
    
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
                
                personOverviewView.setName(guessDetailViewPresenter.getTitle())     //   // TODO *** animate this
                //personOverviewView.setOverviewText(guessDetailViewPresenter.getOverview())
            }
        }
    }
    
    // stackview items
    private let personOverviewView: PersonOverviewView!
    private let knownForCollectionView: HorizontalCollectionViewController!
    
    init(item: Entity) {
        personOverviewView = PersonOverviewView(frame: .zero)
        knownForCollectionView = HorizontalCollectionViewController(title: "Known for")
        
        super.init(item: item, posterImageView: personOverviewView.posterImageView)
        
        guessDetailViewPresenter.setViewDelegate(guessDetailViewDelegate: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        // set person overview view values
        guessDetailViewPresenter.loadPosterImage(completion: personOverviewView.setPosterImage)
        //personOverviewView.setOverviewText(guessDetailViewPresenter.getOverview())
        
        knownForCollectionView.setDelegate(self)
    }
    
    private func layoutViews() {
        addViewToStackView(personOverviewView)
        
        switch state {
        case .fullyHidden:
            addShowHintButton()
        case .hintShown, .revealed:
            addInfo()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        personOverviewView.removePosterImageBlurEffectOverlay(animated: true)
    }
    
    private func addInfo() {
        addChildToStackView(knownForCollectionView)
    }
}

extension PersonDetailViewController: HorizontalCollectionViewDelegate {
    func getNumberOfItems() -> Int {
        return guessDetailViewPresenter.getKnownForCount()
    }
    
    func getTitleFor(index: Int) -> String {
        return guessDetailViewPresenter.getKnownForTitle(for: index)?.name ?? ""
    }
    
    func getImagePathFor(index: Int) -> String? {
        return guessDetailViewPresenter.getKnownForTitle(for: index)?.posterPath
    }
    
    func loadImageFor(index: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void) {
        guessDetailViewPresenter.loadKnownForTitleImage(index: index, completion: completion)
        return
    }
}

extension PersonDetailViewController: GuessDetailViewDelegate {
    func displayError() {
        print("error loading detail view")
    }
    
    func reloadData() {
        knownForCollectionView.reloadData()
    }
}
