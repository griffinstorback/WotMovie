//
//  Constants.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-26.
//

import Foundation
import UIKit

struct Constants {
    // ratio of cornerRadius/height
    static let imageCornerRadiusRatio: CGFloat = 1/20
    
    struct DetailOverviewPosterImage {
        
        // TODO: return larger if running ipad?
        static let size: CGSize = CGSize(width: 160, height: 240)
    }
    
    struct PersonOverviewPosterImage {
        static let size: CGSize = CGSize(width: 200, height: 300)
    }
    
    struct Colors {
        static let defaultBlue: UIColor = UIColor(red: 84/255, green: 101/255, blue: 255/255, alpha: 1.0)
    }
}
