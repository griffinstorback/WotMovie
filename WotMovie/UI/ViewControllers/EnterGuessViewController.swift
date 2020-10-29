//
//  EnterGuessViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-28.
//

import UIKit

class EnterGuessViewController: UIViewController {
    
    // enterGuessPresenter
    
    private let bottomView: UIView!
    
    private let enterGuessField: UISearchBar!
    private var enterGuessFieldBottomConstraint: NSLayoutConstraint!
    
    private let resultsTableView: UITableView!

    init() {
        // enterGuessPresenter =
        bottomView = UIView()
        enterGuessField = UISearchBar()
        resultsTableView = UITableView()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = TouchDelegatingView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bottomView.backgroundColor = .white
        bottomView.layer.cornerRadius = 20
        bottomView.layer.masksToBounds = true
        bottomView.layer.borderWidth = 1
        bottomView.layer.borderColor = UIColor.separator.cgColor
        
        enterGuessField.delegate = self
        //enterGuessField.layer.cornerRadius = 20
        //enterGuessField.layer.masksToBounds = true
        enterGuessField.searchBarStyle = .minimal
        enterGuessField.placeholder = "Enter movie name"
        enterGuessField.tintColor = .systemBlue
        
        // TODO: Replace with question mark icon
        let enterGuessFieldIcon = UIImage(systemName: "magnifyingglass.circle.fill")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
        enterGuessField.setImage(enterGuessFieldIcon, for: .search, state: .normal)
        
        resultsTableView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        resultsTableView.separatorColor = .white
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        resultsTableView.alpha = 0
        resultsTableView.isHidden = true
        
        layoutSubviews()
    }
    
    private func layoutSubviews() {
        view.addSubview(bottomView)
        bottomView.anchor(top: nil, leading: nil, bottom: view.bottomAnchor, trailing: nil)
        bottomView.anchorSize(height: nil, width: view.widthAnchor)
        bottomView.anchorToCenter(yAnchor: nil, xAnchor: view.centerXAnchor)
        
        addGuessFieldToBottomView()
        
        view.addSubview(resultsTableView)
        resultsTableView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: bottomView.topAnchor, trailing: view.trailingAnchor)
    }
    
    private func addGuessFieldToBottomView() {
        bottomView.addSubview(enterGuessField)
        enterGuessFieldBottomConstraint = enterGuessField.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        enterGuessFieldBottomConstraint.isActive = true
        enterGuessField.anchor(top: bottomView.topAnchor, leading: bottomView.leadingAnchor, bottom: nil, trailing: bottomView.trailingAnchor, padding: UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10))
    }
    
    private func removeGuessFieldFromBottomView() {
        enterGuessField.removeFromSuperview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // let touches pass through to the guessdetailview
        if let delegatingView = view as? TouchDelegatingView {
            delegatingView.touchDelegate = presentingViewController?.view
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        super.viewDidDisappear(animated)
    }
    
    @objc func keyboardWillAppear(notification: Notification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame: NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = view.convert(keyboardRectangle, from: nil).origin.y
        
        let spacingBetweenKeyboardAndTextView: CGFloat = 10
        let constraintHeight = view.frame.height - view.safeAreaInsets.bottom - keyboardHeight + spacingBetweenKeyboardAndTextView
        
        enterGuessFieldBottomConstraint.constant = -constraintHeight
        resultsTableView.isHidden = false
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
            self.resultsTableView.alpha = 1
        }
        
        enterGuessField.setShowsCancelButton(true, animated: true)
    }
    
    @objc func keyboardWillDisappear() {
        enterGuessFieldBottomConstraint.constant = -10
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
            self.resultsTableView.alpha = 0
        } completion: { _ in
            self.resultsTableView.isHidden = true
        }
        
        enterGuessField.setShowsCancelButton(false, animated: true)
    }
}

extension EnterGuessViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

extension EnterGuessViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
}
