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
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
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
        
        // load first page of movies/tv shows
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
        guessDetailViewController.modalPresentationStyle = .pageSheet
        
        //navigationController?.pushViewController(guessDetailViewController, animated: true)
        present(guessDetailViewController, animated: true)
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
}

extension GuessGridViewController: UICollectionViewDataSource {
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        
        collectionView.register(GuessGridCollectionViewCell.self, forCellWithReuseIdentifier: "TitleCollectionViewCell")
        collectionView.register(GuessGridFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")
        
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if guessGridViewPresenter.titlesCount > 0 {
            return CGSize(width: collectionView.frame.width, height: 100)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer", for: indexPath) as! GuessGridFooterView
            
            return footerView
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            if let footerView = view as? GuessGridFooterView {
                if guessGridViewPresenter.titlesCount > 0 {
                    print("displaying loading animation")
                    footerView.startLoadingAnimation()
                    guessGridViewPresenter.loadTitles()
                } else {
                    print("nothing more to load?")
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            if let footerView = view as? GuessGridFooterView {
                print("removing loading animation")
                footerView.stopLoadingAnimation()
            }
        }
    }
}

extension GuessGridViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = collectionView.bounds.width
        return CGSize(width: screenWidth/3, height: (screenWidth/3)*1.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
