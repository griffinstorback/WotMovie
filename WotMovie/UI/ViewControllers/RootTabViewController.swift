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
        guessViewController.tabBarItem = UITabBarItem(title: nil, image: questionMarkImage?.withTintColor(.systemGray), selectedImage: questionMarkImage?.withTintColor(UIColor(named: "AccentColor") ?? Constants.Colors.defaultBlue))
        
        let listViewController = UINavigationController(rootViewController: ListViewController())
        let listImage = UIImage(named: "list_icon")
        listViewController.tabBarItem = UITabBarItem(title: nil, image: listImage?.withTintColor(.systemGray), selectedImage: listImage?.withTintColor(UIColor(named: "AccentColor") ?? Constants.Colors.defaultBlue))
        
        let searchViewController = UINavigationController(rootViewController: SearchViewController())
        let searchImage = UIImage(named: "search_icon")
        searchViewController.tabBarItem = UITabBarItem(title: nil, image: searchImage?.withTintColor(.systemGray), selectedImage: searchImage?.withTintColor(UIColor(named: "AccentColor") ?? Constants.Colors.defaultBlue))
        
        let settingsViewController = UINavigationController(rootViewController: SettingsViewController())
        let settingsImage = UIImage(named: "settings_icon")
        settingsViewController.tabBarItem = UITabBarItem(title: nil, image: settingsImage?.withTintColor(.systemGray), selectedImage: settingsImage?.withTintColor(UIColor(named: "AccentColor") ?? Constants.Colors.defaultBlue))
        
        self.setViewControllers([guessViewController, listViewController, searchViewController, settingsViewController], animated: true)
        self.selectedViewController = guessViewController
    }
    
    // This is just an extra check - flag to be set so that if something goes wrong with UserDefaults, this in memory check will at least
    // make it so the tutorial doesn't pop up everytime the user closes a modal.
    var presentedTutorialPagesThisSession: Bool = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // show the tutorial pages if user has not seen them yet (first time launching)
        if !SettingsManager.shared.userHasSeenIntroPages && !presentedTutorialPagesThisSession {
            let tutorialPageViewController = TutorialPageViewController()
            tutorialPageViewController.modalPresentationStyle = .fullScreen
            tutorialPageViewController.modalTransitionStyle = .crossDissolve
            present(tutorialPageViewController, animated: true)
            
            presentedTutorialPagesThisSession = true
        }
    }
}
