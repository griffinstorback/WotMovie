//
//  EnterGuessViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-28.
//

import UIKit

protocol EnterGuessViewDelegate: NSObjectProtocol {
    func reloadResults()
    func reloadGuesses()
    func reloadState()
    
    func searchStartedLoading()
}

class EnterGuessViewController: UIViewController {
    
    private let enterGuessPresenter: EnterGuessPresenterProtocol
    private weak var delegate: EnterGuessProtocol?
    
    private let enterGuessControlsView: EnterGuessControlsView
    private var enterGuessControlsViewBottomConstraint: NSLayoutConstraint!
    
    private let resultsTableView: UITableView
    
    private let placeholderLabelWhenNothingTyped: UILabel
    private let loadingIndicatorOrErrorView: LoadingIndicatorOrErrorView

    init(item: Entity, presenter: EnterGuessPresenterProtocol? = nil) {
        // use passed in presenter if provided (used in tests)
        enterGuessPresenter = presenter ?? EnterGuessPresenter(item: item)
        enterGuessControlsView = EnterGuessControlsView()
        
        resultsTableView = UITableView()
        
        placeholderLabelWhenNothingTyped = UILabel()
        loadingIndicatorOrErrorView = LoadingIndicatorOrErrorView(state: .loaded)
        
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
        
        enterGuessControlsView.setEnterGuessFieldPlaceholder(text: enterGuessPresenter.getPlaceholderText())
        enterGuessControlsView.setWatchlistButtonText(text: enterGuessPresenter.getWatchlistButtonText())
        enterGuessControlsView.setWatchlistButtonImage(imageName: enterGuessPresenter.getWatchlistImageName())
        
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
        
        // show (un hide) this label when nothing typed
        resultsTableView.addSubview(placeholderLabelWhenNothingTyped)
        placeholderLabelWhenNothingTyped.anchorToCenter(yAnchor: resultsTableView.centerYAnchor, xAnchor: nil)
        placeholderLabelWhenNothingTyped.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
        
        view.addSubview(loadingIndicatorOrErrorView)
        loadingIndicatorOrErrorView.anchorToCenter(yAnchor: resultsTableView.centerYAnchor, xAnchor: resultsTableView.centerXAnchor)
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
        enterGuessControlsView.setAnswerWasRevealed()
    }
    
    public func setNoNextButton() {
        enterGuessControlsView.setAnswerWasRevealed()
        enterGuessControlsView.removeNextButton()
    }
    
    public func updateItem(item: Entity) {
        enterGuessPresenter.setItem(item: item)
    }
    
    // Change constaint so it fits keyboard underneath search bar, but don't unhide the results table view (see searchBar didBeginEditing below)
    @objc func keyboardWillAppear(notification: Notification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame: NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = view.convert(keyboardRectangle, from: nil).origin.y
        
        let spacingBetweenKeyboardAndTextView: CGFloat = 0
        let constraintHeight = view.frame.height - view.safeAreaInsets.bottom - keyboardHeight + spacingBetweenKeyboardAndTextView
        
        enterGuessControlsViewBottomConstraint.constant = -constraintHeight
        UIView.animate(withDuration: 0.5,
            animations: {
                self.view.layoutIfNeeded()
            },
            completion: { [weak self] _ in
                print("done animation")
                self?.scrollToBottom(animated: true)
            }
        )
    }
    
    // Change constraint so it touches bottom of screen, but don't hide the results table view (see searchBar didEndEditing below)
    @objc func keyboardWillDisappear() {
        if enterGuessControlsViewBottomConstraint.constant != 0 {
            enterGuessControlsViewBottomConstraint.constant = 0
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }
}

extension EnterGuessViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        resultsTableView.isHidden = true
        resultsTableView.alpha = 0
        
        resultsTableView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        
        // TODO: give results tableview blurred background
        
        resultsTableView.separatorColor = .separator
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        
        // removes lines between cells when tableview empty
        resultsTableView.tableFooterView = UIView()
        resultsTableView.tableHeaderView = UIView()
        
        placeholderLabelWhenNothingTyped.text = "Start typing the name, and select the correct result"
        placeholderLabelWhenNothingTyped.textColor = .tertiaryLabel
        placeholderLabelWhenNothingTyped.textAlignment = .center
        placeholderLabelWhenNothingTyped.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        placeholderLabelWhenNothingTyped.numberOfLines = 0
        
        resultsTableView.register(EntityTableViewCell.self, forCellReuseIdentifier: "ResultsCell")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return EntityTableViewCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return enterGuessPresenter.searchResultsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultsCell") as! EntityTableViewCell
        
        // return empty cell, if item is empty (nil)
        guard let item = enterGuessPresenter.searchResult(for: indexPath.row) else { return cell }
        
