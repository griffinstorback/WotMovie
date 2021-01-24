//
//  WatchlistViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-01-23.
//

import UIKit

protocol WatchlistViewDelegate {
    func reloadData()
}

class WatchlistViewController: UIViewController {

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .green
        navigationItem.title = "Watchlist"
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
}

extension WatchlistViewController: WatchlistViewDelegate {
    func reloadData() {
        print("Reload data in watchlist vc")
    }
}
