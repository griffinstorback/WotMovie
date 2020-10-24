//
//  HorizontalCollectionViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-23.
//

import UIKit

protocol HorizontalCollectionViewDelegate {
    func getNumberOfItems() -> Int
    func getNameForPersonAt(index: Int) -> String
    func loadImageFor(index: Int, completion: @escaping (_ image: UIImage?) -> Void)
}

class HorizontalCollectionViewController: UIViewController {

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
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0/3.5), heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        
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
            titleLabel?.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor)
            
            collectionView.anchor(top: titleLabel?.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, size: CGSize(width: 0, height: 100))
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

extension HorizontalCollectionViewController: UICollectionViewDataSource {
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        
        collectionView.register(HorizontalCollectionViewCell.self, forCellWithReuseIdentifier: "HorizontalCollectionViewCell")
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate?.getNumberOfItems() ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HorizontalCollectionViewCell", for: indexPath) as! HorizontalCollectionViewCell
        
        if let name = delegate?.getNameForPersonAt(index: indexPath.row) {
            cell.setName(name)
        }
        
        delegate?.loadImageFor(index: indexPath.row, completion: cell.setImage)
    
        return cell
    }
}
