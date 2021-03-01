//
//  GuessGridViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-13.
//

import UIKit

protocol GuessGridViewDelegate: NSObjectProtocol {
    func displayItems()
    func displayErrorLoadingItems()
    func reloadData()
    func numberOfItemsPerRow() -> Int
    
    func revealEntities(at indices: [Int])
    func revealCorrectlyGuessedEntities(at indices: [Int])
    
    func presentGuessDetailFor(index: Int)
}

class GuessGridViewController: DetailPresenterViewController {

    private let guessGridViewPresenter: GuessGridPresenterProtocol
    
    private let gridView: LoadMoreGridViewController
    //private var bottomBannerAdView: UIView
    
    init(for category: GuessCategory, presenter: GuessGridPresenterProtocol? = nil) {
        // use passed in presenter if provided (used in tests)
        guessGridViewPresenter = presenter ?? GuessGridPresenter(category: category.type)
        
        gridView = LoadMoreGridViewController(shouldDisplayLoadMoreFooter: true)
        //bottomBannerAdView = UIView()

        super.init(nibName: nil, bundle: nil)
        
        title = "\(category.shortTitle)"
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        //Appodeal.setBannerDelegate(self)
        //Appodeal.setSmartBannersEnabled(true)
        
        navigationItem.largeTitleDisplayMode = .never
        
        guessGridViewPresenter.setViewDelegate(self)
        
        // make button on right side of navigation bar be for genre selection
        let genreSelectionButton = UIBarButtonItem(title: guessGridViewPresenter.getGenreCurrentlyDisplaying().name, style: .plain, target: self, action: #selector(selectGenresToDisplay))
        navigationItem.rightBarButtonItem = genreSelectionButton
        
        gridView.delegate = self
        gridView.transitionPresenter = guessGridViewPresenter
    }
    
    private func layoutViews() {
        addChildViewController(gridView)
        gridView.view.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        
        //view.addSubview(bottomBannerAdView)
        //bottomBannerAdView.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, size: CGSize(width: 0, height: 50))
    }
    
    // right bar item pressed
    @objc func selectGenresToDisplay() {
        let categoryType = guessGridViewPresenter.category
        let genresDisplayedSelections: [(title: String, value: Int)]
        
        if categoryType == .movie {
            genresDisplayedSelections = guessGridViewPresenter.getMovieGenresAvailableToDisplay().map { (title: $0.name, value: $0.id) }
        } else if categoryType == .tvShow {
            genresDisplayedSelections = guessGridViewPresenter.getTVShowGenresAvailableToDisplay().map { (title: $0.name, value: $0.id) }
        } else {
            print("** WARNING: attempting to see genres list for type \(categoryType), which isn't possible.")
            return
        }
        
        let genresDisplayedSelectionController = UIAlertController.actionSheetWithItems(controllerTitle: "Display", items: genresDisplayedSelections) { selectedValue in
            // scroll to top, so that more pages than necessary aren't loaded
            self.scrollToTop()
            
            // set the type on presenter to filter items
            self.guessGridViewPresenter.setGenreToDisplay(genreID: selectedValue)
            
            // set the button string to update what type we are now seeing
            self.navigationItem.rightBarButtonItem?.title = self.guessGridViewPresenter.getGenreCurrentlyDisplaying().name
        }
        
        genresDisplayedSelectionController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(genresDisplayedSelectionController, animated: true)
    }
    
    func scrollToTop() {
        gridView.collectionView.setContentOffset(.zero, animated: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // load first page of movies/tv shows
        guessGridViewPresenter.loadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // add the banner view
        /*if let banner = Appodeal.banner() {
            
            bottomBannerAdView = banner
            view.addSubview(bottomBannerAdView)
            bottomBannerAdView.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, size: CGSize(width: 0, height: 50))
        } else {
            print("**** NO BANNER returned from Appodeal.banner()")
        }*/
    }
}

extension GuessGridViewController: GuessGridViewDelegate {
    func displayItems() {
        print("displayitems")
    }
    
    func displayErrorLoadingItems() {
        print("displayErrorLoadingitems")
    }
    
    func reloadData() {
        gridView.reloadData()
    }
    
    func numberOfItemsPerRow() -> Int {
        return gridView.numberOfCellsPerRow()
    }
    
    func revealEntities(at indices: [Int]) {
        gridView.revealEntities(at: indices)
    }
    
    func revealCorrectlyGuessedEntities(at indices: [Int]) {
        gridView.revealCorrectlyGuessedEntities(at: indices)
    }
    
    func presentGuessDetailFor(index: Int) {
        // TODO: FIND A WAY TO __SAFELY__ SELECT THE ITEM AT THE NEXT INDEX. (is it currently safe?)
        let indexPath = IndexPath(item: index, section: 0)
        
        DispatchQueue.main.async {
            self.gridView.selectCellAt(indexPath: indexPath)
        }
    }
}

extension GuessGridViewController: LoadMoreGridViewDelegate {
    func viewForHeader(_ loadMoreGridViewController: LoadMoreGridViewController, indexPath: IndexPath) -> UICollectionReusableView? {
        return nil
    }
    
    func sizeForHeader(_ loadMoreGridViewController: LoadMoreGridViewController) -> CGSize {
        return .zero
    }
    
    func willDisplayHeader(_ loadMoreGridViewController: LoadMoreGridViewController) {
        // nothing
    }
    
    func didEndDisplayingHeader(_ loadMoreGridViewController: LoadMoreGridViewController) {
        // nothing
    }
    
    func getNumberOfItems(_ loadMoreGridViewController: LoadMoreGridViewController) -> Int {
        return guessGridViewPresenter.itemsCount
    }
    
    func getItemFor(_ loadMoreGridViewController: LoadMoreGridViewController, index: Int) -> Entity? {
        return guessGridViewPresenter.itemFor(index: index)
    }
    
    func loadMoreItems(_ loadMoreGridViewController: LoadMoreGridViewController) {
        guessGridViewPresenter.loadItems()
    }
    
    func loadImageFor(_ loadMoreGridViewController: LoadMoreGridViewController, index: Int, completion: @escaping (UIImage?, String?) -> Void) {
        guessGridViewPresenter.loadImageFor(index: index, completion: completion)
    }
    
    func didPresentEntityDetail() {
        // nothing
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // nothing
    }
}

/*extension GuessGridViewController: AppodealBannerDelegate {
    func bannerDidLoadAdIsPrecache(_ precache: Bool) {
        print("*** BANNER DID LOAD AD IS PRECACHE")
    }
    
    func bannerDidShow() {
        print("*** BANNER DID SHOW")
    }
    
    // banner failed to load
    func bannerDidFailToLoadAd() {
        print("*** BANNER DID FAIL TO LOAD AD")
    }
    
    // banner was clicked
    func bannerDidClick() {
        print("*** BANNER DID CLICK")
    }
    
    // banner did expire and could not be shown
    func bannerDidExpired() {
        print("*** BANNER DID EXPIRED")
    }
}*/
