//
//  IAPManager.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-03-17.
//

import Foundation
import StoreKit

class IAPManager: NSObject {
    static let shared = IAPManager()
    private override init() {
        super.init()
    }
    
    var totalRestoredPurchases = 0
    
    var onReceiveProductsHandler: ((Swift.Result<[SKProduct], IAPManagerError>) -> Void)?
    var onBuyProductHandler: ((Swift.Result<Bool, Swift.Error>) -> Void)?
    
    fileprivate func getProductIDs() -> [String]? {
        guard let url = Bundle.main.url(forResource: "IAP_ProductIDs", withExtension: "plist") else { return nil }
        
        do {
            let data = try Data(contentsOf: url)
            let productIDs = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil) as? [String] ?? []
            return productIDs
        } catch {
            print("** ERROR getting IAP product IDs: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getProducts(withHandler productsReceiveHandler: @escaping (_ result: Swift.Result<[SKProduct], IAPManagerError>) -> Void) {
        onReceiveProductsHandler = productsReceiveHandler
        
        guard let productIDs = getProductIDs() else {
            productsReceiveHandler(.failure(.noProductIDsFound))
            return
        }
        
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        request.delegate = self
        request.start()
    }
    
    func getPriceFormatted(for product: SKProduct) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price)
    }
    
    func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    func buy(product: SKProduct, withHandler handler: @escaping ((_ result: Swift.Result<Bool, Error>) -> Void)) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
        
        // keep the completion handler
        onBuyProductHandler = handler
    }
    
    func restorePurchases(withHandler handler: @escaping ((_ result: Swift.Result<Bool, Error>) -> Void)) {
        onBuyProductHandler = handler
        totalRestoredPurchases = 0
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func readReceipt() {
        
    }
    
    func startObserving() {
        SKPaymentQueue.default().add(self)
    }
    
    func stopObserving() {
        SKPaymentQueue.default().remove(self)
    }
    
    // call when user purchases/restores the person category upgrade.
    private func updateKeychainWithPersonUpgradePurchase() {
        print("***** (IAP MANAGER) UPDATING KEYCHAIN WITH PERSON UPGRADE PURCHASE, AND SENDING NOTIFICATION THAT USER UPGRADED.")
        
        // update keychain to reflect user has purchased the upgrade
        Keychain.shared[Constants.KeychainStrings.personUpgradePurchasedKey] = Constants.KeychainStrings.personUpgradePurchasedValue
        
        // send notification to any view listening that upgrade was purchased.
        let notification = Notification(name: .WMUserDidUpgrade)
        NotificationQueue.default.enqueue(notification, postingStyle: .asap)
    }
}

extension IAPManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products
        
        if products.count > 0 {
            onReceiveProductsHandler?(.success(products))
        } else {
            onReceiveProductsHandler?(.failure(.noProductsFound))
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        onReceiveProductsHandler?(.failure(.productRequestFailed))
    }
    
    //func requestDidFinish(_ request: SKRequest) { }
}

extension IAPManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { transaction in
            switch transaction.transactionState {
            case .purchased:
                updateKeychainWithPersonUpgradePurchase()
                onBuyProductHandler?(.success(true))
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case .restored:
                totalRestoredPurchases += 1
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case .failed:
                // If transaction failed because user cancelled, send back our custom error.
                if let error = transaction.error as? SKError {
                    if error.code != .paymentCancelled {
                        onBuyProductHandler?(.failure(error))
                    } else {
                        onBuyProductHandler?(.failure(IAPManagerError.paymentWasCancelled))
                    }
                    print("** ERROR: failed transaction in IAPManager: \(error.localizedDescription)")
                }
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case .deferred, .purchasing:
                break
            @unknown default:
                break
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if totalRestoredPurchases != 0 {
            updateKeychainWithPersonUpgradePurchase()
            onBuyProductHandler?(.success(true))
        } else {
            print("***** (IAP MANAGER) NO IAP PRODUCTS TO RESTORE")
            onBuyProductHandler?(.success(false))
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        if let error = error as? SKError {
            if error.code != .paymentCancelled {
                print("** ERROR: IAPManager: restore purchase error: \(error.localizedDescription)")
                onBuyProductHandler?(.failure(error))
            } else {
                onBuyProductHandler?(.failure(IAPManagerError.paymentWasCancelled))
            }
        }
    }
}

// Provide the error enum
extension IAPManager {
    enum IAPManagerError: Error, LocalizedError {
        case noProductIDsFound
        case noProductsFound
        case paymentWasCancelled
        case productRequestFailed
        
        var errorDescription: String? {
            switch self {
            case .noProductIDsFound: return "No In-App Purchase product identifiers were found."
            case .noProductsFound: return "No In-App Purchases were found."
            case .paymentWasCancelled: return "In-App Purchase was cancelled."
            case .productRequestFailed: return "Unable to fetch available In-App Purchase products at the moment."
            }
        }
    }
}
