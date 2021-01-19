//
//  CoreData+Extensions.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-01-19.
//

import Foundation
import CoreData

extension NSManagedObject {
    
    // methods for adding/removing objects from a many-to-many relationship
    func addObject(value: NSManagedObject, for key: String) {
        var items = self.mutableSetValue(forKey: key)
        items.add(value)
    }
    
    func removeObject(value: NSManagedObject, for key: String) {
        var items = self.mutableSetValue(forKey: key)
        items.remove(value)
    }
    
    func removeAllObjects(for key: String) {
        var items = self.mutableSetValue(forKey: key)
        items.removeAllObjects()
    }
}
