//
//  PersonDetailPresenter.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-11-20.
//

import Foundation
import UIKit

protocol PersonDetailPresenterProtocol: GuessDetailPresenterProtocol {
    func loadCredits()
    func loadKnownForTitleImage(index: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void)
    func loadActorInTitleImage(index: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void)
    func loadJobForTitleImage(index: Int, section: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void)
    func getKnownForCount() -> Int
    func getActorInCount() -> Int
    func getCountForJob(section: Int) -> Int
    func getKnownForTitle(for index: Int) -> Title?
    func getActorInTitle(for index: Int) -> Title?
    func getJobForTitle(for index: Int, section: Int) -> Title?
}

class PersonDetailPresenter: GuessDetailPresenter, PersonDetailPresenterProtocol {
    private var person: Person?
    
    private var personCredits: PersonCredits? {
        didSet {
            setPersonCrewToDisplay()
            
            DispatchQueue.main.async {
                self.detailViewDelegate?.reloadData()
            }
        }
    }
    private var personCrewToDisplay: [String:[MovieOrTVShow]] = [:]
    private func setPersonCrewToDisplay() {
        if let personCredits = personCredits {
            for projectAsCrew in personCredits.crew {
                for crewType in crewTypeForSection {
                    if projectAsCrew.personsJob == crewType {
                        if personCrewToDisplay[crewType] == nil {
                            personCrewToDisplay[crewType] = [projectAsCrew]
                        } else {
                            personCrewToDisplay[crewType]?.append(projectAsCrew)
                        }
                    }
                }
            }
        }
    }
    
    override init(networkManager: NetworkManager, imageDownloadManager: ImageDownloadManager, item: Entity) {
        person = item as? Person
        
        // if item came from a "Cast" or "Crew" section for movie, it will be type CastMember or CrewMember
        if let item = item as? CastMember {
            person = Person(castMember: item)
        }
        //if let item = item as? CrewMember {
        //    person = Person(crewMember: item)
        //}
        
        super.init(networkManager: networkManager, imageDownloadManager: imageDownloadManager, item: item)
    }
    
    func loadCredits() {
        networkManager.getCombinedCreditsForPerson(id: item.id) { [weak self] credits, error in
            if let error = error {
                print(error)
                DispatchQueue.main.async {
                    self?.detailViewDelegate?.displayError()
                }
                return
            }
            
            self?.personCredits = credits
        }
    }
    
    func loadKnownForTitleImage(index: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void) {
        guard let profilePath = person?.knownFor[index].posterPath else {
            completion(nil, nil)
            return
        }
        
        loadImage(path: profilePath, completion: completion)
    }
    
    func loadActorInTitleImage(index: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void) {
        guard let profilePath = personCredits?.cast[index].posterPath else {
            completion(nil, nil)
            return
        }
        
        loadImage(path: profilePath, completion: completion)
    }
    
    func loadJobForTitleImage(index: Int, section: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void) {
        guard section >= 0 && section < crewTypeForSection.count else {
            return
        }
        
        guard let personCrewOnTitles = personCredits?.crew else {
            return
        }
        
        var count = 0
        for personCrewOnTitle in personCrewOnTitles {
            if personCrewOnTitle.personsJob == crewTypeForSection[section] {
                if count == index {
                    if let profilePath = personCrewOnTitle.posterPath {
                        loadImage(path: profilePath, completion: completion)
                    }
                    
                    return
                }
                
                // keep adding to count until we get to selected index
                count += 1
            }
        }
    }
    
    func getKnownForCount() -> Int {
        return person?.knownFor.count ?? 0
    }
    
    func getActorInCount() -> Int {
        return personCredits?.cast.count ?? 0
    }
    
    func getCountForJob(section: Int) -> Int {
        guard section >= 0 && section < crewTypeForSection.count else {
            return 0
        }
        
        guard let personCrewOnTitles = personCredits?.crew else {
            return 0
        }
        
        var count = 0
        for personCrewOnTitle in personCrewOnTitles {
            if personCrewOnTitle.personsJob == crewTypeForSection[section] {
                count += 1
            }
        }
        
        return count
    }
    
    func getKnownForTitle(for index: Int) -> Title? {
        return person?.knownFor[index]
    }
    
    func getActorInTitle(for index: Int) -> Title? {
        return personCredits?.cast[index]
    }
    
    func getJobForTitle(for index: Int, section: Int) -> Title? {
        guard section >= 0 && section < crewTypeForSection.count else {
            return nil
        }
        
        guard let personCrewOnTitles = personCredits?.crew else {
            return nil
        }
        
        var count = 0
        for personCrewOnTitle in personCrewOnTitles {
            if personCrewOnTitle.personsJob == crewTypeForSection[section] {
                if count == index {
                    return personCrewOnTitle
                }
                
                // keep adding to count until we get to selected index
                count += 1
            }
        }
        
        return nil
    }
}
