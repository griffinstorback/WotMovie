//
//  ListCategoryGridViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-01-26.
//

import Foundation
import UIKit

protocol ListCategoryGridViewDelegate: NSObjectProtocol {
    func reloadData()
}

class ListCategoryGridViewController: UIViewController {
    let listCategoryGridPresenter: ListCategoryGridPresenterProtocol
    
    private let gridView: LoadMoreGridViewController
    private let searchController: UISearchController
    
    init(listCategory: ListCategory) {
        listCategoryGridPresenter = ListCategoryGridPresenter(listCategoryType: listCategory.type)
        
        gridView = LoadMoreGridViewController()
        searchController = UISearchController()
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = listCategory.title
        setupViews()
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.searchController = searchController
        searchController.isActive = true
        
        listCategoryGridPresenter.setViewDelegate(self)
        
        gridView.delegate = self
    }
    
    private func layoutViews() {
        //addChildViewController(gridView)
        //gridView.view.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listCategoryGridPresenter.loadItems()
        
        addChildViewController(gridView)
        gridView.view.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
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
        let category = listCategoryGridPresenter.listCategoryType
        
        switch category {
        case .movieOrTvShowWatchlist:
            
            let genreSelectionButton = UIBarButtonItem(title: "Movies & TV", style: .plain, target: self, action: #selector(selectEntityTypesToDisplay))
            navigationItem.rightBarButtonItem = genreSelectionButton
        case .personFavorites:
            // Maybe instead of "All genres" in top right, have "All job types" with a drop down
            // with options e.g. "Actor/Actress", "Director", etc.
            // --- prob not now that types are in top right instead of genre.
            // ------- prob should have job types under sort menu instead
            break
        case .allGuessed:
            
            // TODO: only show all genres button if movies or tv shows only are selected,
            //       as genres for people makes no sense? (also could have "all jobs" for person)
            let genreSelectionButton = UIBarButtonItem(title: "All types", style: .plain, target: self, action: #selector(selectEntityTypesToDisplay))
            navigationItem.rightBarButtonItem = genreSelectionButton
        case .allRevealed:
            let genreSelectionButton = UIBarButtonItem(title: "All types", style: .plain, target: self, action: #selector(selectEntityTypesToDisplay))
            navigationItem.rightBarButtonItem = genreSelectionButton
        }
        
        // bookmark button is actually the sort button.
        searchController.searchBar.setImage(UIImage(named: "sort_icon"), for: .bookmark, state: .normal)
        searchController.searchBar.showsBookmarkButton = true
    }
    
    // right bar item
    @objc func selectEntityTypesToDisplay() {
        let typesDisplayedSelections = listCategoryGridPresenter.getTypesAvailableToDisplay()
        let typesDisplayedSelectionController = UIAlertController.actionSheetWithItems(controllerTitle: "Display", items: typesDisplayedSelections) { selectedValue in
            // set the type on presenter to filter items
            self.listCategoryGridPresenter.setTypesToDisplay(listCategoryDisplayTypes: selectedValue)
            
            // set the button string to update what type we are now seeing
            self.navigationItem.rightBarButtonItem?.title = selectedValue.rawValue
        }
        
        typesDisplayedSelectionController.popoverPresentationController?.sourceView = navigationItem.titleView
        present(typesDisplayedSelectionController, animated: true)
    }
}

extension ListCategoryGridViewController: LoadMoreGridViewDelegate {
    func getNumberOfItems(_ loadMoreGridViewController: LoadMoreGridViewController) -> Int {
        return listCategoryGridPresenter.itemsCount
    }
    
    func getItemFor(_ loadMoreGridViewController: LoadMoreGridViewController, index: Int) -> Entity? {
        return listCategoryGridPresenter.itemFor(index: index)
    }
    
    func loadMoreItems(_ loadMoreGridViewController: LoadMoreGridViewController) {
        // nothing
    }
    
    func loadImageFor(_ loadMoreGridViewController: LoadMoreGridViewController, index: Int, completion: @escaping (UIImage?, String?) -> Void) {
        listCategoryGridPresenter.loadImageFor(index: index, completion: completion)
    }
    
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // nothing
    }
}

extension ListCategoryGridViewController: ListCategoryGridViewDelegate {
    func reloadData() {
        gridView.reloadData()
    }
}
