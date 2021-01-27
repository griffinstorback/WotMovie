//
//  WatchlistCategoryGridViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-01-26.
//

import Foundation
import UIKit

protocol WatchlistCategoryGridViewDelegate: NSObjectProtocol {
    func reloadData()
}

class WatchlistCategoryGridViewController: UIViewController {
    let watchlistCategoryGridPresenter: WatchlistCategoryGridPresenterProtocol
    
    private let gridView: LoadMoreGridViewController
    
    init(watchlistCategory: WatchlistCategory) {
        watchlistCategoryGridPresenter = WatchlistCategoryGridPresenter(watchlistCategoryType: watchlistCategory.type)
        
        gridView = LoadMoreGridViewController()
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = watchlistCategory.title
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        navigationItem.largeTitleDisplayMode = .never
        
        watchlistCategoryGridPresenter.setViewDelegate(self)
        
        gridView.delegate = self
    }
    
    private func layoutViews() {
        //addChildViewController(gridView)
        //gridView.view.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        addChildViewController(gridView)
        gridView.view.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        super.viewDidDisappear(animated)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension WatchlistCategoryGridViewController: LoadMoreGridViewDelegate {
    func getNumberOfItems(_ loadMoreGridViewController: LoadMoreGridViewController) -> Int {
        return watchlistCategoryGridPresenter.itemsCount
    }
    
    func getItemFor(_ loadMoreGridViewController: LoadMoreGridViewController, index: Int) -> Entity? {
        return watchlistCategoryGridPresenter.itemFor(index: index)
    }
    
    func loadMoreItems(_ loadMoreGridViewController: LoadMoreGridViewController) {
        // load next page of items
        watchlistCategoryGridPresenter.loadItems()
    }
    
    func loadImageFor(_ loadMoreGridViewController: LoadMoreGridViewController, index: Int, completion: @escaping (UIImage?, String?) -> Void) {
        watchlistCategoryGridPresenter.loadImageFor(index: index, completion: completion)
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

extension WatchlistCategoryGridViewController: WatchlistCategoryGridViewDelegate {
    func reloadData() {
        gridView.reloadData()
    }
}
