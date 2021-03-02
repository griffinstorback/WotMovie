//
//  ListViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-01-23.
//

import UIKit

protocol ListViewDelegate: NSObjectProtocol {
    func reloadRecentlyViewedData()
    func reloadCategoryListData()
    
    func revealEntities(at indices: [Int])
    func revealCorrectlyGuessedEntities(at indices: [Int])
}

class ListViewController: UIViewController {
    
    let listPresenter: ListPresenterProtocol
    
    let statusBarCoverView: UIView
    
    // recentlyViewedCollectionView contains header with category table view inside
    let recentlyViewedCollectionView: LoadMoreGridViewController
    
    // keep reference to header so we can reload table view rows when needed (when counts change)
    weak var recentlyViewedCollectionViewHeader: RecentlyViewedCollectionViewHeader?
    
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
        
        statusBarCoverView.giveBlurredBackground(style: .systemMaterial)
        statusBarCoverView.alpha = 0
        
        recentlyViewedCollectionView.delegate = self
        recentlyViewedCollectionView.transitionPresenter = listPresenter
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
    
    var justPresentedEntityDetail: Bool = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // query recently viewed if arriving from another page other than an entity detail.
        if !justPresentedEntityDetail {
            listPresenter.loadRecentlyViewed()
        }
        justPresentedEntityDetail = false
        
        // reload counts for categories in category list (in recentlyViewedCollectionView header)
        listPresenter.loadCategoryCounts()
        
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
        cell.setIconImage(imageName: category.imageName, tintColor: .label)
        
        let countForStatType = listPresenter.getCountForCategory(index: indexPath.row)
        cell.detailTextLabel?.text = String(countForStatType)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        cell.detailTextLabel?.textColor = UIColor(named: "AccentColor") ?? Constants.Colors.defaultBlue
        
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
        
        // keep reference to header so we can reload cells.
        recentlyViewedCollectionViewHeader = headerView
        
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
        // nothing (amount of recently viewed displayed is static - 60 as of writing this comment)
    }
    
    func loadImageFor(_ loadMoreGridViewController: LoadMoreGridViewController, index: Int, completion: @escaping (UIImage?, String?) -> Void) {
        listPresenter.loadImageFor(index: index, completion: completion)
    }
    
    func didPresentEntityDetail() {
        // make sure recently viewed doesn't reload after presenting entity modal (causes bugs with animating poster image back to the correct grid cell)
        justPresentedEntityDetail = true
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
    func reloadRecentlyViewedData() {
        recentlyViewedCollectionView.reloadData()
    }
    
    // reloads when counts for categories change.
    func reloadCategoryListData() {
        recentlyViewedCollectionViewHeader?.categoryTableView.reloadData()
    }
    
    func revealEntities(at indices: [Int]) {
        recentlyViewedCollectionView.revealEntities(at: indices)
    }
    
    func revealCorrectlyGuessedEntities(at indices: [Int]) {
        recentlyViewedCollectionView.revealCorrectlyGuessedEntities(at: indices)
    }
}
