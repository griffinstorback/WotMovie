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
        
        let listViewController = UINavigationController(rootViewController: ListViewController())
        let listImage = UIImage(named: "list_icon")
        listViewController.tabBarItem = UITabBarItem(title: nil, image: listImage?.withTintColor(.gray), selectedImage: listImage?.withTintColor(Constants.Colors.defaultBlue))
        
        let settingsViewController = UINavigationController(rootViewController: SettingsViewController())
        let settingsImage = UIImage(named: "settings_icon")
        settingsViewController.tabBarItem = UITabBarItem(title: nil, image: settingsImage?.withTintColor(.gray), selectedImage: settingsImage?.withTintColor(Constants.Colors.defaultBlue))
        
        self.setViewControllers([listViewController, guessViewController, settingsViewController], animated: true)
        self.selectedViewController = guessViewController
    }
}
