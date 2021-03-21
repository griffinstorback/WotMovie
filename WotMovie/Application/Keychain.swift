//
//  Keychain.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-03-19.
//

import Foundation

class Keychain {
    static let shared = Keychain()
    private init() {}
    
    subscript(key: String) -> String? {
        get {
            return load(with: key)
        }
        set {
            DispatchQueue.global().sync(flags: .barrier) {
                self.save(newValue, for: key)
            }
        }
    }
    
    private func save(_ string: String?, for key: String) {
        let query = keychainQuery(with: key)
        let objectData: Data? = string?.data(using: .utf8, allowLossyConversion: false)
        
        if SecItemCopyMatching(query, nil) == noErr {
            if let dictData = objectData {
                let status = SecItemUpdate(query, NSDictionary(dictionary: [kSecValueData: dictData]))
                print("** Update status: ", status)
            } else {
                let status = SecItemDelete(query)
                print("** Delete status: ", status)
            }
        } else {
            // create new
            if let dictData = objectData {
                query.setValue(dictData, forKey: kSecValueData as String)
                let status = SecItemAdd(query, nil)
                print("** Add status: ", status)
            }
        }
    }
    
    private func load(with key: String) -> String? {
        let query = keychainQuery(with: key)
        query.setValue(kCFBooleanTrue, forKey: kSecReturnData as String)
        query.setValue(kCFBooleanTrue, forKey: kSecReturnAttributes as String)
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query, &result)
        
        guard let resultsDict = result as? NSDictionary,
              let resultsData = resultsDict.value(forKey: kSecValueData as String) as? Data,
              status == noErr else {
            print("** Load status: ", status)
            return nil
        }
        
        return String(data: resultsData, encoding: .utf8)
    }
    
    private func keychainQuery(with key: String) -> NSMutableDictionary {
        let result = NSMutableDictionary()
        result.setValue(kSecClassGenericPassword, forKey: kSecClass as String)
        result.setValue(key, forKey: kSecAttrService as String)
        result.setValue(kSecAttrAccessibleWhenUnlocked, forKey: kSecAttrAccessible as String)
        return result
    }
}
