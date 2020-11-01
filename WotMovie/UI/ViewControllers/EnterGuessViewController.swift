//
//  EnterGuessViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-28.
//

import UIKit

protocol EnterGuessProtocol {
    func showResults()
    func hideResults()
    func revealAnswer()
    func nextQuestion()
    func checkAnswer(id: Int) -> Bool
}

class EnterGuessViewController: UIViewController {
    
    private let enterGuessPresenter: EnterGuessPresenter
    private var delegate: EnterGuessProtocol?
    
    private let enterGuessControlsView: EnterGuessControlsView
    private var enterGuessControlsViewBottomConstraint: NSLayoutConstraint!
    
    private let resultsTableView: UITableView!

    init() {
        enterGuessPresenter = EnterGuessPresenter(networkManager: NetworkManager.shared, imageDownloadManager: ImageDownloadManager.shared)
        enterGuessControlsView = EnterGuessControlsView()
        
        resultsTableView = UITableView()
        
        super.init(nibName: nil, bundle: nil)
        
        enterGuessControlsView.setDelegate(self)
        enterGuessPresenter.setViewDelegate(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        // let touches through to the presenting view
        view = TouchDelegatingView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        enterGuessControlsView.setEnterGuessFieldPlaceholder(text: "Enter movie name")
        
        setupTableView()
        
        layoutSubviews()
    }
    
    private func layoutSubviews() {
        view.addSubview(enterGuessControlsView)
        enterGuessControlsViewBottomConstraint = enterGuessControlsView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        enterGuessControlsViewBottomConstraint.isActive = true
        enterGuessControlsView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor)
        
        view.addSubview(resultsTableView)
        resultsTableView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: enterGuessControlsView.topAnchor, trailing: view.trailingAnchor)
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
    
    public func setDelegate(_ delegate: EnterGuessProtocol) {
        self.delegate = delegate
    }
    
    public func setAnswerRevealed() {
        print("uh huh")
        enterGuessControlsView.setAnswerWasRevealed()
    }
    
    @objc func keyboardWillAppear(notification: Notification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame: NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = view.convert(keyboardRectangle, from: nil).origin.y
        
        let spacingBetweenKeyboardAndTextView: CGFloat = 0
        let constraintHeight = view.frame.height - view.safeAreaInsets.bottom - keyboardHeight + spacingBetweenKeyboardAndTextView
        
        enterGuessControlsViewBottomConstraint.constant = -constraintHeight
        resultsTableView.isHidden = false
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
            self.resultsTableView.alpha = 1
        }
        
        enterGuessControlsView.setShowsEnterGuessFieldCancelButton(true, animated: true)
        enterGuessControlsView.setShowsRevealButton(false, animated: true)
        delegate?.showResults()
    }
    
    @objc func keyboardWillDisappear() {
        enterGuessControlsViewBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
            self.resultsTableView.alpha = 0
        } completion: { _ in
            self.resultsTableView.isHidden = true
        }
        
        enterGuessControlsView.setShowsEnterGuessFieldCancelButton(false, animated: true)
        enterGuessControlsView.setShowsRevealButton(true, animated: true)
        delegate?.hideResults()
    }
}

extension EnterGuessViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        resultsTableView.isHidden = true
        resultsTableView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        // TODO: give results tableview blurred background
        
        resultsTableView.separatorColor = .white
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        resultsTableView.alpha = 0
        
        // removes lines between cells when tableview empty
        resultsTableView.tableFooterView = UIView()
        
        resultsTableView.register(PersonTableViewCell.self, forCellReuseIdentifier: "ResultsCell")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PersonTableViewCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return enterGuessPresenter.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultsCell") as! PersonTableViewCell
        
        let movie = enterGuessPresenter.searchResults[indexPath.row]
        
        cell.setName(text: movie.title)
        enterGuessPresenter.loadImage(path: movie.posterPath ?? "", completion: cell.setImage)
        cell.backgroundColor = .clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = enterGuessPresenter.searchResults[indexPath.row]
        
        guard let correct = delegate?.checkAnswer(id: movie.id) else {
            return
        }
        
        if correct {
            revealButtonPressed()
            enterGuessControlsView.shouldResignFirstReponder()
            print("Correct!")
        } else {
            print("Wrong.")
        }
    }
}

extension EnterGuessViewController: EnterGuessControlsDelegate {
    func revealButtonPressed() {
        delegate?.revealAnswer()
    }
    
    func nextButtonPressed() {
        delegate?.nextQuestion()
    }
    
    func addToWatchlistButtonPressed() {
        print("add to watchlist!")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
        
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performSearch), object: searchBar)
        self.perform(#selector(performSearch(_:)), with: searchBar, afterDelay: 0.5)
    }
    
    @objc func performSearch(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, query.trimmingCharacters(in: .whitespaces) != "" else {
            return
        }
        
        enterGuessPresenter.search(searchText: query)
    }
}

extension EnterGuessViewController: EnterGuessViewDelegate {
    func reloadResults() {
        resultsTableView.reloadData()
    }
}
