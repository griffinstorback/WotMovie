//
//  UpgradePresenter.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-03-18.
//

import Foundation
import StoreKit

protocol UpgradePresenterProtocol {
    func setViewDelegate(_ upgradeViewDelegate: UpgradeViewDelegate?)
    func getLocalizedPrice() -> String?
    func purchasePersonGuessingUpgrade() -> Bool?
}

class UpgradePresenter: UpgradePresenterProtocol {
    private let networkManager: NetworkManagerProtocol
    private let imageDownloadManager: ImageDownloadManagerProtocol
    private let coreDataManager: CoreDataManager
    private let iapManager: IAPManager
    weak var upgradeViewDelegate: UpgradeViewDelegate?
    
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
         iapManager: IAPManager = IAPManager.shared) {
        self.networkManager = networkManager
        self.imageDownloadManager = imageDownloadManager
        self.coreDataManager = coreDataManager
        self.iapManager = iapManager
        
        loadIAPProducts()
    }
    
    func setViewDelegate(_ upgradeViewDelegate: UpgradeViewDelegate?) {
        self.upgradeViewDelegate = upgradeViewDelegate
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
    
    // Returns false if no payment can be made on this device - otherwise, it starts the transaction (and returns true)
    private func purchase(product: SKProduct) -> Bool {
        guard iapManager.canMakePayments() else { return false }
        
        //delegate.didStartLoadingTransaction
        iapManager.buy(product: product) { result in
            //delegate.didFinishLoadingTransaction
            
            switch result {
            case .success(_):
                self.updateAppDataWithPurchasedProduct(product)
            case .failure(let error):
                self.error = error
            }
        }
        
        return true
    }
    
    private func updateAppDataWithPurchasedProduct(_ product: SKProduct) {
        
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
