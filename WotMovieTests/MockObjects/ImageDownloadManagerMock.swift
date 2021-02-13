//
//  ImageDownloadManagerMock.swift
//  WotMovieTests
//
//  Created by Griffin Storback on 2021-02-12.
//

import Foundation
import UIKit
@testable import WotMovie

class ImageDownloadManagerMock: ImageDownloadManagerProtocol {
    func downloadImage(path: String, completion: @escaping (UIImage?, String?) -> Void) {
        completion(nil, "not implemented")
    }
}
