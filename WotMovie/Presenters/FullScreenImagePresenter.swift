//
//  FullScreenImagePresenter.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-04-28.
//

import Foundation
import UIKit

protocol FullScreenImagePresenterProtocol {
    func setViewDelegate(_ delegate: FullScreenImageViewDelegate?)
    func loadPosterImage(completion: @escaping (_ image: UIImage?) -> Void)
}

class FullScreenImagePresenter: FullScreenImagePresenterProtocol {
    let imageDownloadManager: ImageDownloadManagerProtocol
    weak var fullScreenImageViewDelegate: FullScreenImageViewDelegate?
    
    let item: Entity
    
    init(item: Entity,
         imageDownloadManager: ImageDownloadManagerProtocol = ImageDownloadManager.shared) {
        self.imageDownloadManager = imageDownloadManager
        
        self.item = item
    }
    
    func setViewDelegate(_ delegate: FullScreenImageViewDelegate?) {
        fullScreenImageViewDelegate = delegate
    }
    
    func loadPosterImage(completion: @escaping (_ image: UIImage?) -> Void) {
        // this case shouldn't be hit, because whichever class is presenting the full screen image should check that posterpath exists before presenting.
        guard let posterPath = item.posterPath, !posterPath.isEmpty else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        imageDownloadManager.downloadOriginalImage(path: posterPath) { image, error in
            if let error = error {
                print("** ERROR: error getting original sized image in FullScreenImagePresenter: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
}
