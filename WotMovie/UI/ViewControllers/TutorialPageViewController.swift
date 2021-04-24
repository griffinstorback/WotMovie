//
//  TutorialPageViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-04-23.
//

import UIKit

protocol TutorialPageViewDelegate: NSObjectProtocol {
    func reloadData()
}

class TutorialPageViewController: UIPageViewController {
    
    lazy var orderedViewControllers: [UIViewController] = {
        return [TutorialPageDetailViewController(identifier: "")]
    }()

    init() {
        
        
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [:])
        
        dataSource = self
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

extension TutorialPageViewController: UIPageViewControllerDelegate {
    
}

extension TutorialPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex < orderedViewControllers.count, previousIndex >= 0 else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < orderedViewControllers.count, nextIndex >= 0 else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
