//
//  SearchViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-04-07.
//

import UIKit

protocol SearchViewDelegate: NSObjectProtocol {
    func reloadData()
    func searchStartedLoading()
}

class SearchViewController: UIViewController {
    let searchPresenter: SearchPresenterProtocol
    
    private let resultsTableView: EntityTableViewController
    private let searchController: UISearchController
    
    private let placeholderLabelWhenNoResultsShown: UILabel
    private let loadingIndicatorOrErrorView: LoadingIndicatorOrErrorView
    
    init(presenter: SearchPresenterProtocol? = nil) {
        searchPresenter = presenter ?? SearchPresenter()
        
        resultsTableView = EntityTableViewController()
        searchController = UISearchController(searchResultsController: nil)
        
        placeholderLabelWhenNoResultsShown = UILabel()
        loadingIndicatorOrErrorView = LoadingIndicatorOrErrorView(state: .loaded)
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = "Search"
        setupViews()
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.searchController = searchController
        
        resultsTableView.setDelegate(self)
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.isActive = true
        searchController.searchBar.delegate = self
        
        placeholderLabelWhenNoResultsShown.textAlignment = .center
        placeholderLabelWhenNoResultsShown.textColor = .secondaryLabel
        placeholderLabelWhenNoResultsShown.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        placeholderLabelWhenNoResultsShown.numberOfLines = 0
        
        searchPresenter.setViewDelegate(self)
    }
    
    private func layoutViews() {
        addChildViewController(resultsTableView)
        resultsTableView.view.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        
        view.addSubview(loadingIndicatorOrErrorView)
        loadingIndicatorOrErrorView.anchorToCenter(yAnchor: resultsTableView.view.centerYAnchor, xAnchor: resultsTableView.view.centerXAnchor)
        
        if searchPresenter.searchResultsCount == 0 {
            addOrUpdatePlaceholderLabelWhenNoResultsShown()
        }
    }
    
    // even if the label is already on screen, this function can still be called to update its text
    private func addOrUpdatePlaceholderLabelWhenNoResultsShown() {
        placeholderLabelWhenNoResultsShown.text = searchPresenter.stringToShowWhenNoResultsShown
        
        guard !view.subviews.contains(placeholderLabelWhenNoResultsShown) else { return }
        
        view.addSubview(placeholderLabelWhenNoResultsShown)
        placeholderLabelWhenNoResultsShown.anchor(top: nil, leading: resultsTableView.view.leadingAnchor, bottom: nil, trailing: resultsTableView.view.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40))
        placeholderLabelWhenNoResultsShown.anchorToCenter(yAnchor: resultsTableView.view.centerYAnchor, xAnchor: nil)
    }
    
    private func removePlaceholderLabelBecauseResultsWereShown() {
        guard view.subviews.contains(placeholderLabelWhenNoResultsShown) else { return }
        placeholderLabelWhenNoResultsShown.removeFromSuperview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavBarAndSearchBar()
        
        // unhide nav bar (it was hidden in viewWillAppear of parent, ListVC)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        // don't hide search bar when scrolling
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    // method needs to be called in view will appear.
    func setupNavBarAndSearchBar() {
        // set right bar button item to select types to show (movie, tv, person)
        let entityTypesSelectionButton = UIBarButtonItem(title: searchPresenter.getTypesCurrentlyDisplaying().rawValue, style: .done, target: self, action: #selector(selectEntityTypesToDisplay))
        navigationItem.rightBarButtonItem = entityTypesSelectionButton
        
        // bookmark button is actually the sort button.
        searchController.searchBar.setImage(UIImage(named: "sort_icon")?.withTintColor(UIColor(named: "AccentColor") ?? Constants.Colors.defaultBlue), for: .bookmark, state: .normal)
        searchController.searchBar.showsBookmarkButton = true
    }
    
    // right bar item
    @objc func selectEntityTypesToDisplay() {
        let typesDisplayedSelections = searchPresenter.getTypesAvailableToDisplay()
        let typesDisplayedSelectionController = UIAlertController.actionSheetWithItems(controllerTitle: "Display", items: typesDisplayedSelections) { selectedValue in
            // set the type on presenter to filter items
            self.searchPresenter.setTypesToDisplay(categoryDisplayTypes: selectedValue)
            
            // set the button string to update what type we are now seeing
            self.navigationItem.rightBarButtonItem?.title = selectedValue.rawValue
            
            // update text for label shown when no results yet
            self.addOrUpdatePlaceholderLabelWhenNoResultsShown()
        }
        
        typesDisplayedSelectionController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(typesDisplayedSelectionController, animated: true)
    }
}

extension SearchViewController: SearchViewDelegate {
    func reloadData() {
        resultsTableView.view.isHidden = false
        loadingIndicatorOrErrorView.state = .loaded
        resultsTableView.reloadData()
    }
    
    func searchStartedLoading() {
        resultsTableView.view.isHidden = true
        loadingIndicatorOrErrorView.state = .loading
        removePlaceholderLabelBecauseResultsWereShown()
    }
}

// could replace this with the UISearchBarDelegate function 'textDidChange'
extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchPresenter.setSearchText(searchController.searchBar.text)
    }
}

extension SearchViewController: EntityTableViewDelegate {
    func getSectionsCount() -> Int {
        return 1
    }
    
    func getCountForSection(section: Int) -> Int {
        let searchResultsCount = searchPresenter.searchResultsCount
        
        if searchResultsCount > 0 {
            // results available to show, so remove the placeholder label
            removePlaceholderLabelBecauseResultsWereShown()
        } else {
            // add or update text for label shown when no results
            addOrUpdatePlaceholderLabelWhenNoResultsShown()
        }
        return searchResultsCount
    }
    
    func getSectionTitle(for index: Int) -> String? {
        return nil
    }
    
    func getItem(for index: Int, section: Int) -> Entity? {
        guard section == 0 else { return nil }
        return searchPresenter.searchResultFor(index: index)
    }
    
    func loadImage(for index: Int, section: Int, completion: @escaping (UIImage?, String?) -> Void) {
        searchPresenter.loadImageFor(index: index, completion: completion)
    }
    
    func tableViewScrollViewDidScroll(_ scrollView: UIScrollView) {
        //searchController.searchBar.resignFirstResponder()
    }
}

extension SearchViewController: UISearchBarDelegate {
    /*func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        let sortGridViewController = SortGridViewController(sortParameters: searchPresenter.getSortParameters())
        sortGridViewController.resultsDelegate = self
        let navigationController = UINavigationController(rootViewController: sortGridViewController)
        navigationController.modalPresentationStyle = .formSheet
        
        present(navigationController, animated: true)
    }*/
}

/*
// get results back from 'sort' VC
extension SearchViewController: SortGridViewResultsDelegate {
    func didSaveWithParameters(_ sortParameters: SortParameters) {
        searchPresenter.setSortParameters(sortParameters)
    }
}
 */
