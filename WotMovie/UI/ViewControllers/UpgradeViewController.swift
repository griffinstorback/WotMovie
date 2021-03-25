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
    
    // show three examples of (broadly) what guess view looks like for people
    let examplePersonGuessViewsStackView: UIStackView
    let examplePersonGuessView1: ExamplePersonGuessView
    let examplePersonGuessView2: ExamplePersonGuessView
    let examplePersonGuessView3: ExamplePersonGuessView
    
    let infoLabelsStackView: UIStackView
    let infoLabel1Stack: UIStackView
    let infoLabel1Bullet: UILabel
    let infoLabel1: UILabel
    let infoLabel2Stack: UIStackView
    let infoLabel2Bullet: UILabel
    let infoLabel2: UILabel
    let infoLabel3Stack: UIStackView
    let infoLabel3Bullet: UILabel
    let infoLabel3: UILabel
    
    let buyUpgradeButtonContainer: UIView
    let buyUpgradeButton: ShrinkOnTouchButton
    
    init(presenter: UpgradePresenterProtocol? = nil) {
        upgradePresenter = presenter ?? UpgradePresenter()
        
        examplePersonGuessViewsStackView = UIStackView()
        examplePersonGuessView1 = ExamplePersonGuessView()
        examplePersonGuessView2 = ExamplePersonGuessView()
        examplePersonGuessView3 = ExamplePersonGuessView()
        
        infoLabelsStackView = UIStackView()
        infoLabel1Stack = UIStackView()
        infoLabel1Bullet = UILabel()
        infoLabel1 = UILabel()
        infoLabel2Stack = UIStackView()
        infoLabel2Bullet = UILabel()
        infoLabel2 = UILabel()
        infoLabel3Stack = UIStackView()
        infoLabel3Bullet = UILabel()
        infoLabel3 = UILabel()
        
        buyUpgradeButtonContainer = UIView()
        buyUpgradeButton = ShrinkOnTouchButton()
        
        super.init(nibName: nil, bundle: nil)
        
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        upgradePresenter.setViewDelegate(self)
        
        title = "Upgrade"
        
        view.backgroundColor = .systemBackground
        
        examplePersonGuessViewsStackView.axis = .horizontal
        examplePersonGuessViewsStackView.distribution = .fillEqually
        examplePersonGuessViewsStackView.spacing = 20
        examplePersonGuessViewsStackView.backgroundColor = .clear
        examplePersonGuessView1.layer.cornerRadius = 5
        examplePersonGuessView2.layer.cornerRadius = 5
        examplePersonGuessView3.layer.cornerRadius = 5
        
        infoLabelsStackView.axis = .vertical
        infoLabelsStackView.spacing = 15
        
        infoLabel1Stack.axis = .horizontal
        infoLabel1Bullet.text = "•"
        infoLabel1Bullet.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        infoLabel1.text = "Guess famous actors, actresses and directors"
        infoLabel1.font = UIFont.systemFont(ofSize: 18)
        infoLabel1.numberOfLines = 0
        
        infoLabel2Stack.axis = .horizontal
        infoLabel2Bullet.text = "•"
        infoLabel2Bullet.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        infoLabel2.text = "Test your knowlege on THOUSANDS of celebrities"
        infoLabel2.font = UIFont.systemFont(ofSize: 18)
        infoLabel2.numberOfLines = 0
        
        infoLabel3Stack.axis = .horizontal
        infoLabel3Bullet.text = "•"
        infoLabel3Bullet.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        infoLabel3.text = "Purchase ONCE, unlock PERMANENTLY"
        infoLabel3.font = UIFont.systemFont(ofSize: 18)
        infoLabel3.numberOfLines = 0
        
        buyUpgradeButtonContainer.giveBlurredBackground(style: .systemMaterial)
        
        buyUpgradeButton.setTitle("Buy Upgrade $1.99", for: .normal)
        buyUpgradeButton.setTitleColor(.white, for: .normal)
        buyUpgradeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        buyUpgradeButton.backgroundColor = UIColor(named: "AccentColor") ?? Constants.Colors.defaultBlue
        buyUpgradeButton.layer.cornerRadius = 10
        buyUpgradeButton.addTarget(self, action: #selector(buyUpgradeButtonPressed), for: .touchUpInside)
        
        let closeButton = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(closeButtonPressed))
        navigationItem.rightBarButtonItem = closeButton
    }
    
    var examplePersonGuessViewsStackViewLeftRightMargins: CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return 20
        case .pad:
            return 50
        default:
            return 20
        }
    }
    private func layoutViews() {
        view.addSubview(examplePersonGuessViewsStackView)
        examplePersonGuessViewsStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 10, left: examplePersonGuessViewsStackViewLeftRightMargins, bottom: 0, right: examplePersonGuessViewsStackViewLeftRightMargins))
        
        examplePersonGuessViewsStackView.addArrangedSubview(examplePersonGuessView1)
        examplePersonGuessViewsStackView.addArrangedSubview(examplePersonGuessView2)
        examplePersonGuessViewsStackView.addArrangedSubview(examplePersonGuessView3)
        
        view.addSubview(infoLabelsStackView)
        infoLabelsStackView.anchor(top: examplePersonGuessViewsStackView.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 10, bottom: 0, right: 10))
        
        infoLabel1Stack.addArrangedSubview(infoLabel1Bullet)
        infoLabel1Bullet.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: CGSize(width: 20, height: 0))
        infoLabel1Stack.addArrangedSubview(infoLabel1)
        
        infoLabel2Stack.addArrangedSubview(infoLabel2Bullet)
        infoLabel2Bullet.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: CGSize(width: 20, height: 0))
        infoLabel2Stack.addArrangedSubview(infoLabel2)
        
        infoLabel3Stack.addArrangedSubview(infoLabel3Bullet)
        infoLabel3Bullet.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: CGSize(width: 20, height: 0))
        infoLabel3Stack.addArrangedSubview(infoLabel3)
        
        infoLabelsStackView.addArrangedSubview(infoLabel1Stack)
        infoLabelsStackView.addArrangedSubview(infoLabel2Stack)
        infoLabelsStackView.addArrangedSubview(infoLabel3Stack)
        infoLabelsStackView.addArrangedSubview(UIView())
        
        view.addSubview(buyUpgradeButtonContainer)
        buyUpgradeButtonContainer.anchor(top: infoLabelsStackView.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        
        buyUpgradeButtonContainer.addSubview(buyUpgradeButton)
        buyUpgradeButton.anchor(top: buyUpgradeButtonContainer.topAnchor, leading: buyUpgradeButtonContainer.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: buyUpgradeButtonContainer.trailingAnchor, padding: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), size: CGSize(width: 0, height: 50))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        upgradePresenter.loadExamplePeople()
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
        
        // set the three example person images.
        upgradePresenter.loadImageFor(index: 0, completion: examplePersonGuessView1.setImage)
        upgradePresenter.loadImageFor(index: 1, completion: examplePersonGuessView2.setImage)
        upgradePresenter.loadImageFor(index: 2, completion: examplePersonGuessView3.setImage)
    }
    
    func displayError() {
        print("***** ERROR IN UPGRADE VIEW CONTROLLER: \(upgradePresenter.error)")
    }
    
    func upgradeWasPurchased() {
        self.dismiss(animated: true)
    }
}