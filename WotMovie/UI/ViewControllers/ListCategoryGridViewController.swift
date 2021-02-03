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
    }
    
    // use this to only perform certain viewDidAppear/WillAppear method calls (like hiding search bar on scroll)
    private var isInitialLoad = true
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // unhide serach bar after it has been shown initially.
        if isInitialLoad {
            isInitialLoad = false
            //navigationItem.hidesSearchBarWhenScrolling = true
        }
    }
    
    // method needs to be called in view will appear.
    func setupNavBarAndSearchBar() {
        // initially don't hide search bar, so that it is initially showing (its set to true in didAppear)
        if isInitialLoad {
            navigationItem.hidesSearchBarWhenScrolling = false
        }
        
        let category = listCategoryGridPresenter.listCategoryType
        
        switch category {
        case .movieOrTvShowWatchlist:
            //searchController.searchBar.scopeButtonTitles = ["All", "Movies", "TV Shows"]
            //searchController.searchBar.showsScopeBar = true
            
            let genreSelectionButton = UIBarButtonItem(title: "Movies & TV", style: .plain, target: self, action: nil)
            navigationItem.rightBarButtonItem = genreSelectionButton
        case .personFavorites:
            // Maybe instead of "All genres" in top right, have "All job types" with a drop down
            // with options e.g. "Actor/Actress", "Director", etc.
            // --- prob not now that types are in top right instead of genre.
            break
        case .allGuessed:
            //searchController.searchBar.scopeButtonTitles = ["All", "Without hint", "With hint"]
            //searchController.searchBar.showsScopeBar = true
            
            // TODO: only show all genres button if movies or tv shows only are selected,
            //       as genres for people makes no sense? (also could have "all jobs" for person)
            let genreSelectionButton = UIBarButtonItem(title: "All types", style: .plain, target: self, action: nil)
            navigationItem.rightBarButtonItem = genreSelectionButton
        case .allRevealed:
            let genreSelectionButton = UIBarButtonItem(title: "All types", style: .plain, target: self, action: nil)
            navigationItem.rightBarButtonItem = genreSelectionButton
        }
        
        // bookmark button is actually the sort button.
        searchController.searchBar.setImage(UIImage(named: "sort_icon"), for: .bookmark, state: .normal)
        searchController.searchBar.showsBookmarkButton = true
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
