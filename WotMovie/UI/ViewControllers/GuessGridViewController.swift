//
//  GuessGridViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-13.
//

import UIKit

class GuessGridViewController: UIViewController {

    private let guessGridViewPresenter: GuessGridPresenter
    
    private var collectionView: UICollectionView!
    
    init(for genre: Genre) {
        guessGridViewPresenter = GuessGridPresenter(networkManager: NetworkManager.shared, imageDownloadManager: ImageDownloadManager.shared, genre: genre)
        
        super.init(nibName: nil, bundle: nil)
        
        navigationItem.largeTitleDisplayMode = .never
        title = genre.name
        
        guessGridViewPresenter.setViewDelegate(guessGridViewDelegate: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        
        guessGridViewPresenter.loadTitles()
    }
}

extension GuessGridViewController: GuessGridViewDelegate {
    func displayTitles() {
        print("displayTitles")
    }
    
    func displayErrorLoadingTitles() {
        print("displayErrorLoadingTitles")
    }
    
    func presentGuessTitleDetail(for title: Title) {
        let guessDetailViewController = GuessDetailViewController(title: title)
        guessDetailViewController.modalPresentationStyle = .formSheet
        
        //navigationController?.pushViewController(guessDetailViewController, animated: true)
        present(guessDetailViewController, animated: true)
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
}

extension GuessGridViewController: UICollectionViewDataSource {
    func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        
        collectionView.register(GuessGridCollectionViewCell.self, forCellWithReuseIdentifier: "TitleCollectionViewCell")
        
        view.addSubview(collectionView)
        
        collectionView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return guessGridViewPresenter.titlesCount
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TitleCollectionViewCell", for: indexPath) as! GuessGridCollectionViewCell
        guessGridViewPresenter.loadImageFor(index: indexPath.row, completion: cell.imageDataReceived)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guessGridViewPresenter.showGuessDetail(index: indexPath.row)
    }
}

extension GuessGridViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width/3, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
