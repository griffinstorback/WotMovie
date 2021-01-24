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
        let questionMarkImage = UIImage(named: "question_mark")
        guessViewController.tabBarItem = UITabBarItem(title: nil, image: questionMarkImage?.withTintColor(.gray), selectedImage: questionMarkImage?.withTintColor(Constants.Colors.defaultBlue))
        
        let watchListViewController = UINavigationController(rootViewController: WatchlistViewController())
        watchListViewController.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "list.bullet")?.withTintColor(.gray), selectedImage: UIImage(systemName: "list.bullet")?.withTintColor(Constants.Colors.defaultBlue))
        
        let settingsViewController = UINavigationController(rootViewController: SettingsViewController())
        settingsViewController.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "gear")?.withTintColor(.gray), selectedImage: UIImage(systemName: "gear")?.withTintColor(Constants.Colors.defaultBlue))
        
        self.setViewControllers([watchListViewController, guessViewController, settingsViewController], animated: true)
        self.selectedViewController = guessViewController
    }
}
