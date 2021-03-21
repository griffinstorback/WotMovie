//
//  UpgradeViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-03-17.
//

import UIKit

protocol UpgradeViewDelegate: NSObjectProtocol {
    func reloadData()
    func displayError()
    func upgradeWasPurchased()
}

class UpgradeViewController: UIViewController {
    
    let upgradePresenter: UpgradePresenterProtocol
    
    let buyUpgradeButton: ShrinkOnTouchButton
    
    init(presenter: UpgradePresenterProtocol? = nil) {
        upgradePresenter = presenter ?? UpgradePresenter()
        
        buyUpgradeButton = ShrinkOnTouchButton()
        
        super.init(nibName: nil, bundle: nil)
        
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        upgradePresenter.setViewDelegate(self)
        
        title = "Upgrade"
        
        view.backgroundColor = .systemBackground
        
        buyUpgradeButton.setTitle("Buy Upgrade $3.99", for: .normal)
        buyUpgradeButton.setTitleColor(.white, for: .normal)
        buyUpgradeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        buyUpgradeButton.backgroundColor = UIColor(named: "AccentColor") ?? Constants.Colors.defaultBlue
        buyUpgradeButton.layer.cornerRadius = 10
        buyUpgradeButton.addTarget(self, action: #selector(buyUpgradeButtonPressed), for: .touchUpInside)
        
        let closeButton = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(closeButtonPressed))
        navigationItem.rightBarButtonItem = closeButton
    }
    
    private func layoutViews() {
        view.addSubview(buyUpgradeButton)
        buyUpgradeButton.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), size: CGSize(width: 0, height: 50))
    }
    
    @objc func buyUpgradeButtonPressed() {
        if let deviceCanMakePayments = upgradePresenter.purchasePersonGuessingUpgrade() {
            if !deviceCanMakePayments {
                print("***** DEVICE CANNOT MAKE PAYMENTS. SHOW ALERT")
                return
            }
        } else {
            print("***** PRODUCTS LIST WAS EMPTY")
            return
        }
    }
    
    @objc func closeButtonPressed() {
        self.dismiss(animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UpgradeViewController: UpgradeViewDelegate {
    func reloadData() {
        print("***** UPGRADE VIEW reload data")
    }
    
    func displayError() {
        print("***** ERROR IN UPGRADE VIEW CONTROLLER: \(upgradePresenter.error)")
    }
    
    func upgradeWasPurchased() {
        self.dismiss(animated: true)
    }
}
