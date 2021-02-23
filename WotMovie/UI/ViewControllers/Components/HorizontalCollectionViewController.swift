//
//  HorizontalCollectionViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-23.
//

import UIKit

protocol HorizontalCollectionViewDelegate {
    func getNumberOfItems(_ horizontalCollectionViewController: HorizontalCollectionViewController) -> Int
    func getItemFor(_ horizontalCollectionViewController: HorizontalCollectionViewController, index: Int) -> Entity?
    func getSubtitleFor(_ horizontalCollectionViewController: HorizontalCollectionViewController, index: Int) -> String?
    func loadImageFor(_ horizontalCollectionViewController: HorizontalCollectionViewController, index: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void)
}

class HorizontalCollectionViewController: DetailPresenterViewController {

    private var delegate: HorizontalCollectionViewDelegate?
    
    private var titleLabel: UILabel?
    private var collectionView: UICollectionView!
    
    init(title: String?) {
        if let title = title {
            titleLabel = UILabel()
            titleLabel?.text = title
        }
        
        super.init(nibName: nil, bundle: nil)
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(100), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 5
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .horizontal
        
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: config)
        return layout
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    private func setupViews() {
        collectionView.delaysContentTouches = false
        
        if titleLabel != nil {
            titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        }
        
        setupCollectionView()
        layoutViews()
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
        
        cell.setName(item.name)
        
        // set the subtitle if one exists for this item
        if let subtitle = delegate?.getSubtitleFor(self, index: indexPath.row) {
            cell.setSubtitle(subtitle)
        }
        
        if let imagePath = item.posterPath {
            cell.setImagePath(path: imagePath)
        }
        
        delegate?.loadImageFor(self, index: indexPath.row, completion: cell.setImage)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! HorizontalCollectionViewCell
        guard let item = delegate?.getItemFor(self, index: indexPath.row) else {
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
