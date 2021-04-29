//
//  TutorialPageDetailViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-04-23.
//

import UIKit

protocol TutorialPageDetailViewDelegate: NSObjectProtocol {
    func getTitleText(type: TutorialPageDetailViewType) -> String
    func getBodyText(type: TutorialPageDetailViewType) -> String
    func getImageName(type: TutorialPageDetailViewType) -> String
    func nextPage()
    func dismissTutorial()
}

class TutorialPageDetailViewController: UIViewController {
    
    weak var delegate: TutorialPageDetailViewDelegate? {
        didSet {
            loadInfo()
        }
    }
    
    let type: TutorialPageDetailViewType
    
    let imageView: UIImageView
    let titleLabel: UILabel
    let bodyLabel: UILabel
    let spacingToBottom: UIView
    
    let bottomButton: ShrinkOnTouchButton // only displayed on first and last view controllers

    init(type: TutorialPageDetailViewType) {
        self.type = type
        
        imageView = UIImageView()
        titleLabel = UILabel()
        bodyLabel = UILabel()
        spacingToBottom = UIView()
        
        bottomButton = ShrinkOnTouchButton()
        
        super.init(nibName: nil, bundle: nil)
        
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemGray5
        
        imageView.contentMode = .scaleAspectFit
        
        // only affects template images, such as watchlist icon
        imageView.tintColor = .label
        
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        bodyLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        bodyLabel.numberOfLines = 0
        bodyLabel.textAlignment = .center
    }
    
    private func layoutViews() {
        view.addSubview(imageView)
        imageView.anchorToCenter(yAnchor: nil, xAnchor: view.centerXAnchor)
        imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 50).isActive = true
        
        
        imageView.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: CGSize(width: 250, height: 250))
        
        view.addSubview(titleLabel)
        titleLabel.anchor(top: imageView.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 30, left: 20, bottom: 0, right: 20))
        
        view.addSubview(bodyLabel)
        bodyLabel.anchor(top: titleLabel.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 10, left: 20, bottom: 50, right: 20))
        
        view.addSubview(spacingToBottom)
        spacingToBottom.anchor(top: bodyLabel.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        
        /*if type == .guessAndReveal || type == .unlockPeople {
            addBottomButtonAndLayout()
        }*/
        addBottomButtonAndLayout()
    }
    
    private func addBottomButtonAndLayout() {
        if type == .unlockPeople {
            bottomButton.backgroundColor = UIColor(named: "AccentColor") ?? Constants.Colors.defaultBlue
            bottomButton.layer.masksToBounds = true
            bottomButton.layer.cornerRadius = 10
            bottomButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            bottomButton.setTitleColor(.white, for: .normal)
            bottomButton.setTitle("Get started", for: .normal)
            bottomButton.addTarget(self, action: #selector(finishShowingTutorialPages), for: .touchUpInside)
        } else {
            bottomButton.backgroundColor = .systemGray6
            bottomButton.layer.masksToBounds = true
            bottomButton.layer.cornerRadius = 10
            bottomButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            bottomButton.setTitleColor(.secondaryLabel, for: .normal)
            bottomButton.setTitle("Next", for: .normal)
            bottomButton.addTarget(self, action: #selector(nextPageButtonPressed), for: .touchUpInside)
            //bottomButton.isUserInteractionEnabled = false
        }
        
        view.addSubview(bottomButton)
        bottomButton.anchor(top: nil, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10), size: CGSize(width: 0, height: 50))
        //bottomButton.anchorToCenter(yAnchor: nil, xAnchor: view.centerXAnchor)
    }
    
    @objc private func nextPageButtonPressed() {
        delegate?.nextPage()
    }
    
    @objc private func finishShowingTutorialPages() {
        SettingsManager.shared.userHasSeenIntroPages = true
        delegate?.dismissTutorial()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadInfo() {
        guard let delegate = delegate else {
            return
        }
        
        imageView.image = UIImage(named: delegate.getImageName(type: type))
        titleLabel.text = delegate.getTitleText(type: type)
        bodyLabel.text = delegate.getBodyText(type: type)
    }
}
