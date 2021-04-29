//
//  ImageDownloadManager.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-16.
//

import Foundation
import UIKit

protocol ImageDownloadManagerProtocol {
    // find a way to test that images are stored in variable imageCache
    func cancelImageDownload(path: String)
    func downloadImage(path: String, completion: @escaping (_ image: UIImage?, _ error: String?) -> Void)
    func downloadOriginalImage(path: String, completion: @escaping (_ image: UIImage?, _ error: String?) -> Void)
}

final class ImageDownloadManager: ImageDownloadManagerProtocol {
    
    static let shared = ImageDownloadManager()
    private init() {
        imageCache = ImageCacheManager.shared
    }
    
    private let imageCache: ImageCacheManager
    private let imageRouter = Router<ImageApi>()
    
    // since images are large, we want to be able to cancel queries for them
    private var activeDownloads: [String:URLSessionDataTask] = [:]
    
    // TODO: currently, this method is called whenever an image leaves the screen. This is a very small computation when nothing to remove, but that's still wasted resources.
    func cancelImageDownload(path: String) {
        if let activeDownload = activeDownloads[path] {
            
            // need to cancel on a background thread, or else it sometimes crashes?
            DispatchQueue.global().async {
                activeDownload.cancel()
            }
            
            activeDownloads[path] = nil
            print("******* cancelImageDownload - successfully cancelled download for path \(path) (activeDownloads count: \(activeDownloads.count))")
        }/* else {
            print("******* cancelImageDownload - NO ACTIVE DOWNLOAD found for path \(path) (activeDownloads count: \(activeDownloads.count))")
        }*/
    }
    
    func downloadImage(path: String, completion: @escaping (_ image: UIImage?, _ error: String?) -> Void) {
        let nsStringPath = path as NSString
        
        if let cachedImage = imageCache[nsStringPath] {
            completion(cachedImage, nil)
            return
        }
        
        activeDownloads[path] = imageRouter.requestAndReturnDataTask(.imageWithPath(path: path)) { data, response, error in
            // request returned, so data task is no longer active (do this on main thread, causes crashes otherwise)
            DispatchQueue.main.async {
                self.activeDownloads[path] = nil
            }
            
            if error != nil {
                completion(nil, NetworkResponse.checkNetworkConnection.rawValue)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = NetworkResponse.handleNetworkResponse(response)
                
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    
                    if let image = UIImage(data: responseData) {
                        // success
                        completion(image, nil)
                        
                        // update image cache
                        self.imageCache[nsStringPath] = image
                    } else {
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    print(networkFailureError)
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    func downloadOriginalImage(path: String, completion: @escaping (_ image: UIImage?, _ error: String?) -> Void) {
        let nsStringPath = path as NSString
        
        /*if let cachedImage = imageCache[nsStringPath] {
            completion(cachedImage, nil)
            return
        }*/
        
        //activeDownloads[path] = imageRouter.requestAndReturnDataTask(.originalImageWithPath(path: path)) { data, response, error in
        _ = imageRouter.requestAndReturnDataTask(.originalImageWithPath(path: path)) { data, response, error in
            // request returned, so data task is no longer active (do this on main thread, causes crashes otherwise)
            /*DispatchQueue.main.async {
                self.activeDownloads[path] = nil
            }*/
            
            if error != nil {
                completion(nil, NetworkResponse.checkNetworkConnection.rawValue)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = NetworkResponse.handleNetworkResponse(response)
                
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    
                    if let image = UIImage(data: responseData) {
                        // success
                        completion(image, nil)
                        
                        // update image cache
                        self.imageCache[nsStringPath] = image
                    } else {
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    print(networkFailureError)
                    completion(nil, networkFailureError)
                }
            }
        }
    }
}
