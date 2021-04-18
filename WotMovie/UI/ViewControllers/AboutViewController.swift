//
//  AboutViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-04-13.
//

import UIKit

class AboutViewController: UIViewController {
    
    let contentStackView: UIStackView
    
    let contactUsContainer: ShrinkOnTouchView
    let contactUsLabel: UILabel
    let contactUsEmailLabel: UILabel
    
    let privacyPolicyButton: ShrinkOnTouchButton
    
    let tmdbAttributionContainer: UIView
    let tmdbAttributionImage: UIImageView
    let tmdbAttributionLabel: UILabel
    
    
    init() {
        contentStackView = UIStackView()
        
        contactUsContainer = ShrinkOnTouchView()
        contactUsLabel = UILabel()
        contactUsEmailLabel = UILabel()
        
        privacyPolicyButton = ShrinkOnTouchButton()
        
        tmdbAttributionContainer = UIView()
        tmdbAttributionImage = UIImageView()
        tmdbAttributionLabel = UILabel()
        
        super.init(nibName: nil, bundle: nil)
        
        setupViews()
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        title = "About"
        view.backgroundColor = .systemBackground
        
        contentStackView.axis = .vertical
        contentStackView.alignment = .fill
        contentStackView.spacing = 20
        
        contactUsContainer.layer.masksToBounds = true
        contactUsContainer.layer.cornerRadius = 10
        contactUsContainer.backgroundColor = .systemGray6
        contactUsLabel.text = "For support, or other inquiries, contact us at"
        contactUsLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        contactUsEmailLabel.text = "wotmovie_app@gmail.com"
        contactUsEmailLabel.textColor = UIColor(named: "AccentColor") ?? Constants.Colors.defaultBlue
        contactUsEmailLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        
        privacyPolicyButton.backgroundColor = .systemGray6
        privacyPolicyButton.layer.masksToBounds = true
        privacyPolicyButton.layer.cornerRadius = 10
        privacyPolicyButton.setTitleColor(UIColor(named: "AccentColor") ?? Constants.Colors.defaultBlue, for: .normal)
        privacyPolicyButton.setTitle("Privacy policy", for: .normal)
        privacyPolicyButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        privacyPolicyButton.addTarget(self, action: #selector(openPrivacyPolicy), for: .touchUpInside)
        
        tmdbAttributionImage.image = UIImage(named: "tmdb_attribution")
        tmdbAttributionImage.contentMode = .scaleAspectFit
        tmdbAttributionLabel.text = "This product uses the TMDb API but is not endorsed or certified by TMDb."
        tmdbAttributionLabel.numberOfLines = 0
        tmdbAttributionLabel.textColor = .secondaryLabel
        tmdbAttributionLabel.textAlignment = .center
    }
    
    private func layoutViews() {
        view.addSubview(contentStackView)
        contentStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10))
        
        contactUsContainer.addSubview(contactUsLabel)
        contactUsLabel.anchor(top: contactUsContainer.topAnchor, leading: contactUsContainer.leadingAnchor, bottom: nil, trailing: contactUsContainer.trailingAnchor, padding: UIEdgeInsets(top: 15, left: 15, bottom: 0, right: 15))
        contactUsContainer.addSubview(contactUsEmailLabel)
        contactUsEmailLabel.anchor(top: contactUsLabel.bottomAnchor, leading: contactUsContainer.leadingAnchor, bottom: contactUsContainer.bottomAnchor, trailing: contactUsContainer.trailingAnchor, padding: UIEdgeInsets(top: 5, left: 15, bottom: 15, right: 15))
        contentStackView.addArrangedSubview(contactUsContainer)
        
        // make privacy policy button same size as contactUsContainer
        contentStackView.addArrangedSubview(privacyPolicyButton)
        privacyPolicyButton.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: CGSize(width: 0, height: 50))
    
        tmdbAttributionContainer.addSubview(tmdbAttributionImage)
        tmdbAttributionImage.anchor(top: tmdbAttributionContainer.topAnchor, leading: nil, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0), size: CGSize(width: 80, height: 80))
        tmdbAttributionImage.anchorToCenter(yAnchor: nil, xAnchor: tmdbAttributionContainer.centerXAnchor)
        tmdbAttributionContainer.addSubview(tmdbAttributionLabel)
        tmdbAttributionLabel.anchor(top: tmdbAttributionImage.bottomAnchor, leading: tmdbAttributionContainer.leadingAnchor, bottom: tmdbAttributionContainer.bottomAnchor, trailing: tmdbAttributionContainer.trailingAnchor, padding: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
        contentStackView.addArrangedSubview(tmdbAttributionContainer)
        
        // spacing to fill to bottom
        contentStackView.addArrangedSubview(UIView())
    }
    
    @objc func openPrivacyPolicy() {
        print("***** SHOW THE PRIVACY POLICY IN A WEB VIEW>")
    }
}
