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
    
    let scrollView: UIScrollView
    let mainStackView: UIStackView
    
    // show three examples of (broadly) what guess view looks like for people
    let examplePersonGuessViewsStackView: UIStackView
    let examplePersonGuessView1: ExamplePersonGuessView
    let examplePersonGuessView2: ExamplePersonGuessView
    let examplePersonGuessView3: ExamplePersonGuessView
    
    let infoLabelsTitle: UILabel
    
    // kind of convoluted, but each bullet point needs its own view (for correct formatting).
    let infoLabelsStackView: UIStackView
    let infoLabel1Stack: UIStackView
    let infoLabel1Bullet: UILabel
    let infoLabel1: UILabel
    let infoLabel2Stack: UIStackView
    let infoLabel2Bullet: UILabel
    let infoLabel2: UILabel
    /*let infoLabel3Stack: UIStackView
    let infoLabel3Bullet: UILabel
    let infoLabel3: UILabel*/
    
    let bottomSpacingView: UIView // empty view at bottom of mainStack view, made equal to height of the bottom container, so that can scroll all the way down.
    
    let bottomContainer: UIView
    let unlockByPlayingLabel: UILabel
    let currentProgressLabel: UILabel
    let bottomContainerItemSeparator: UILabel // the label (with title - OR -) which separates unlockByPlayingLabel and buyUpgradeButton within the bottomContainer.
    let buyUpgradeButton: ShrinkOnTouchButton
    
    init(presenter: UpgradePresenterProtocol? = nil) {
        upgradePresenter = presenter ?? UpgradePresenter()
        
        scrollView = UIScrollView()
        mainStackView = UIStackView()
        
        examplePersonGuessViewsStackView = UIStackView()
        examplePersonGuessView1 = ExamplePersonGuessView()
        examplePersonGuessView2 = ExamplePersonGuessView()
        examplePersonGuessView3 = ExamplePersonGuessView()
        
        infoLabelsTitle = UILabel()
        
        infoLabelsStackView = UIStackView()
        infoLabel1Stack = UIStackView()
        infoLabel1Bullet = UILabel()
        infoLabel1 = UILabel()
        infoLabel2Stack = UIStackView()
        infoLabel2Bullet = UILabel()
        infoLabel2 = UILabel()
        /*infoLabel3Stack = UIStackView()
        infoLabel3Bullet = UILabel()
        infoLabel3 = UILabel()*/
        
        bottomSpacingView = UIView()
        
        bottomContainer = UIView()
        unlockByPlayingLabel = UILabel()
        currentProgressLabel = UILabel()
        bottomContainerItemSeparator = UILabel()
        buyUpgradeButton = ShrinkOnTouchButton()
        
        super.init(nibName: nil, bundle: nil)
        
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        upgradePresenter.setViewDelegate(self)
        
        title = "People"
        
        view.backgroundColor = .systemBackground
        
        scrollView.alwaysBounceVertical = true
        scrollView.bounces = true
        
        mainStackView.axis = .vertical
        mainStackView.alignment = .fill
        mainStackView.spacing = 20
        
        examplePersonGuessViewsStackView.axis = .horizontal
        examplePersonGuessViewsStackView.distribution = .fillEqually
        examplePersonGuessViewsStackView.spacing = 10
        examplePersonGuessViewsStackView.backgroundColor = .clear
        examplePersonGuessViewsStackView.layoutMargins = UIEdgeInsets(top: 10, left: examplePersonGuessViewsStackViewLeftRightMargins, bottom: 5, right: examplePersonGuessViewsStackViewLeftRightMargins)
        examplePersonGuessViewsStackView.isLayoutMarginsRelativeArrangement = true
        
        let proTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24, weight: .bold), NSAttributedString.Key.foregroundColor: UIColor(named: "AccentColor") ?? Constants.Colors.defaultBlue]
        let proText = NSMutableAttributedString(string: " People", attributes: proTextAttributes)
        let upgradeToWotMovieTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24, weight: .bold)]
        let upgradeToWotMovieText = NSMutableAttributedString(string: upgradePresenter.getTextFor(item: 0), attributes: upgradeToWotMovieTextAttributes)
        upgradeToWotMovieText.append(proText)
        infoLabelsTitle.attributedText = upgradeToWotMovieText
        
        infoLabelsStackView.axis = .vertical
        infoLabelsStackView.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        infoLabelsStackView.isLayoutMarginsRelativeArrangement = true
        infoLabelsStackView.spacing = 15
        
        infoLabel1Stack.axis = .horizontal
        infoLabel1Bullet.text = "•"
        //infoLabel1Bullet.textColor = .secondaryLabel
        infoLabel1Bullet.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        infoLabel1.text = upgradePresenter.getTextFor(item: 1)
        //infoLabel1.textColor = .secondaryLabel
        infoLabel1.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        infoLabel1.numberOfLines = 0
        
        infoLabel2Stack.axis = .horizontal
        infoLabel2Bullet.text = "•"
        //infoLabel2Bullet.textColor = .secondaryLabel
        infoLabel2Bullet.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        infoLabel2.text = upgradePresenter.getTextFor(item: 2)
        infoLabel2.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        infoLabel2.numberOfLines = 0
        
        /*infoLabel3Stack.axis = .horizontal
        infoLabel3Bullet.text = "•"
        infoLabel3Bullet.textColor = .secondaryLabel
        infoLabel3Bullet.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        infoLabel3.text = upgradePresenter.getTextFor(item: 3)
        infoLabel3.font = UIFont.systemFont(ofSize: 18)
        infoLabel3.numberOfLines = 0*/
        
        bottomContainer.giveBlurredBackground(style: .systemMaterial)
        
        unlockByPlayingLabel.text = "Unlock by playing 500 times"
        unlockByPlayingLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        unlockByPlayingLabel.textAlignment = .center
        unlockByPlayingLabel.numberOfLines = 1
        
        let unlockProgress = upgradePresenter.getUnlockProgress()
        currentProgressLabel.text = "Current progress: \(unlockProgress)/500"
        currentProgressLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        currentProgressLabel.textAlignment = .center
        currentProgressLabel.numberOfLines = 1
        currentProgressLabel.textColor = .secondaryLabel
        
        bottomContainerItemSeparator.text = "- OR -"
        bottomContainerItemSeparator.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        bottomContainerItemSeparator.textColor = .secondaryLabel
        bottomContainerItemSeparator.textAlignment = .center
        
        buyUpgradeButton.setTitle("Unlock now - $1.29", for: .normal)
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
        view.addSubview(scrollView)
        scrollView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        
        scrollView.addSubview(mainStackView)
        mainStackView.anchor(top: scrollView.topAnchor, leading: scrollView.leadingAnchor, bottom: scrollView.bottomAnchor, trailing: scrollView.trailingAnchor)
        mainStackView.anchorSize(height: nil, width: scrollView.widthAnchor)
        
        mainStackView.addArrangedSubview(examplePersonGuessViewsStackView)
        examplePersonGuessViewsStackView.addArrangedSubview(examplePersonGuessView1)
        examplePersonGuessViewsStackView.addArrangedSubview(examplePersonGuessView2)
        examplePersonGuessViewsStackView.addArrangedSubview(examplePersonGuessView3)
        
        
        
        // Info labels
        
        mainStackView.addArrangedSubview(infoLabelsStackView)
        
        infoLabel1Stack.addArrangedSubview(infoLabel1Bullet)
        infoLabel1Bullet.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: CGSize(width: 20, height: 0))
        infoLabel1Stack.addArrangedSubview(infoLabel1)
        
        infoLabel2Stack.addArrangedSubview(infoLabel2Bullet)
        infoLabel2Bullet.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: CGSize(width: 20, height: 0))
        infoLabel2Stack.addArrangedSubview(infoLabel2)
        
        /*infoLabel3Stack.addArrangedSubview(infoLabel3Bullet)
        infoLabel3Bullet.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: CGSize(width: 20, height: 0))
        infoLabel3Stack.addArrangedSubview(infoLabel3)*/
        
        infoLabelsStackView.addArrangedSubview(infoLabelsTitle)
        infoLabelsStackView.addArrangedSubview(infoLabel1Stack)
        infoLabelsStackView.addArrangedSubview(infoLabel2Stack)
        //infoLabelsStackView.addArrangedSubview(infoLabel3Stack)
        infoLabelsStackView.addArrangedSubview(UIView())
        
        
        
        // Bottom Container View
        
        view.addSubview(bottomContainer)
        bottomContainer.anchor(top: nil, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        
        bottomContainer.addSubview(unlockByPlayingLabel)
        unlockByPlayingLabel.anchor(top: bottomContainer.topAnchor, leading: bottomContainer.leadingAnchor, bottom: nil, trailing: bottomContainer.trailingAnchor, padding: UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10))
        
        bottomContainer.addSubview(currentProgressLabel)
        currentProgressLabel.anchor(top: unlockByPlayingLabel.bottomAnchor, leading: bottomContainer.leadingAnchor, bottom: nil, trailing: bottomContainer.trailingAnchor)
        
        bottomContainer.addSubview(bottomContainerItemSeparator)
        bottomContainerItemSeparator.anchor(top: currentProgressLabel.bottomAnchor, leading: bottomContainer.leadingAnchor, bottom: nil, trailing: bottomContainer.trailingAnchor, padding: UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10))
        
        bottomContainer.addSubview(buyUpgradeButton)
        buyUpgradeButton.anchor(top: bottomContainerItemSeparator.bottomAnchor, leading: bottomContainer.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: bottomContainer.trailingAnchor, padding: UIEdgeInsets(top: 10, left: 5, bottom: 5, right: 5), size: CGSize(width: 0, height: 50))
        
        
        // extra space at bottom of mainstack view to offset the height of the bottomcontainer.
        mainStackView.addArrangedSubview(bottomSpacingView)
        bottomSpacingView.anchorSize(height: bottomContainer.heightAnchor, width: nil)
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
