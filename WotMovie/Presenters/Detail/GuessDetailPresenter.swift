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
    var item: Entity { get set }
    func reloadItemFromCoreData(shouldSetLastViewedDate: Bool)
    
    func setViewDelegate(detailViewDelegate: GuessDetailViewDelegate?)
    func loadPosterImage(completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void)
    func cancelLoadImageRequestFor(imagePath: String)
    
    //func loadCrewTypes()
    func getID() -> Int
    func getName() -> String
    
    func isHintShown() -> Bool
    func isAnswerRevealed() -> Bool
    func isAnswerCorrectlyGuessed() -> Bool
    
    func hintWasShown()
    func answerWasRevealed()
    func answerWasRevealedAsCorrect()
    
    func answerWasRevealedDuringAttemptToDismiss()
}

class GuessDetailPresenter: GuessDetailPresenterProtocol {
    let networkManager: NetworkManagerProtocol
    let imageDownloadManager: ImageDownloadManagerProtocol
    let coreDataManager: CoreDataManager
    weak var detailViewDelegate: GuessDetailViewDelegate?
    
    var item: Entity
    
    // call this function if you want to reload view after item is set.
    func setItem(item: Entity) {
        self.item = item
        
        DispatchQueue.main.async {
            self.detailViewDelegate?.reloadData()
        }
    }
    
    var crewTypes: [Department] = [] {
        didSet {
            print(crewTypes)
        }
    }
    
    // TODO: Currently, PersonDetail uses this, but TitleDetail has been refactored to use CrewTypeSection enum. Make PersonDetail do same.
    let crewTypeForSection: [String] = [
        "Director",
        "Writer",
        "Producer"
    ]
    
    init(networkManager: NetworkManagerProtocol = NetworkManager.shared,
            imageDownloadManager: ImageDownloadManagerProtocol = ImageDownloadManager.shared,
            coreDataManager: CoreDataManager = CoreDataManager.shared,
            item: Entity) {
        self.networkManager = networkManager
        self.imageDownloadManager = imageDownloadManager
        self.coreDataManager = coreDataManager
        self.item = item
        
        //loadCrewTypes()
        //reloadItemFromCoreData()
        
        // TODO (maybe not right here though): Check if Core data entity language matches user's current language - if not, retrieve from network and update movie.
    }
    
    func reloadItemFromCoreData(shouldSetLastViewedDate: Bool = true) {
        guard let entityFromCoreData = coreDataManager.updateOrCreateEntity(entity: item, shouldSetLastViewedDate: shouldSetLastViewedDate) else { return }
        self.item = entityFromCoreData
        
        DispatchQueue.main.async {
            self.detailViewDelegate?.updateItemOnEnterGuessView()
        }
    }
    
    // this is called from sub classes, title and person when details (credits) are retrieved from network (details come with credits, so may as well update CD)
    func updateEntityInCoreData(_ entity: Entity?) {
        if let entity = entity {
            DispatchQueue.global().async {
                print("***** entity of type \(entity.type) (name: \(entity.name)) retrieved from details object, updating entity in Core Data now, on BG thread.")
                
                // Importantly, DON'T SET lastViewedDate - we have to be careful when setting this, to not set it when the item is still .fullyHidden (i.e. is
                //  not guessed or revealed). The other method in this class reloadItemFromCoreData(), will be called from within viewDidAppear
                //  from GuessViewDetailController, on the condition that its state is not .fullyHidden (or .hintShown).
                self.coreDataManager.backgroundUpdateOrCreateEntity(entity: entity, shouldSetLastViewedDate: false)
            }
        }
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
    
    func cancelLoadImageRequestFor(imagePath: String) {
        imageDownloadManager.cancelImageDownload(path: imagePath)
    }
    
    /*func loadCrewTypes() {
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
    }*/
    
    func getID() -> Int {
        return item.id
    }
    
    func getName() -> String {
        return item.name
    }
    
    func isHintShown() -> Bool {
        return item.isHintShown
    }
    
    func isAnswerRevealed() -> Bool {
        return item.isRevealed
    }
    
    func isAnswerCorrectlyGuessed() -> Bool {
        return item.correctlyGuessed
    }
    
    
    // Call one of the below functions from the view delegate. If just retrieved the entity from core data, just set
    // item.isHintShown/.isRevealed/.correctlyGuessed on the item itself, to avoid redundant core data update.
    //
    func hintWasShown() {
        item.isHintShown = true
        coreDataManager.updateOrCreateEntity(entity: item, shouldSetLastViewedDate: false)
    }
    
    func answerWasRevealed() {
        item.isRevealed = true
        coreDataManager.updateOrCreateEntity(entity: item)
    }
    
    func answerWasRevealedAsCorrect() {
        item.correctlyGuessed = true
        coreDataManager.updateOrCreateEntity(entity: item)
    }
    
    // Call this from DetailViewController when user is trying to dismiss detail view without having guessed/revealed.
    func answerWasRevealedDuringAttemptToDismiss() {
        detailViewDelegate?.answerWasRevealedDuringAttemptToDismiss()
    }
}
