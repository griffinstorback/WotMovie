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
            setCrewToDisplay()
            print(crewToDisplay)
            DispatchQueue.main.async {
                self.guessDetailViewDelegate?.reloadCreditsData()
            }
        }
    }
    
    private let crewTypeForSection: [Int:String] = [
            0: "Director",
            1: "Writer",
            2: "Producer"
        ]
    private var crewToDisplay: [String:[CrewMember]] = [:]
    private func setCrewToDisplay() {
        if let credits = credits {
            for crewMember in credits.crew {
                for crewType in crewTypeForSection.values {
                    if crewMember.job == crewType {
                        if crewToDisplay[crewType] == nil {
                            crewToDisplay[crewType] = [crewMember]
                        } else {
                            crewToDisplay[crewType]?.append(crewMember)
                        }
                    }
                }
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
        guard let posterPath = title.posterPath else {
            completion(nil)
            return
        }
        
        loadImage(path: posterPath, completion: completion)
    }
    
    func loadCastPersonImage(index: Int, completion: @escaping (_ image: UIImage?) -> Void) {
        guard let credits = credits, let profilePath = credits.cast[index].profilePath else {
            completion(nil)
            return
        }
        
        loadImage(path: profilePath, completion: completion)
    }
    
    func loadCrewPersonImage(index: Int, section: Int, completion: @escaping (_ image: UIImage?) -> Void) {
        guard let crewType = crewTypeForSection[section] else {
            completion(nil)
            return
        }
        
        guard let crewMember = crewToDisplay[crewType]?[index] else {
            completion(nil)
            return
        }
        
        guard let profilePath = crewMember.profilePath else {
            completion(nil)
            return
        }
        
        loadImage(path: profilePath, completion: completion)
    }
    
    func loadImage(path: String, completion: @escaping (_ image: UIImage?) -> Void) {
        imageDownloadManager.downloadImage(path: path) { image, error in
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
    
    func getCastCount() -> Int {
        return credits?.cast.count ?? 0
    }
    
    func getCastMember(for index: Int) -> CastMember? {
        return credits?.cast[index]
    }
    
    func getCrewTypesToDisplayCount() -> Int {
        return crewTypeForSection.count
    }
    
    func getCrewCountForType(section: Int) -> Int {
        guard let crewType = crewTypeForSection[section] else {
            return 0
        }
        
        return crewToDisplay[crewType]?.count ?? 0
    }
    
    func getCrewTypeToDisplay(for section: Int) -> String? {
        guard let crewType = crewTypeForSection[section] else {
            return nil
        }
        
        guard let crewTypeCount = crewToDisplay[crewType]?.count else {
            return nil
        }
        
        // if more than one crew of this type, return plural (e.g. "Director" or "Directors")
        if crewTypeCount <= 0 {
            return nil
        } else if crewTypeCount == 1 {
            return crewType
        } else {
            return "\(crewType)s"
        }
    }
    
    func getCrewMember(for index: Int, section: Int) -> CrewMember? {
        guard let crewType = crewTypeForSection[section] else {
            return nil
        }
        
        return crewToDisplay[crewType]?[index]
    }
}
