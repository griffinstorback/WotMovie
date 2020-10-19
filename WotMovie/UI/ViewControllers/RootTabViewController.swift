//
//  RootTabViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-13.
//

import UIKit

class RootTabViewController: UITabBarController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let guessViewController = UINavigationController(rootViewController: GuessViewController())
        guessViewController.tabBarItem = UITabBarItem(title: "Guess", image: UIImage(systemName: "home"), selectedImage: nil)
        
        let watchListViewController = UINavigationController(rootViewController: WatchListViewController())
        watchListViewController.tabBarItem = UITabBarItem(title: "Watchlist", image: nil, selectedImage: nil)
        
        let settingsViewController = UINavigationController(rootViewController: SettingsViewController())
        settingsViewController.tabBarItem = UITabBarItem(title: "Settings", image: nil, selectedImage: nil)
        
        self.setViewControllers([watchListViewController, guessViewController, settingsViewController], animated: true)
        self.selectedViewController = guessViewController
    }
}
