//
//  GuessDetailPresenter.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-18.
//

import Foundation
import UIKit

protocol GuessDetailViewDelegate: NSObjectProtocol {
    func displayError()
    func reloadData()
}

class GuessDetailPresenter {
    private let networkManager: NetworkManager
    private let imageDownloadManager: ImageDownloadManager
    weak private var guessDetailViewDelegate: GuessDetailViewDelegate?
    
    private let item: Entity
    private let movie: Movie?
    private let tvShow: TVShow?
    private let person: Person?
    
    private var credits: Credits? {
        didSet {
            setCrewToDisplay()
            
            DispatchQueue.main.async {
                self.guessDetailViewDelegate?.reloadData()
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
    
    init(networkManager: NetworkManager, imageDownloadManager: ImageDownloadManager, item: Entity) {
        self.networkManager = networkManager
        self.imageDownloadManager = imageDownloadManager
        self.item = item
        
        movie = item as? Movie
        tvShow = item as? TVShow
        person = item as? Person
    }
    
    func setViewDelegate(guessDetailViewDelegate: GuessDetailViewDelegate?) {
        self.guessDetailViewDelegate = guessDetailViewDelegate
    }
    
    func loadPosterImage(completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void) {
        guard let posterPath = item.posterPath else {
            completion(nil, nil)
            return
        }
        
        loadImage(path: posterPath, completion: completion)
    }
    
    func loadImage(path: String, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void) {
        imageDownloadManager.downloadImage(path: path) { image, error in
            if let error = error {
                print(error)
                DispatchQueue.main.async {
                    completion(nil, nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(image, path)
            }
        }
    }
    
    func getID() -> Int {
        switch item.type {
        case .movie:
            return movie?.id ?? -1
        case .tvShow:
            return tvShow?.id ?? -1
        case .person:
            return person?.id ?? -1
        }
    }
    
    func getTitle() -> String {
        switch item.type {
        case .movie:
            return movie?.name ?? "Error retrieving title"
        case .tvShow:
            return tvShow?.name ?? "Error retrieving title"
        case .person:
            return person?.name ?? "Error retrieving name"
        }
    }
}



// MARK: - Movie/TVShow methods

extension GuessDetailPresenter {
    func loadCastPersonImage(index: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void) {
        guard let credits = credits, let profilePath = credits.cast[index].posterPath else {
            completion(nil, nil)
            return
        }
        
        loadImage(path: profilePath, completion: completion)
    }
    
    func loadCrewPersonImage(index: Int, section: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void) {
        guard let crewType = crewTypeForSection[section] else {
            completion(nil, nil)
            return
        }
        
        guard let crewMember = crewToDisplay[crewType]?[index] else {
            completion(nil, nil)
            return
        }
        
        guard let profilePath = crewMember.posterPath else {
            completion(nil, nil)
            return
        }
        
        loadImage(path: profilePath, completion: completion)
    }
    
    func loadCredits() {
        switch item.type {
        case .movie:
            networkManager.getCreditsForMovie(id: item.id) { [weak self] credits, error in
                if let error = error {
                    print(error)
                    DispatchQueue.main.async {
                        self?.guessDetailViewDelegate?.displayError()
                    }
                    return
                }
                
                self?.credits = credits
            }
        
        
        case .tvShow:
            networkManager.getCreditsForTVShow(id: item.id) { [weak self] credits, error in
                if let error = error {
                    print(error)
                    DispatchQueue.main.async {
                        self?.guessDetailViewDelegate?.displayError()
                    }
                    return
                }
                
                self?.credits = credits
            }
            
        case .person:
            DispatchQueue.main.async {
                self.guessDetailViewDelegate?.displayError()
            }
        }
    }
    
    func getOverview() -> String {
        switch item.type {
        case .movie:
            return movie?.overview ?? "Error retrieving overview"
        case .tvShow:
            return tvShow?.overview ?? "Error retrieving overview"
        case .person:
            return "Error - no overview for type .person"
        }
    }
    
    // censor the title from the overview, so that it doesn't give it away
    // (i.e. "The matrix tells the story of..." becomes "********** tells the story of...")
    func getOverviewCensored() -> String {
        switch item.type {
        case .movie:
            guard let title = movie?.name, let overview = movie?.overview else {
                return "Error retrieving overview"
            }
            return getOverviewWithTitleCensored(title: title, overview: overview)
        case .tvShow:
            guard let title = tvShow?.name, let overview = tvShow?.overview else {
                return "Error retrieving overview"
            }
            return getOverviewWithTitleCensored(title: title, overview: overview)
        case .person:
            return "Error - no overview (censored) for type .person"
        }
    }
    
    private func getOverviewWithTitleCensored(title: String, overview: String) -> String {
        return overview.replacingOccurrences(of: title, with: String(repeating: "?", count: title.count))
    }
    
    func getReleaseDate() -> String {
        switch item.type {
        case .movie:
            return movie?.releaseDate ?? "-"
        case .tvShow:
            return tvShow?.releaseDate ?? "-"
        case .person:
            return "Error - no release date for type .person"
        }
    }
    
    // genres appear as comma separated list
    func getGenres(completion: @escaping (_ genres: String?) -> Void) {
        switch item.type {
        case .movie:
            networkManager.getMovieGenres { genres, error in
                if let error = error {
                    print(error)
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                
                if let genres = genres {
                    DispatchQueue.main.async {
                        completion(self.getGenresStringFor(genres: genres))
                    }
                }
            }
        
        
        case .tvShow:
            networkManager.getTVShowGenres { genres, error in
                if let error = error {
                    print(error)
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                
                if let genres = genres {
                    DispatchQueue.main.async {
                        completion(self.getGenresStringFor(genres: genres))
                    }
                }
            }
        
        case .person:
            DispatchQueue.main.async {
                completion("Error - no genres for type .person")
            }
        }
    }
    private func getGenresStringFor(genres: [Genre]) -> String {
        guard item.type == .movie || item.type == .tvShow else {
            return "Error - can't get genre string for type .person"
        }
        
        let title: Title
        if item.type == .movie {
            if let movie = movie {
                title = movie
            } else {
                return "Error - no movie found to get genres for"
            }
        } else {
            if let tvShow = tvShow {
                title = tvShow
            } else {
                return "Error - no tv show found to get genres for"
            }
        }
        
        let titleGenres = genres.filter { title.genreIDs.contains($0.id) }
        let titleGenresStringList = titleGenres.map { $0.name }
        let titleGenresString = titleGenresStringList.joined(separator: ", ")
        return titleGenresString
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



// MARK: - Person methods

extension GuessDetailPresenter {
    func loadKnownForTitleImage(index: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void) {
        guard let profilePath = person?.knownFor[index].posterPath else {
            completion(nil, nil)
            return
        }
        
        loadImage(path: profilePath, completion: completion)
    }
    
    func getKnownForCount() -> Int {
        return person?.knownFor.count ?? 0
    }
    
    func getKnownForTitle(for index: Int) -> Title? {
        return person?.knownFor[index]
    }
}
