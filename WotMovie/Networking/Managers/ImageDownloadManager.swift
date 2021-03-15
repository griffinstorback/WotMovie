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
    func downloadImage(path: String, completion: @escaping (_ image: UIImage?, _ error: String?) -> Void)
}

final class ImageDownloadManager: ImageDownloadManagerProtocol {
    
    static let shared = ImageDownloadManager()
    private init() {
        imageCache = ImageCacheManager.shared
    }
    
    private let imageCache: ImageCacheManager
    private let imageRouter = Router<ImageApi>()
    
    func downloadImage(path: String, completion: @escaping (_ image: UIImage?, _ error: String?) -> Void) {
        let nsStringPath = path as NSString
        
        if let cachedImage = imageCache[nsStringPath] {
            completion(cachedImage, nil)
            return
        }
        
        imageRouter.request(.imageWithPath(path: path)) { data, response, error in
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
