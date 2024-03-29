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
    func creditsHaveLoaded() -> Bool
    func loadCastPersonImage(index: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void)
    
    func getTypeString() -> String
    func getOverview() -> String
    func getOverviewCensored() -> String
    func getReleaseDate() -> String
    func getContentLength() -> String
    func getRating() -> Double?
    func getGenres(completion: @escaping (_ genres: String?) -> Void)
    
    func getCastCount() -> Int
    func getCastMember(for index: Int) -> CastMember?
    func getCharacterForCastMember(for index: Int) -> String?
    
    func getCrewTypeStringToDisplay(for section: CrewTypeSection) -> String?
    func getCrewMember(for index: Int, section: CrewTypeSection) -> CrewMember?
    func loadCrewMemberImageFor(index: Int, section: CrewTypeSection, completion: @escaping (UIImage?) -> Void)

    func getDirectors() -> [CrewMember]
    func getProducers() -> [CrewMember]
    func getWriters() -> [CrewMember]
}

// corresponds with property in super class GuessDetailPresenter - crewTypeForSection
enum CrewTypeSection: String, CaseIterable {
    case director = "Director"
    case writer = "Writer"
    case producer = "Producer"
}

class TitleDetailPresenter: GuessDetailPresenter, TitleDetailPresenterProtocol {
    private var movie: Movie?
    private var movieDetails: MovieDetails? {
        didSet {
            setCrewToDisplay(from: movieDetails?.credits)
            
            DispatchQueue.main.async {
                self.detailViewDelegate?.reloadData()
            }
        }
    }
    
    private var tvShow: TVShow?
    private var tvShowDetails: TVShowDetails? {
        didSet {
            setCrewToDisplay(from: tvShowDetails?.credits)
            
            DispatchQueue.main.async {
                self.detailViewDelegate?.reloadData()
            }
        }
    }
    
    /*private var credits: Details? {
        didSet {
            setCrewToDisplay()
            
            DispatchQueue.main.async {
                self.detailViewDelegate?.reloadData()
            }
        }
    }*/
    
