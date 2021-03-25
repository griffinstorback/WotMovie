//
//  UpgradePresenter.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-03-18.
//

import Foundation
import StoreKit

protocol UpgradePresenterProtocol {
    var error: Error? { get set }
    func setViewDelegate(_ upgradeViewDelegate: UpgradeViewDelegate?)
    
    func getNumberOfPeopleInCarousel() -> Int
    func getPersonInCarouselForIndex(_ index: Int) -> Person?
    func loadImageFor(index: Int, completion: @escaping (_ image: UIImage?) -> Void)
    
    func getLocalizedPrice() -> String?
    func purchasePersonGuessingUpgrade() -> Bool?
    
    func loadExamplePeople()
}

class UpgradePresenter: UpgradePresenterProtocol {
    private let networkManager: NetworkManagerProtocol
    private let imageDownloadManager: ImageDownloadManagerProtocol
    private let coreDataManager: CoreDataManager
    private let iapManager: IAPManager
    private let keychain: Keychain
    weak var upgradeViewDelegate: UpgradeViewDelegate?
    
    // this list should always contain 3 entries (if less than three, fill missing ones with empty person in VC)
    private var examplePeople: [Person] = [] {
        didSet {
            if examplePeople.count > 3 {
                examplePeople = Array(examplePeople[0..<3])
            }
            
            upgradeViewDelegate?.reloadData()
        }
    }
    
    var products: [SKProduct] = [] {
        didSet {
            if products.count > 0 {
                DispatchQueue.main.async {
                    self.upgradeViewDelegate?.reloadData()
                }
            }
        }
    }
    
    var error: Error? {
        didSet {
            if error != nil {
                DispatchQueue.main.async {
                    self.upgradeViewDelegate?.displayError()
                }
            }
        }
    }
    
    init(networkManager: NetworkManagerProtocol = NetworkManager.shared,
         imageDownloadManager: ImageDownloadManagerProtocol = ImageDownloadManager.shared,
         coreDataManager: CoreDataManager = CoreDataManager.shared,
         iapManager: IAPManager = IAPManager.shared,
         keychain: Keychain = Keychain.shared) {
        self.networkManager = networkManager
        self.imageDownloadManager = imageDownloadManager
        self.coreDataManager = coreDataManager
        self.iapManager = iapManager
        self.keychain = keychain
        
        loadIAPProducts()
    }
    
    func setViewDelegate(_ upgradeViewDelegate: UpgradeViewDelegate?) {
        self.upgradeViewDelegate = upgradeViewDelegate
    }
    
    func getNumberOfPeopleInCarousel() -> Int {
        return max(3, examplePeople.count)
    }
    
    func getPersonInCarouselForIndex(_ index: Int) -> Person? {
        if index < examplePeople.count {
            return examplePeople[index]
        } else {
            // if index is out of range, return nil, indicating a default image should be used in place of an actual person.
            return nil
        }
    }
    
    func loadImageFor(index: Int, completion: @escaping (_ image: UIImage?) -> Void) {
        guard index < examplePeople.count else { return }
        let item = examplePeople[index]
        
        if let posterPath = item.posterPath {
            imageDownloadManager.downloadImage(path: posterPath) { image, error in
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
        } else {
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
    
    func getLocalizedPrice() -> String? {
        // there's only one product (as of now), so return the price for the first item in the products array
        guard products.count > 0 else { return nil }
        return iapManager.getPriceFormatted(for: products[0])
    }
    
    func restorePurchases() {
        //delegate.didStarLoading
        iapManager.restorePurchases { result in
            //delegate.didFinishLoading
            
            switch result {
            case .success(let success):
                if success {
                    // did finish restoring purchased products
                } else {
                    // did finish restoring purchases with 0 products
                }
            case .failure(let error):
                self.error = error
            }
        }
    }
    
    // return nil if product not found - false if purchase() returns false (device can't make payments)
    func purchasePersonGuessingUpgrade() -> Bool? {
        guard products.count > 0 else { return nil }
        return purchase(product: products[0])
    }
    
    // get 3 random people from the top page of popular people (either from core data or network)
    func loadExamplePeople() {
        if !loadExamplePeopleFromCoreData() {
            loadExamplePeopleFromNetwork() { [weak self] success in
                if success {
                    print("**** GOT EXAMPLE PEOPLE FROM NETWORK. (\(self?.examplePeople.count))")
                } else {
                    print("**** FAILED TO GET EXAMPLE PEOPLE FROM NETWORK.")
                    // try one more time
                    self?.loadExamplePeopleFromNetwork() { [weak self] success in
                        if success {
                            print("** **** GOT EXAMPLE PEOPLE FROM NETWORK (AFTER FAILURE. (\(self?.examplePeople.count))")
                        } else {
                            print("** **** FAILED (TWICE!) TO GET EXAMPLE PEOPLE FROM NETWORK.")
                        }
                    }
                }
            }
        } else {
            print("**** GOT EXAMPLE PEOPLE FROM CORE DATA. (\(examplePeople.count))")
        }
    }
    
    private func loadExamplePeopleFromCoreData() -> Bool {
        if let items = coreDataManager.fetchEntityPage(category: .person, pageNumber: 1, genreID: -1) {
            if items.count != 0 {
                examplePeople = items as? [Person] ?? []
                return true
            }
        }
        
        return false
    }
    
    private func loadExamplePeopleFromNetwork(completion: @escaping (_ success: Bool) -> Void) {
        networkManager.getPopularPeople(page: 1) { [weak self] people, error in
            if let error = error {
                print(error)
                completion(false)
                return
            }
            if let people = people {
                
                // update/create page in core data, then retrieve the newly posted page
                if let strongSelf = self {
                    DispatchQueue.main.async {
                        
                        let newlyAddedPeople = strongSelf.coreDataManager.updateOrCreatePersonPage(people: people, pageNumber: 1)
                        strongSelf.examplePeople = newlyAddedPeople ?? []
                        completion(true)
                        return
                    }
                }
                
                completion(false)
                return
            }
        }
    }
    
    // Returns false if no payment can be made on this device - otherwise, it starts the transaction (and returns true)
    private func purchase(product: SKProduct) -> Bool {
        guard iapManager.canMakePayments() else { return false }
        
        //delegate.didStartLoadingTransaction
        iapManager.buy(product: product) { result in
            //delegate.didFinishLoadingTransaction
            
            switch result {
            case .success(let success):
                if success {
                    self.productPurchasedSuccessfully(product)
                }
            case .failure(let error):
                self.error = error
            }
        }
        
        return true
    }
    
    private func productPurchasedSuccessfully(_ product: SKProduct) {
        
        upgradeViewDelegate?.upgradeWasPurchased()
        
        // TODO: DELETE THE KEYCHAIN LINE -- ITS DONE IN IAP MANAGER
        // update keychain to reflect user has purchased the upgrade
        keychain[Constants.KeychainStrings.personUpgradePurchasedKey] = Constants.KeychainStrings.personUpgradePurchasedValue
        
        // send notification to any view listening that upgrade was purchased.
        let notification = Notification(name: .WMUserDidUpgrade)
        NotificationQueue.default.enqueue(notification, postingStyle: .asap)
    }
    
    private func loadIAPProducts() {
        //delegate.didStartLoading()
        
        iapManager.getProducts { result in
            //delegate.didFinishLoading()
            
            switch result {
            case .success(let products):
                self.products = products
                self.error = nil
            case .failure(let error):
                self.products = []
                self.error = error
            }
        }
    }
}
