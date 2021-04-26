//
//  HorizontalCollectionViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-23.
//

import UIKit

protocol HorizontalCollectionViewDelegate: NSObjectProtocol {
    func getNumberOfItems(_ horizontalCollectionViewController: HorizontalCollectionViewController) -> Int
    func getItemFor(_ horizontalCollectionViewController: HorizontalCollectionViewController, index: Int) -> Entity?
    func getSubtitleFor(_ horizontalCollectionViewController: HorizontalCollectionViewController, index: Int) -> String?
    
    func loadImageFor(_ horizontalCollectionViewController: HorizontalCollectionViewController, index: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void)
    func cancelLoadImageRequestFor(imagePath: String)
}

enum HorizontalCollectionViewState {
    case namesHidden
    case namesShownButItemIsStillHidden // this is the case for person detail views, which display names of movies, yet these movies still shouldn't be opened yet.
    case itemIsRevealedOrGuessed
}

class HorizontalCollectionViewController: DetailPresenterViewController {

    // is hidden to start by default - reload when changed
    var state: HorizontalCollectionViewState {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private weak var delegate: HorizontalCollectionViewDelegate?
    
    private var titleLabel: UILabel?
    private var collectionView: UICollectionView
    
    init(title: String?, state: HorizontalCollectionViewState = .namesHidden) {
        self.state = state
        
        if let title = title {
            titleLabel = UILabel()
            titleLabel?.text = title
        }
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionView.createHorizontalLayout())
        
        super.init(nibName: nil, bundle: nil)
        
        setupViews()
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        collectionView.delaysContentTouches = false
        
        if titleLabel != nil {
            titleLabel?.font = Constants.Fonts.detailViewSectionHeader
        }
        
        setupCollectionView()
    }
    
    private func layoutViews() {
        view.addSubview(collectionView)
        
        // if a title was provided, position it above the collection view.
        if titleLabel != nil {
            view.addSubview(titleLabel!)
            titleLabel?.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 10, bottom: 5, right: 0))
            
            collectionView.anchor(top: titleLabel?.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, size: CGSize(width: 0, height: 250))
        } else {
            collectionView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        }
    }
    
    public func setDelegate(_ delegate: HorizontalCollectionViewDelegate) {
        self.delegate = delegate
        collectionView.reloadData()
    }
    
    public func reloadData() {
        collectionView.reloadData()
        view.layoutIfNeeded()
    }
}

extension HorizontalCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        
        collectionView.register(HorizontalCollectionViewCell.self, forCellWithReuseIdentifier: "HorizontalCollectionViewCell")
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numberOfItems = delegate?.getNumberOfItems(self) ?? 0
        
        // hide this whole view if there are no items to display
        if numberOfItems == 0 {
            view.isHidden = true
        } else {
            view.isHidden = false
        }
        
        return numberOfItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HorizontalCollectionViewCell", for: indexPath) as! HorizontalCollectionViewCell
        guard let item = delegate?.getItemFor(self, index: indexPath.row) else {
            print("ERROR: could not find item for index \(indexPath.row) in horizontal collection view.")
            return cell
        }
        
        switch state {
        case .namesHidden:
            cell.setNameHidden()
        case .namesShownButItemIsStillHidden:
            cell.setName(item.name)
        case .itemIsRevealedOrGuessed:
            cell.setName(item.name)
        }
        
        // set the subtitle if one exists for this item (and if state isn't hidden)
        if let subtitle = delegate?.getSubtitleFor(self, index: indexPath.row), state != .namesHidden {
            cell.setSubtitle(subtitle)
        }
        
        if let imagePath = item.posterPath {
            cell.setImagePath(path: imagePath)
        }
        
        delegate?.loadImageFor(self, index: indexPath.row, completion: cell.setImage)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? HorizontalCollectionViewCell else {
            print("** ERROR: could not cast cell as HorizontalCollectionViewCell in didEndDisplaying")
            return
        }
        
        let imagePath = cell.getImagePath()
        guard !imagePath.isEmpty else { return } // if there is no image path set there's nothing to cancel
        
        delegate?.cancelLoadImageRequestFor(imagePath: imagePath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! HorizontalCollectionViewCell
        guard let item = delegate?.getItemFor(self, index: indexPath.row) else {
            return
        }
        
        // if the item user is guessing on hasn't been revealed (i.e its in .hintShown state), don't allow modals to be presented yet.
        guard state == .itemIsRevealedOrGuessed else {
            BriefAlertView(title: "Guess or Reveal first").present()
            return
        }
        
        let guessDetailViewController: GuessDetailViewController
        
        switch item.type {
        case .movie, .tvShow:
            guessDetailViewController = TitleDetailViewController(item: item, state: .revealedWithNoNextButton)
        case .person:
            guessDetailViewController = PersonDetailViewController(item: item, state: .revealedWithNoNextButton)
        }
        
        // Presenter nil because no entity presented from this VC will start hidden, therefore will never need
        // to update posterimage hidden status.
        present(guessDetailViewController, fromCard: cell.imageView, startHidden: false, transitionPresenter: nil)
    }
}
