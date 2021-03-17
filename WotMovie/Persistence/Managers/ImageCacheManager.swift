//
//  ImageCacheManager.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-03-12.
//

import Foundation
import UIKit

final class CachedImage: Codable {
    let key: String
    let imageData: Data?
    let dateAdded: Date
    
    init(key: NSString, image: UIImage, dateAdded: Date) {
        self.key = key as String
        self.imageData = image.jpegData(compressionQuality: 1)
        self.dateAdded = dateAdded
    }
    
    init(key: NSString, imageData: Data, dateAdded: Date) {
        self.key = key as String
        self.imageData = imageData
        self.dateAdded = dateAdded
    }
}

// By extending NSDiscardableContent, we can prevent memory cache from being completely emptied when app is backgrounded,
// but then it seems it is never cleared, and eventually the app crashes while in background.
// (I tested this by creating large cache ~300MB, then opening a few different apps like iMDB - eventually WotMovie crashed while in BG).

/*extension CachedImage: NSDiscardableContent {
    func beginContentAccess() -> Bool {
        return true
    }
    
    func endContentAccess() {
        // nothing
    }
    
    func discardContentIfPossible() {
        // nothing
    }
    
    func isContentDiscarded() -> Bool {
        return false
    }
}*/


// Partially based on this article by John Sundell: https://www.swiftbysundell.com/articles/caching-in-swift/
final class ImageCacheManager {
    static let cacheFilename = "ImageCache.cache"
    static var shared = {
        ImageCacheManager.retrieveFromDisk() ?? ImageCacheManager()
    }()
    
    // Max number of items which should be persisted on disk
    private let maxNumberOfItemsToPersist = 150
    
    // When this reaches desired threshold, save to disk, then reset to 0. (we want to avoid constantly saving to disk)
    private var numberOfCachedItemsSinceSaveToDisk = 0
    private let numberOfItemsBeforeSavingToDiskThreshold = 30
    
    // Set this when retrieving cache from disk (used to prevent rewriting persistent cache with smaller cache,
    //   i.e. we retrieve cache size 120, then memory cache is cleared, and we end up rewriting the 120 with 30)
    private var numberOfPersistedCachedItems = 0 {
        didSet {
            // Should never surpass the max number of items in persistent cache
            if numberOfPersistedCachedItems > maxNumberOfItemsToPersist {
                numberOfPersistedCachedItems = maxNumberOfItemsToPersist
            }
        }
    }
    
    private init() {
        imageCache = NSCache<NSString, CachedImage>()
        keyTracker = KeyTracker()
        
        imageCache.delegate = keyTracker
    }
    
    // The image cache itself, which will hold as much in memory as possible.
    // every 30 (or whatever numberOfItemsBeforeSavingToDiskThreshold) entries, it saves maxNumberOfItemsToPersist to disk, so on next launch the app will have some already cached.
    private let imageCache: NSCache<NSString, CachedImage>
    private let keyTracker: KeyTracker
    
    // insert cached image at key. (DONT use publicly - use subscript)
    private func insertImage(_ cachedImage: CachedImage) {
        let key = cachedImage.key as NSString
        //print("***** INSERTING IMAGE INTO CACHE (key: \(cachedImage.key))")
        imageCache.setObject(cachedImage, forKey: key)
        if keyTracker.keys.insert(key).inserted {
            print("*****   KEY WAS INSERTED IN KEYTRACKER. KEYS COUNT: \(keyTracker.keys.count)")
        }
    }
    
    // Get the image data (if it exists) associated with the key
    private func cachedImage(for key: NSString) -> CachedImage? {
        //guard let imageData = imageCache.object(forKey: key)?.imageData else { return nil }
        guard let cachedImage = imageCache.object(forKey: key) else {
            //print("***** FAILED TO RETRIEVE IMAGE FROM CACHE (key: \(key))")
            return nil
        }
        //print("***** RETRIEVED IMAGE FROM CACHE (key: \(key))")
        return cachedImage
    }
    
    // Remove the value at 'key' (if one exists)
    private func removeImage(for key: NSString) {
        imageCache.removeObject(forKey: key)
    }
}

