//
//  TitleDetailPresenter.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-11-20.
//

import Foundation
import UIKit

protocol TitleDetailPresenterProtocol: GuessDetailPresenterProtocol {
    func loadCredits()
    func loadCastPersonImage(index: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void)
    func loadCrewPersonImage(index: Int, section: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void)
    func getOverview() -> String
    func getOverviewCensored() -> String
    func getReleaseDate() -> String
    func getGenres(completion: @escaping (_ genres: String?) -> Void)
    func getCastCount() -> Int
    func getCastMember(for index: Int) -> CastMember?
    func getCharacterForCastMember(for index: Int) -> String?
    func getCrewTypesToDisplayCount() -> Int
    func getCrewCountForType(section: Int) -> Int
    func getCrewTypeToDisplay(for section: Int) -> String?
    func getCrewMember(for index: Int, section: Int) -> CrewMember?
}

class TitleDetailPresenter: GuessDetailPresenter, TitleDetailPresenterProtocol {
    private var movie: Movie?
    private var tvShow: TVShow?
    
    private var credits: Credits? {
        didSet {
            setCrewToDisplay()
            
            DispatchQueue.main.async {
                self.detailViewDelegate?.reloadData()
            }
        }
    }
    
    private var crewToDisplay: [String:[CrewMember]] = [:]
    private func setCrewToDisplay() {
        if let credits = credits {
            for crewMember in credits.crew {
                for crewType in crewTypeForSection {
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
    
    override init(networkManager: NetworkManagerProtocol = NetworkManager.shared,
            imageDownloadManager: ImageDownloadManagerProtocol = ImageDownloadManager.shared,
            coreDataManager: CoreDataManager = CoreDataManager.shared,
            item: Entity) {
        movie = item as? Movie
        tvShow = item as? TVShow
        
        // if item came from a "Known for" section for person, it will be type MovieOrTVShow
        if let item = item as? MovieOrTVShow {
            if item.type == .movie {
                movie = Movie(movieOrTVShow: item)
            } else if item.type == .tvShow {
                tvShow = TVShow(movieOrTVShow: item)
            }
        }
                
        super.init(networkManager: networkManager, imageDownloadManager: imageDownloadManager, coreDataManager: coreDataManager, item: item)
        
        
        // read this movie from core data
        let returned = coreDataManager.fetchMovie(id: item.id)
        if returned[0].isHintShown {
            hintWasShown()
        }
        if returned[0].isRevealed {
            answerWasRevealed()
        }
    }
    
    func loadCredits() {
        // first try to get credits from core data
        if let credits = getCreditsFromCoreData() {
            self.credits = credits
            return
        }
        
        getCreditsFromNetworkThenCacheInCoreData()
    }
    
    func loadCastPersonImage(index: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void) {
        guard let credits = credits, let profilePath = credits.cast[index].posterPath else {
            completion(nil, nil)
            return
        }
        
        loadImage(path: profilePath, completion: completion)
    }
    
    func loadCrewPersonImage(index: Int, section: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void) {
        let crewType = crewTypeForSection[section]
        
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
    
    func getCastCount() -> Int {
        return credits?.cast.count ?? 0
    }
    
    func getCastMember(for index: Int) -> CastMember? {
        return credits?.cast[index]
    }
    
    func getCharacterForCastMember(for index: Int) -> String? {
        return credits?.cast[index].character
    }
    
    func getCrewTypesToDisplayCount() -> Int {
        return crewTypeForSection.count
    }
    
    func getCrewCountForType(section: Int) -> Int {
        let crewType = crewTypeForSection[section]
        
        return crewToDisplay[crewType]?.count ?? 0
    }
    
    func getCrewTypeToDisplay(for section: Int) -> String? {
        let crewType = crewTypeForSection[section]
        
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
        let crewType = crewTypeForSection[section]
        
        return crewToDisplay[crewType]?[index]
    }
    
    // genres appear as comma separated list
    func getGenres(completion: @escaping (_ genres: String?) -> Void) {
        // first, try to load the genres from core data
        if let genresString = getGenresFromCoreData() {
            print("*** Got genres from core data, string: \(genresString)")
            completion(genresString)
            return
        }
        
        print("*** No genres found in core data, fetching from network")
        getGenresFromNetworkThenCacheInCoreData(completion: completion)
    }
    
    
    // MARK: - Private
    
    private func getCreditsFromCoreData() -> Credits? {
        let credits = coreDataManager.getCreditsFor(type: item.type, id: item.id)
        return credits
    }
    
    private func getCreditsFromNetworkThenCacheInCoreData() {
        switch item.type {
        case .movie:
            networkManager.getCreditsForMovie(id: item.id) { [weak self] credits, error in
                if let error = error {
                    print(error)
                    DispatchQueue.main.async {
                        self?.detailViewDelegate?.displayError()
                    }
                    return
                }
                
                if let credits = credits {
                    if let strongSelf = self {
                        DispatchQueue.main.async {
                            //self?
                            //strongSelf.coreDataManager.updateOrCreateCredits(type: strongSelf.item.type, credits: credits)
                        }
                    }
                    
                    
                    self?.credits = credits
                }
            }
        
        
        case .tvShow:
            networkManager.getCreditsForTVShow(id: item.id) { [weak self] credits, error in
                if let error = error {
                    print(error)
                    DispatchQueue.main.async {
                        self?.detailViewDelegate?.displayError()
                    }
                    return
                }
                
                self?.credits = credits
            }
            
        case .person:
            DispatchQueue.main.async {
                self.detailViewDelegate?.displayError()
            }
            return
        }
    }
    
    private func getGenresFromCoreData() -> String? {
        let genres = coreDataManager.fetchGenres()
            
        // TODO: need to check if lastUpdated > 2 days (or whatever threshold), then update genres
        // either right now or on a background thread.
        
        // if empty list was returned, means there is no genres in core data
        if genres.count > 0 {
            return getGenresStringFor(genres: genres)
        } else {
            print("** got no genres from core data")
        }
        
        return nil
    }
    
    private func getGenresFromNetworkThenCacheInCoreData(completion: @escaping (_ genres: String?) -> Void) {
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
                        self.coreDataManager.updateOrCreateGenreList(genres: genres)
                    }
                    
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
    
    private func getOverviewWithTitleCensored(title: String, overview: String) -> String {
        return overview.replacingOccurrences(of: title, with: String(repeating: "?", count: title.count))
    }
}
