//
//  GuessGridViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-13.
//

import UIKit

protocol GuessGridViewDelegate: NSObjectProtocol {
    func displayLoadMoreItemsAlert(text: String)
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
    
    init(for category: GuessCategory, presenter: GuessGridPresenterProtocol? = nil) {
        // use passed in presenter if provided (used in tests)
        guessGridViewPresenter = presenter ?? GuessGridPresenter(category: category.type)
        
        gridView = LoadMoreGridViewController(shouldDisplayLoadMoreFooter: true)

        super.init(nibName: nil, bundle: nil)
        
        title = "\(category.shortTitle)"
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        navigationItem.largeTitleDisplayMode = .never
        
        guessGridViewPresenter.setViewDelegate(self)
        
        // make button on right side of navigation bar be for genre selection (except for People, obviously)
        if guessGridViewPresenter.category == .movie || guessGridViewPresenter.category == .tvShow {
            addGenreSelectionBarButton()
        }
        
        
        gridView.delegate = self
        gridView.transitionPresenter = guessGridViewPresenter
    }
    
    private func layoutViews() {
        addChildViewController(gridView)
        gridView.view.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
    }
    
    private func addGenreSelectionBarButton() {
        let genreSelectionButton = UIBarButtonItem(title: guessGridViewPresenter.getGenreCurrentlyDisplaying().name, style: .done, target: self, action: #selector(selectGenresToDisplay))
        navigationItem.rightBarButtonItem = genreSelectionButton
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
        
        // unhide nav bar (it was hidden in viewWillAppear of parent, GuessVC)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

extension GuessGridViewController: GuessGridViewDelegate {
    func displayLoadMoreItemsAlert(text: String) {
        BriefAlertView(title: text).present()
    }
    
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
    
    func isPresentingFromGuessGrid() -> Bool {
        return true
    }
    
    func didPresentEntityDetail() {
        // nothing
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // INSTEAD OF BELOW, currently what happens is when the footer is loaded, it shows the brief alert view.
        //      - the issue with that being, footer is loaded before its in view, so *could* be confusing.
        
        /*let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height
        print("***** bottomEdge: \(bottomEdge)")
        print("***** scrollView.contentSize.height: \(scrollView.contentSize.height)")
        if bottomEdge >= scrollView.contentSize.height {
            if guessGridViewPresenter.shouldNotLoadMoreItems() {
                BriefAlertView(title: "Guess some before loading more").present()
            }
        }*/
    }
}
