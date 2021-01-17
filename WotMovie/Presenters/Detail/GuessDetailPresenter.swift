//
//  GuessDetailPresenter.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-18.
//

import Foundation
import UIKit


// MARK: - Base class. implemented by TitleDetailPresenter and PersonDetailPresenter.


protocol GuessDetailPresenterProtocol {
    func loadPosterImage(completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void)
    func loadCrewTypes()
    func getID() -> Int
    func getTitle() -> String // should rename getName()?
}

class GuessDetailPresenter: GuessDetailPresenterProtocol {
    let networkManager: NetworkManager
    let imageDownloadManager: ImageDownloadManager
    let coreDataManager: CoreDataManager
    weak var detailViewDelegate: GuessDetailViewDelegate?
    
    let item: Entity
    
    var crewTypes: [Department] = [] {
        didSet {
            print(crewTypes)
        }
    }
    let crewTypeForSection: [String] = [
        "Director",
        "Writer",
        "Producer"
    ]
    
    init(networkManager: NetworkManager = .shared, imageDownloadManager: ImageDownloadManager = .shared, coreDataManager: CoreDataManager = .shared, item: Entity) {
        self.networkManager = networkManager
        self.imageDownloadManager = imageDownloadManager
        self.coreDataManager = coreDataManager
        self.item = item
        
        //loadCrewTypes()
        
        // LOG THIS ENTITY as OPENED (mainly to update date, aka last seen date) in CORE DATA
        coreDataManager.setEntityAsSeen(entity: item)
        coreDataManager.readMovie(id: item.id)
    }
    
    func setViewDelegate(detailViewDelegate: GuessDetailViewDelegate?) {
        self.detailViewDelegate = detailViewDelegate
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
    
    func loadCrewTypes() {
        networkManager.getJobsList { [weak self] departments, error in
            if let error = error {
                print(error)
                DispatchQueue.main.async {
                    self?.detailViewDelegate?.displayError()
                }
                return
            }
            
            if let departments = departments {
                self?.crewTypes = departments
            }
        }
    }
    
    func getID() -> Int {
        return item.id
    }
    
    func getTitle() -> String {
        return item.name
    }
}
