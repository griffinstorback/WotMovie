//
//  AboutViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-04-13.
//

import UIKit

class AboutViewController: UIViewController {
    
    let privacyPolicyButton: UIButton
    
    init() {
        privacyPolicyButton = UIButton()
        
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
        
        privacyPolicyButton.setTitleColor(UIColor(named: "AccentColor") ?? Constants.Colors.defaultBlue, for: .normal)
        privacyPolicyButton.setTitle("Privacy policy", for: .normal)
        privacyPolicyButton.addTarget(self, action: #selector(openPrivacyPolicy), for: .touchUpInside)
    }
    
    private func layoutViews() {
        view.addSubview(privacyPolicyButton)
        privacyPolicyButton.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)//, size: CGSize(width: 0, height: 50))
    }
    
    @objc func openPrivacyPolicy() {
        print("***** SHOW THE PRIVACY POLICY IN A WEB VIEW>")
    }
}
