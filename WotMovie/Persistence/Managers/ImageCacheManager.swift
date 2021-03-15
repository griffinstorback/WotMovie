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

final class ImageCacheManager {
    static let cacheFilename = "ImageCache.cache"
    static var shared = {
        ImageCacheManager.retrieveFromDisk() ?? ImageCacheManager()
    }()
    
    // when this reaches 10, save to disk, the reset to 0.
    private var numberOfCachedItemsSinceSaveToDisk = 0
    
    private init() {
        imageCache = NSCache<NSString, CachedImage>()
        keyTracker = KeyTracker()
        
        imageCache.delegate = keyTracker
    }
    
    // The image cache itself, which will hold as much in memory as possible.
    // every 10 entries, it saves 100 to disk, so on next launch the app will have some already cached.
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
            
            // save to disk after 10 new entries.
            numberOfCachedItemsSinceSaveToDisk += 1
            if numberOfCachedItemsSinceSaveToDisk >= 10 {
                try? saveToDisk()
                numberOfCachedItemsSinceSaveToDisk = 0
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
        
        // persist random 100 images from cache on disk
        var last100: [CachedImage] = []
        for key in keyTracker.keys {
            if let img = cachedImage(for: key) {
                last100.append(img)
                
                if last100.count >= 100 {
                    break
                }
            }
        }
        
        try container.encode(last100)
    }
    
    func saveToDisk(using fileManager: FileManager = .default) throws {
        // create URL to filename within the caches directory
        let folderURLs = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let fileURL = folderURLs[0].appendingPathComponent(ImageCacheManager.cacheFilename)
        
        // write data in this image cache manager to the URL
        let data = try JSONEncoder().encode(self)
        print("***** SAVING CACHE DATA TO DISK AT URL: \(fileURL)")
        try data.write(to: fileURL)
    }
    
    static func retrieveFromDisk(using fileManager: FileManager = .default) -> ImageCacheManager? {
        let folderURLs = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let fileURL = folderURLs[0].appendingPathComponent(ImageCacheManager.cacheFilename)
        
        do {
            let data = try Data(contentsOf: fileURL)
            let storedImageCacheManager = try JSONDecoder().decode(ImageCacheManager.self, from: data)
            print("***** RETRIEVED CACHE FROM DISK, SIZE: \(data.count/1024/1024) megabytes, KEY COUNT: \(storedImageCacheManager.keyTracker.keys.count)")
            return storedImageCacheManager
        } catch {
            print("***** ERROR RETRIEVING FILE FROM \(fileURL): \(error)")
            return nil
        }
    }
}
