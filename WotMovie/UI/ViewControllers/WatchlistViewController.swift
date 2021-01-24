//
//  WatchlistViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-01-23.
//

import UIKit

protocol WatchlistViewDelegate: NSObjectProtocol {
    func reloadData()
}

class WatchlistViewController: UIViewController {
    
    let watchlistPresenter: WatchlistPresenterProtocol
    
    let categoryTableView: ContentSizedTableView
    let recentlyViewedCollectionView: UICollectionView
    
    init(presenter: WatchlistPresenterProtocol? = nil) {
        // use passed in presenter if provided (used in tests)
        watchlistPresenter = presenter ?? WatchlistPresenter()
        categoryTableView = ContentSizedTableView()
        recentlyViewedCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        super.init(nibName: nil, bundle: nil)
        
        categoryTableView.delegate = self
        recentlyViewedCollectionView.delegate = self
        watchlistPresenter.setViewDelegate(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .green
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
}

extension WatchlistViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

extension WatchlistViewController: UICollectionViewDelegateFlowLayout {
    
}

extension WatchlistViewController: WatchlistViewDelegate {
    func reloadData() {
        print("Reload data in watchlist vc")
    }
}
