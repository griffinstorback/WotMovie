//
//  ListViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-01-23.
//

import UIKit

protocol ListViewDelegate: NSObjectProtocol {
    func reloadData()
}

class ListViewController: UIViewController {
    
    let listPresenter: ListPresenterProtocol
    
    let statusBarCoverView: UIView
    // recentlyViewedCollectionView contains header with category table view inside
    let recentlyViewedCollectionView: LoadMoreGridViewController
    
    init(presenter: ListPresenterProtocol? = nil) {
        // use passed in presenter if provided (used in tests)
        listPresenter = presenter ?? ListPresenter()
        
        statusBarCoverView = UIView()
        recentlyViewedCollectionView = LoadMoreGridViewController(shouldDisplayLoadMoreFooter: false)
        
        super.init(nibName: nil, bundle: nil)
        
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        listPresenter.setViewDelegate(self)
        
        statusBarCoverView.giveBlurredBackground(style: .systemThickMaterialLight)
        statusBarCoverView.alpha = 0
        
        recentlyViewedCollectionView.delegate = self
        recentlyViewedCollectionView.registerClassAsCollectionViewHeader(customClass: RecentlyViewedCollectionViewHeader.self)
    }
    
    private func layoutViews() {
        addChildViewController(recentlyViewedCollectionView)
        recentlyViewedCollectionView.view.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        
        view.addSubview(statusBarCoverView)
        statusBarCoverView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // query recently viewed (re-query whenever this page view appears)
        listPresenter.loadRecentlyViewed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // hide nav bar on this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

// table view at top of screen, providing categories e.g. "Watchlist, Favorites, Guessed"
extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listPresenter.getListCategoriesCount()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return RecentlyViewedCollectionViewHeader.categoryTableViewCellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCategoryTableViewCell") as! ListCategoryTableViewCell
        let category = listPresenter.getListCategoryFor(index: indexPath.row)
        cell.setCategoryLabelText(text: category.title)
        cell.setIconImage(imageName: category.imageName)
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = listPresenter.getListCategoryFor(index: indexPath.row)
        let listCategoryGridViewController = ListCategoryGridViewController(listCategory: category)
        navigationController?.pushViewController(listCategoryGridViewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ListViewController: LoadMoreGridViewDelegate {
    func viewForHeader(_ loadMoreGridViewController: LoadMoreGridViewController, indexPath: IndexPath) -> UICollectionReusableView? {
        let headerView = loadMoreGridViewController.collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! RecentlyViewedCollectionViewHeader
        
        // set this VC as delegate & data source for table view in the header
        headerView.categoryTableView.delegate = self
        headerView.categoryTableView.dataSource = self
        
        return headerView
    }
    
    func sizeForHeader(_ loadMoreGridViewController: LoadMoreGridViewController) -> CGSize {
        let categoryTableViewHeight = CGFloat(listPresenter.getListCategoriesCount()) * RecentlyViewedCollectionViewHeader.categoryTableViewCellHeight
        let recentlyViewedTitleLabelHeight = RecentlyViewedCollectionViewHeader.recentlyViewedTitleHeight
        let spaceFromTop = RecentlyViewedCollectionViewHeader.spaceFromTop
        
        let headerHeight = spaceFromTop + categoryTableViewHeight + recentlyViewedTitleLabelHeight
        return CGSize(width: 1, height: headerHeight)
    }
    
    func willDisplayHeader(_ loadMoreGridViewController: LoadMoreGridViewController) {
        // nothing
    }
    
    func didEndDisplayingHeader(_ loadMoreGridViewController: LoadMoreGridViewController) {
        // nothing
    }
    
    func getNumberOfItems(_ loadMoreGridViewController: LoadMoreGridViewController) -> Int {
        return listPresenter.getNumberOfRecentlyViewed()
    }
    
    func getItemFor(_ loadMoreGridViewController: LoadMoreGridViewController, index: Int) -> Entity? {
        return listPresenter.getRecentlyViewedFor(index: index)
    }
    
    func loadMoreItems(_ loadMoreGridViewController: LoadMoreGridViewController) {
        print("*** LOAD NEXT PAGE...")
    }
    
    func loadImageFor(_ loadMoreGridViewController: LoadMoreGridViewController, index: Int, completion: @escaping (UIImage?, String?) -> Void) {
        listPresenter.loadImageFor(index: index, completion: completion)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y
        
        // hide or unhide the opaque view under status bar, depending on if scrolled to top or not.
        if contentOffset <= 20 {
            statusBarCoverView.alpha = max(min(contentOffset/20, 1), 0)
        } else {
            statusBarCoverView.alpha = 1
        }
    }
}

extension ListViewController: ListViewDelegate {
    func reloadData() {
        recentlyViewedCollectionView.reloadData()
    }
}
