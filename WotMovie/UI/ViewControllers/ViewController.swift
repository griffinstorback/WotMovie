//
//  ViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-06.
//

import UIKit

class ViewController: UIViewController {

    private var networkManager: NetworkManager!
    
    init(networkManager: NetworkManager) {
        super.init(nibName: nil, bundle: nil)
        self.networkManager = networkManager
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .green
        
        networkManager.getNewMovies(page: 1) { movies, error in
            
        }
    }


}

