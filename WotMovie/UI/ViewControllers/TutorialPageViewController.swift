//
//  TutorialPageViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-04-23.
//

import UIKit

protocol TutorialPageViewDelegate: NSObjectProtocol {
    func reloadData() // probably isn't called - data is static (as of writing this comment)
}

class TutorialPageViewController: UIPageViewController {
    
    let tutorialPagePresenter: TutorialPagePresenterProtocol
    
    var orderedPageDetailViewControllers: [UIViewController] = []

    init(presenter: TutorialPagePresenterProtocol? = nil) {
        tutorialPagePresenter = presenter ?? TutorialPagePresenter()
        
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [:])
        
        setupViewsAndViewControllers()
    }
    
    private func setupViewsAndViewControllers() {
        self.view.backgroundColor = .systemGray5
        
        // annoyingly this is the only way to change tint color of dots at bottom (indicating currentpage of the pagecontroller)
        UIPageControl.appearance().pageIndicatorTintColor = .quaternaryLabel
        UIPageControl.appearance().currentPageIndicatorTintColor = .label
        
        dataSource = self
        delegate = self
        
        // get the detail views identifiers from the presenter, init the detail VCs, add them to orderedPageDetailViewControllers
        for i in 0..<tutorialPagePresenter.getDetailViewCount() {
            let tutorialPageDetail = TutorialPageDetailViewController(type: tutorialPagePresenter.getDetailViewIdentifier(for: i))
            tutorialPageDetail.delegate = self
            orderedPageDetailViewControllers.append(tutorialPageDetail)
        }
        
        if tutorialPagePresenter.getDetailViewCount() > 0 {
            setViewControllers([orderedPageDetailViewControllers[0]], direction: .forward, animated: true, completion: nil)
        } else {
            print("** ERROR: no detail views found for the TutorialPageViewController!")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TutorialPageViewController: UIPageViewControllerDelegate {
    
}

extension TutorialPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedPageDetailViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex < orderedPageDetailViewControllers.count, previousIndex >= 0 else {
            return nil
        }
        
        return orderedPageDetailViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedPageDetailViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < orderedPageDetailViewControllers.count, nextIndex >= 0 else {
            return nil
        }
        
        return orderedPageDetailViewControllers[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedPageDetailViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}

extension TutorialPageViewController: TutorialPageDetailViewDelegate {
    func getTitleText(type: TutorialPageDetailViewType) -> String {
        return tutorialPagePresenter.getTitleTextFor(type: type)
    }
    
    func getBodyText(type: TutorialPageDetailViewType) -> String {
        return tutorialPagePresenter.getBodyTextFor(type: type)
    }
    
    func getImageName(type: TutorialPageDetailViewType) -> String {
        return tutorialPagePresenter.getImageNameFor(type: type)
    }
    
    func dismissTutorial() {
        self.dismiss(animated: true)
    }
}