        cell.setName(text: item.name)
        cell.setImagePath(imagePath: item.posterPath ?? "")
        enterGuessPresenter.loadImage(for: indexPath.row, completion: cell.setImage)
        cell.backgroundColor = .clear
        
        // need to set this here, because its set to .none in the cell's prepareForReuse (so that empty cells can't be tapped at all)
        cell.selectionStyle = .default
        
        // if this item already been guessed (cell was tapped), display 'X' on right, indicating not the answer (otherwise remove accessory view)
        let xIconImageView = UIImageView(image: UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .heavy))?.withRenderingMode(.alwaysTemplate))
        xIconImageView.tintColor = .systemRed
        cell.accessoryView = enterGuessPresenter.itemHasBeenGuessed(id: item.id) ? xIconImageView : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        enterGuessPresenter.cancelLoadImageRequestFor(indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // if nil is returned, it means this cell has no item in it (empty cell)
        guard let isCorrect = enterGuessPresenter.isCorrect(index: indexPath.row) else {
            tableView.deselectRow(at: indexPath, animated: false)
            return
        }
        
        // haptic- give light single tap for attempt
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        if isCorrect {
            // additional success haptic if correct
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            delegate?.revealAsCorrect()
            enterGuessControlsView.shouldResignFirstReponder()
        }
    }
}

extension EnterGuessViewController: EnterGuessControlsDelegate {
    func revealButtonPressed() {
        delegate?.revealAnswer()
    }
    
    func nextButtonPressed() {
        // haptic- give light single tap
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        delegate?.nextQuestion()
    }
    
    func addToWatchlistButtonPressed() {
        if enterGuessPresenter.addItemToWatchlist() {
            // give user success haptic (successfully added to watchlist)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // inform grid that this item was added to watchlist/favorites so contextual menu (hold down grid cell) reflects correct data
            delegate?.addToFavoritesOrWatchlist()
        } else {
            // haptic- give light single tap for removal from watchlist
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
            // inform grid that this item was removed from watchlist/favorites so contextual menu (hold down grid cell) reflects correct data
            delegate?.removeFromFavoritesOrWatchlist()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
        
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // This search delay is now done using Combine within the EnterGuessPresenter
        //NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performSearch), object: searchBar)
        //self.perform(#selector(performSearch(_:)), with: searchBar, afterDelay: 0.2)
        performSearch(searchBar)
        
        // if text is empty, or nil, add placeholder, otherwise hide it
        if searchBar.text?.isEmpty ?? true {
            placeholderLabelWhenNothingTyped.isHidden = false
        } else {
            placeholderLabelWhenNothingTyped.isHidden = true
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        resultsTableView.isHidden = false
        UIView.animate(withDuration: 0.5) {
            self.resultsTableView.alpha = 1
        }
        
        enterGuessControlsView.setShowsEnterGuessFieldCancelButton(true, animated: true)
        enterGuessControlsView.setShowsRevealButton(false, animated: true)
        delegate?.showResults(animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: 0.5) {
            self.resultsTableView.alpha = 0
        }
        
        enterGuessControlsView.setShowsEnterGuessFieldCancelButton(false, animated: true)
        enterGuessControlsView.setShowsRevealButton(true, animated: false) // for some reason, trying to animate this makes it not animate...
        delegate?.hideResults(animated: true)
    }
    
    @objc func performSearch(_ searchBar: UISearchBar) {
        enterGuessPresenter.setSearchText(searchBar.text)
        scrollToBottom()
    }
}

extension EnterGuessViewController: EnterGuessViewDelegate {
    func reloadResults() {
        reloadGuesses()
        reloadState()
        scrollToBottom()
    }
    
    // only reload the tableview. don't scroll to the bottom.
    func reloadGuesses() {
        resultsTableView.isHidden = false
        loadingIndicatorOrErrorView.state = .loaded
        resultsTableView.reloadData()
    }
    
    // only reload watch/favorite button state. (GuessDetailVC --updateItem--> thisVC --setItem--> thisPresenter --reloadState--> here)
    func reloadState() {
        enterGuessControlsView.setWatchlistButtonText(text: enterGuessPresenter.getWatchlistButtonText())
        enterGuessControlsView.setWatchlistButtonImage(imageName: enterGuessPresenter.getWatchlistImageName())
    }
    
    func searchStartedLoading() {
        resultsTableView.isHidden = true
        loadingIndicatorOrErrorView.state = .loading
        //removePlaceholderLabelBecauseResultsWereShown()
    }
    
    // scroll to bottom when new results will be shown (because most relevant items start from bottom)
    func scrollToBottom(animated: Bool = false) {
        if enterGuessPresenter.searchResultsCount > 0 && !resultsTableView.isHidden {
            let lastRow = IndexPath(row: enterGuessPresenter.searchResultsCount-1, section: 0)
            resultsTableView.scrollToRow(at: lastRow, at: .bottom, animated: animated)
        }
    }
}
