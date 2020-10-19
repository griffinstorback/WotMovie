//
//  PropertyWrappers.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-13.
//

import Foundation
import UIKit

// easily set translatesAutoresizingMaskIntoConstraints when initializing views.
@propertyWrapper
public struct UsesAutoLayout<T: UIView> {
    public var wrappedValue: T {
        didSet {
            wrappedValue.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
        wrappedValue.translatesAutoresizingMaskIntoConstraints = false
    }
}

// set and get userdefaults keys easily
@propertyWrapper
public struct UserDefault<T> {
    let key: String
    let defaultValue: T
    
    public var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
    
    public init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
}
struct UserDefaultsConfig {
    @UserDefault("hasSeenAppIntroduction", defaultValue: false)
    static var hasSeenAppIntroduction: Bool
}
