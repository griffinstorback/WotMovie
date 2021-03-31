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
    
    // main screen boxes (Movies, TV Shows, People, along with their image) corner radius ratio
    static let guessCategoryViewRadiusRatio: CGFloat = 1/7
    
    struct DetailOverviewPosterImage {
        
        // TODO: return larger if running ipad?
        static let size: CGSize = CGSize(width: 160, height: 240)
    }
    
    struct PersonOverviewPosterImage {
        static let size: CGSize = CGSize(width: 200, height: 300)
    }
    
    struct Colors {
        // this static color should only be used as backup - the actual default blue is a dynamic color (different in light/dark mode), and is defined in Assets.
        static let defaultBlue: UIColor = UIColor(red: 84/255, green: 101/255, blue: 255/255, alpha: 1.0)
        //static let defaultBlue: UIColor = UIColor(red: 107/255, green: 122/255, blue: 255/255, alpha: 1.0)
    }
    
    struct Fonts {
        static let detailViewSectionHeader = UIFont.systemFont(ofSize: 22, weight: .bold)
    }
    
    // When displaying grid, should omit these items below, for they have descriptions that are either impossible to
    // guess from, or way too easy; especially important for first impressions (don't want a first time user to see
    // multiple bad descriptions in a row)
    struct BadDescriptions {
        static let movies: Set<Int> = [
            -1, // MovieName
        ]
        
        static let tvShows: Set<Int> = [
            -1, // TVShowName
        ]
    }
    
    struct KeychainStrings {
        static let personUpgradePurchasedKey = "person_guessing"
        static let personUpgradePurchasedValue = "yes"
    }
}


