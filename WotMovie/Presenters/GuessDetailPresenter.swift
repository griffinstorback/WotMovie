//
//  GuessDetailPresenter.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-18.
//

import Foundation
import UIKit

protocol GuessDetailViewDelegate: NSObjectProtocol {
    func displayErrorLoadingDetail()
    func reloadCreditsData()
}

class GuessDetailPresenter {
    private let networkManager: NetworkManager
    private let imageDownloadManager: ImageDownloadManager
    weak private var guessDetailViewDelegate: GuessDetailViewDelegate?
    
    private let title: Title
    private let movie: Movie?
    private let tvShow: TVShow?
    private var credits: Credits? {
        didSet {
            DispatchQueue.main.async {
                self.guessDetailViewDelegate?.reloadCreditsData()
            }
        }
    }
    
    init(networkManager: NetworkManager, imageDownloadManager: ImageDownloadManager, title: Title) {
        self.networkManager = networkManager
        self.imageDownloadManager = imageDownloadManager
        self.title = title
        
        if title is Movie {
            movie = title as? Movie
            tvShow = nil
        } else if title is TVShow {
            movie = nil
            tvShow = title as? TVShow
        } else {
            // display error
            movie = nil
            tvShow = nil
        }
    }
    
    func setViewDelegate(guessDetailViewDelegate: GuessDetailViewDelegate?) {
        self.guessDetailViewDelegate = guessDetailViewDelegate
    }
    
    func loadPosterImage(completion: @escaping (_ image: UIImage?) -> Void) {
        imageDownloadManager.downloadImage(path: title.posterPath ?? "") { image, error in
            if let error = error {
                print(error)
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    func getOverview() -> String {
        if let movie = movie {
            return movie.overview
        }
        
        if let tvShow = tvShow {
            return tvShow.overview
        }
        
        return "Error retrieving overview"
    }
    
    func getTitle() -> String {
        if let movie = movie {
            return movie.title
        }
        
        if let tvShow = tvShow {
            return tvShow.title
        }
        
        return "Error retrieving title"
    }
    
    func loadCredits() {
        if movie != nil {
            networkManager.getCreditsForMovie(id: title.id) { [weak self] credits, error in
                if let error = error {
                    print(error)
                    DispatchQueue.main.async {
                        self?.guessDetailViewDelegate?.displayErrorLoadingDetail()
                    }
                    return
                }
                
                self?.credits = credits
            }
        }
        
        if tvShow != nil {
            networkManager.getCreditsForTVShow(id: title.id) { [weak self] credits, error in
                if let error = error {
                    print(error)
                    DispatchQueue.main.async {
                        self?.guessDetailViewDelegate?.displayErrorLoadingDetail()
                    }
                    return
                }
                
                self?.credits = credits
            }
        }
    }
    
    func getCastCount() -> Int {
        return credits?.cast.count ?? 0
    }
    
    func getCrewCount() -> Int {
        return credits?.crew.count ?? 0
    }
    
    func getCastMember(for index: Int) -> CastMember? {
        return credits?.cast[index]
    }
    
    func getCrewMember(for index: Int) -> CrewMember? {
        return credits?.crew[index]
    }
}
