//
//  GuessDetailViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-13.
//

import UIKit

// TODO: Delete and rename GuessTitleDetailViewController
class GuessDetailViewController: UIViewController {
    
    private let guessDetailViewPresenter: GuessDetailPresenter
    
    private var detailOverviewView: DetailOverviewView!
    
    init(title: Title) {
        guessDetailViewPresenter = GuessDetailPresenter(networkManager: NetworkManager.shared, imageDownloadManager: ImageDownloadManager.shared, title: title)
        //detailOverviewView = DetailOverviewView()
        
        super.init(nibName: nil, bundle: nil)
        
        navigationItem.largeTitleDisplayMode = .never
        self.title = "?"
        view.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
