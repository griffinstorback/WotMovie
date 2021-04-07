//
//  SearchViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-04-07.
//

import UIKit

protocol SearchViewDelegate: NSObjectProtocol {
    func reloadData()
}

class SearchViewController: UIViewController {
    let searchPresenter: SearchPresenterProtocol
    
    private let resultsTableView: EntityTableViewController
    private let searchController: UISearchController
    
    init(presenter: SearchPresenterProtocol? = nil) {
        searchPresenter = presenter ?? SearchPresenter()
        
        resultsTableView = EntityTableViewController()
        searchController = UISearchController(searchResultsController: nil)
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = "Search"
        setupViews()
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.searchController = searchController
        
        resultsTableView.setDelegate(self)
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.isActive = true
        searchController.searchBar.delegate = self
        
        searchPresenter.setViewDelegate(self)
    }
    
    private func layoutViews() {
        // Had to move this to viewDidLoad for some reason but don't remember why... something about needing to call loadItems first?
        //addChildViewController(gridView)
        //gridView.view.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        addChildViewController(resultsTableView)
        resultsTableView.view.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
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
        /*let entityTypesSelectionButton = UIBarButtonItem(title: listCategoryGridPresenter.getTypesCurrentlyDisplaying().rawValue, style: .done, target: self, action: #selector(selectEntityTypesToDisplay))
        navigationItem.rightBarButtonItem = entityTypesSelectionButtonswitch*/
        
        // bookmark button is actually the sort button.
        searchController.searchBar.setImage(UIImage(named: "sort_icon")?.withTintColor(UIColor(named: "AccentColor") ?? Constants.Colors.defaultBlue), for: .bookmark, state: .normal)
        searchController.searchBar.showsBookmarkButton = true
    }
    
    // right bar item
    /*@objc func selectEntityTypesToDisplay() {
        let typesDisplayedSelections = listCategoryGridPresenter.getTypesAvailableToDisplay()
        let typesDisplayedSelectionController = UIAlertController.actionSheetWithItems(controllerTitle: "Display", items: typesDisplayedSelections) { selectedValue in
            // set the type on presenter to filter items
            self.listCategoryGridPresenter.setTypesToDisplay(listCategoryDisplayTypes: selectedValue)
            
            // set the button string to update what type we are now seeing
            self.navigationItem.rightBarButtonItem?.title = selectedValue.rawValue
        }
        
        typesDisplayedSelectionController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(typesDisplayedSelectionController, animated: true)
    }*/
}

extension SearchViewController: SearchViewDelegate {
    func reloadData() {
        resultsTableView.reloadData()
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
        return searchPresenter.searchResultsCount
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