// enable subscripting - always use subscripting externally.
extension ImageCacheManager {
    subscript(key: NSString) -> UIImage? {
        get {
            guard let imageData = cachedImage(for: key)?.imageData else { return nil }
            return UIImage(data: imageData)
        }
        set {
            guard let image = newValue else {
                // if nil assigned in subscript, remove value for the key
                removeImage(for: key)
                return
            }
            
            let imageToCache = CachedImage(key: key, image: image, dateAdded: Date())
            insertImage(imageToCache)
            
            // save to disk after 30 (or whatever numberOfItemsBeforeSavingToDiskThreshold is) new entries.
            numberOfCachedItemsSinceSaveToDisk += 1
            if numberOfCachedItemsSinceSaveToDisk >= numberOfItemsBeforeSavingToDiskThreshold {
                
                // don't save to disk less items than there already are (disk has max maxNumberOfItemsToPersist - we don't want to rewrite 150 with 5, for example.)
                if keyTracker.keys.count >= numberOfPersistedCachedItems {
                    print("***** SAVING CACHE TO DISK - keyTracker has \(keyTracker.keys.count) keys, while numberOfPersistedCachedItems was set as \(numberOfPersistedCachedItems)")
                    if saveToDisk() {
                        numberOfCachedItemsSinceSaveToDisk = 0
                    }
                } else {
                    print("***** NOT SAVING CACHE TO DISK - keyTracker has \(keyTracker.keys.count) keys, while numberOfPersistedCachedItems was set as \(numberOfPersistedCachedItems)")
                }
            }
        }
    }
}

// track cached images by key (NSCache doesn't expose keys)
extension ImageCacheManager {
    final class KeyTracker: NSObject, NSCacheDelegate {
        var keys = Set<NSString>()
        
        func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
            guard let image = obj as? CachedImage else {
                print("***** FAILED TO CAST obj AS CachedImage (in KeyTracker willEvictObject) (obj: \(obj))")
                return
            }
            //print("***** REMOVING KEY FROM KEYTRACKER (in KeyTracker willEvictObject) (key: \(image.key))")
            keys.remove(image.key as NSString)
        }
    }
}

// enable persistence of cache
extension ImageCacheManager: Codable {
    convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.singleValueContainer()
        let cachedImages = try container.decode([CachedImage].self)
        cachedImages.forEach(insertImage)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        // persist random maxNumberOfItemsToPersist images from cache on disk
        var itemsToPersist: [CachedImage] = []
        for key in keyTracker.keys {
            if let img = cachedImage(for: key) {
                itemsToPersist.append(img)
                
                if itemsToPersist.count >= maxNumberOfItemsToPersist {
                    break
                }
            }
        }
        
        try container.encode(itemsToPersist)
    }
    
    func saveToDisk(using fileManager: FileManager = .default) -> Bool {
        // create URL to filename within the caches directory
        let folderURLs = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let fileURL = folderURLs[0].appendingPathComponent(ImageCacheManager.cacheFilename)
        
        // write data in this image cache manager to the URL
        print("***** SAVING CACHE DATA TO DISK AT URL: \(fileURL)")
        do {
            let data = try JSONEncoder().encode(self)
            try data.write(to: fileURL)
            return true
        } catch {
            print("** ERROR: Saving image cache to disk failed (key count: \(keyTracker.keys.count)), provided error: \(error)")
            return false
        }
    }
    
    static func retrieveFromDisk(using fileManager: FileManager = .default) -> ImageCacheManager? {
        let folderURLs = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let fileURL = folderURLs[0].appendingPathComponent(ImageCacheManager.cacheFilename)
        
        do {
            let data = try Data(contentsOf: fileURL)
            let storedImageCacheManager = try JSONDecoder().decode(ImageCacheManager.self, from: data)
            storedImageCacheManager.numberOfPersistedCachedItems = storedImageCacheManager.keyTracker.keys.count
            print("***** RETRIEVED CACHE FROM DISK, SIZE: \(data.count/1024/1024) megabytes, KEY COUNT: \(storedImageCacheManager.numberOfPersistedCachedItems)")
            
            return storedImageCacheManager
        } catch {
            print("***** ERROR RETRIEVING FILE FROM \(fileURL): \(error)")
            return nil
        }
    }
}
