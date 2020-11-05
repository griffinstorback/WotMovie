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
        guessViewController.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        
        let watchListViewController = UINavigationController(rootViewController: WatchListViewController())
        watchListViewController.tabBarItem = UITabBarItem(title: "Watchlist", image: UIImage(systemName: "list.bullet"), selectedImage: nil)
        
        let settingsViewController = UINavigationController(rootViewController: SettingsViewController())
        settingsViewController.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), selectedImage: nil)
        
        self.setViewControllers([watchListViewController, guessViewController, settingsViewController], animated: true)
        self.selectedViewController = guessViewController
    }
}