    private var crewToDisplay: [String:[CrewMember]] = [:]
    private func setCrewToDisplay(from credits: Credits?) {
        if let credits = credits {
            for crewMember in credits.crew {
                for crewType in CrewTypeSection.allCases {
                    if crewMember.job == crewType.rawValue {
                        if crewToDisplay[crewType.rawValue] == nil {
                            crewToDisplay[crewType.rawValue] = [crewMember]
                        } else {
                            crewToDisplay[crewType.rawValue]?.append(crewMember)
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
    }
    
    func loadCredits() {
        // first try to get credits from core data ( NOT IMPLEMENTED )
        /*if let credits = getCreditsFromCoreData() {
            self.credits = credits
            return
        }*/
        
        // doesn't cache in core data right now - just gets from network
        getCreditsFromNetworkThenCacheInCoreData()
    }
    
    func creditsHaveLoaded() -> Bool {
        switch item.type {
        case .movie:
            return movieDetails?.credits != nil
        case .tvShow:
            return tvShowDetails?.credits != nil
        case .person:
            DispatchQueue.main.async {
                self.detailViewDelegate?.displayErrorLoadingCredits()
            }
            return false
        }
    }
    
    func loadCastPersonImage(index: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void) {
        let movieOrTVShowCredits: Credits?
        switch item.type {
        case .movie:
            movieOrTVShowCredits = movieDetails?.credits
        case .tvShow:
            movieOrTVShowCredits = tvShowDetails?.credits
        case .person:
            DispatchQueue.main.async {
                self.detailViewDelegate?.displayErrorLoadingCredits()
            }
            return
        }
        
        guard let credits = movieOrTVShowCredits, let profilePath = credits.cast[index].posterPath else {
            completion(nil, nil)
            return
        }
        
        loadImage(path: profilePath, completion: completion)
    }
    
    func getTypeString() -> String {
        switch item.type {
        case .movie:
            return "MOVIE"
        case .tvShow:
            return "TV SHOW"
        case .person:
            print("** WARNING: TitleDetailPresenter.getTypeString attempted but item.type was found to be .person")
            return ""
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
    
    func getReleaseDate() -> String {
        switch item.type {
        case .movie:
            return movie?.releaseDate ?? "-"
        case .tvShow:
            return tvShow?.releaseDate ?? "-"
        case .person:
            print("** ERROR - item type found to be .person while retrieving release date string (TitleDetailPresenter)")
            return "-"
        }
    }
    
    func getContentLength() -> String {
        switch item.type {
        case .movie:
            guard let runtime = movieDetails?.runtime else { return "" }
            return "\(runtime) mins"
        case .tvShow:
            guard let episodeCount = tvShowDetails?.numberOfEpisodes else { return "" }
            return "\(episodeCount) episodes"
        case .person:
            print("** ERROR - item type found to be .person while retrieving content length string (TitleDetailPresenter)")
            return ""
        }
    }
    
    func getRating() -> Double? {
        // guard will only fail when
        guard let title = item as? Title else {
            print("** ERROR - getting rating in TitleDetailPresenter, could not cast item as Title (it must be type .person)")
            return nil
        }
        
        // if the voteAverage is 0.0, just treat as nil (something about core data storing optional doubles, they don't return as nil even if not set)
        if let rating = title.voteAverage, rating > 0.0 {
            return rating
        } else {
            return nil
        }
    }
    
    func getCastCount() -> Int {
        switch item.type {
        case .movie:
            return movieDetails?.credits.cast.count ?? 0
        case .tvShow:
            return tvShowDetails?.credits.cast.count ?? 0
        case .person:
            DispatchQueue.main.async {
                self.detailViewDelegate?.displayErrorLoadingCredits()
            }
            return 0
        }
    }
    
    func getCastMember(for index: Int) -> CastMember? {
        switch item.type {
        case .movie:
            return movieDetails?.credits.cast[index]
        case .tvShow:
            return tvShowDetails?.credits.cast[index]
        case .person:
            DispatchQueue.main.async {
                self.detailViewDelegate?.displayErrorLoadingCredits()
            }
            return nil
        }
    }
    
    func getCharacterForCastMember(for index: Int) -> String? {
        switch item.type {
        case .movie:
            return movieDetails?.credits.cast[index].character
        case .tvShow:
            return tvShowDetails?.credits.cast[index].character
        case .person:
            DispatchQueue.main.async {
                self.detailViewDelegate?.displayErrorLoadingCredits()
            }
            return nil
        }
    }
    
    func getCrewTypeStringToDisplay(for section: CrewTypeSection) -> String? {
        let crewType = section.rawValue
        
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
    
    func getCrewMember(for index: Int, section: CrewTypeSection) -> CrewMember? {
        let crewType = section.rawValue
        
        // don't let index go out of range
        guard index < crewToDisplay[crewType]?.count ?? -1 else { return nil }
        return crewToDisplay[crewType]?[index]
    }
    
    // genres appear as comma separated list
    func getGenres(completion: @escaping (_ genres: String?) -> Void) {
        // first, try to load the genres from core data
        if let genresString = getGenresFromCoreData() {
            completion(genresString)
            return
        }
        
        getGenresFromNetworkThenCacheInCoreData(completion: completion)
    }
    
    func getDirectors() -> [CrewMember] {
        return crewToDisplay[CrewTypeSection.director.rawValue] ?? []
    }
    
    func getWriters() -> [CrewMember] {
        return crewToDisplay[CrewTypeSection.writer.rawValue] ?? []
    }
    
    func getProducers() -> [CrewMember] {
        return crewToDisplay[CrewTypeSection.producer.rawValue] ?? []
    }
    
    func loadCrewMemberImageFor(index: Int, section: CrewTypeSection, completion: @escaping (UIImage?) -> Void) {
        let crewType = section.rawValue
        
        // don't let go out of range
        guard index < crewToDisplay[crewType]?.count ?? -1 else {
            completion(nil)
            return
        }
        guard let crewMember = crewToDisplay[crewType]?[index] else {
            completion(nil)
            return
        }
        
        guard let profilePath = crewMember.posterPath else {
            completion(nil)
            return
        }
        
        loadImage(path: profilePath) { image, _ in
            completion(image)
        }
    }
    
    
    // MARK: - Private
    
    /*private func getCreditsFromCoreData() -> Credits? {
        //let credits = coreDataManager.getCreditsFor(type: item.type, id: item.id)
        //return credits
        return nil
    }*/
    
    // doesn't currently cache in core data.
    private func getCreditsFromNetworkThenCacheInCoreData() {
        switch item.type {
        case .movie:
            networkManager.getMovieDetailsAndCredits(id: item.id) { [weak self] details, error in
                if let error = error {
                    print(error)
                    DispatchQueue.main.async {
                        self?.detailViewDelegate?.displayErrorLoadingCredits()
                    }
                    return
                }
                
                self?.movieDetails = details
                
                // update the movie in core data if it was retrieved (method defined in super GuessDetailPresenter)
                self?.updateEntityInCoreData(details?.movie)
            }
        
        
        case .tvShow:
            networkManager.getTVShowDetailsAndCredits(id: item.id) { [weak self] details, error in
                if let error = error {
                    print(error)
                    DispatchQueue.main.async {
                        self?.detailViewDelegate?.displayErrorLoadingCredits()
                    }
                    return
                }
                
                self?.tvShowDetails = details
                
                // update the tv show in core data if it was retrieved (method defined in super GuessDetailPresenter)
                self?.updateEntityInCoreData(details?.tvShow)
            }
            
        case .person:
            DispatchQueue.main.async {
                self.detailViewDelegate?.displayErrorLoadingCredits()
            }
            return
        }
    }
    
    private func getGenresFromCoreData() -> String? {
        let genres = coreDataManager.fetchMovieGenres()
            
        // TODO: need to check if lastUpdated > 2 days (or whatever threshold), then update genres
        // either right now or on a background thread.
        
        // if empty list was returned, means there is no genres in core data
        if genres.count > 0 {
            return getGenresStringFor(genres: genres)
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
                        self.coreDataManager.updateOrCreateMovieGenreList(genres: genres)
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
