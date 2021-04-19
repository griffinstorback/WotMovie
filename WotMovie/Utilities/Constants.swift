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
    
    struct KeychainStrings {
        static let personUpgradePurchasedKey = "person_guessing"
        static let personUpgradePurchasedValue = "yes"
    }
    
    // When displaying grid, should omit these categories below, for they have descriptions that are either impossible to
    // guess from, or way too easy.
    struct BadCategories {
        static let movies: Set<Int> = [
            // format: ID int, // Movie category name commented out
        ]
        
        static let tvShows: Set<Int> = [
            10767, // Talk
            10763, // News
        ]
    }
    
    // Same as bad categories defined above, but for individual items. This should be reviewed each release of
    // the app, especially those listed under PRETTY BAD.
    struct BadDescriptions { // these are for ENGLISH
        // TODO??: Convert this to a list on TMDB under my account, which each user would query, to allow updates without updating the app?
        //          note: this would require adhering to the v4 api, which would mean slightly rethinking how networking is done.
        
        static let movies: Set<Int> = [
            // TERRIBLE (name is in description)
            
            
            
            
            // PRETTY BAD
        ]
        static let tvShows: Set<Int> = [
            // TERRIBLE (name is in description)
            31910, // naruuto shippuden
            62104, // the seven deadly sins
            43348, // pablo escobar the drug lord
            65334, // miraculous: tales of ladybug & cat noir
            16286, // yo soy betty, la fea (terribly long desc with name in it too)
            
            
            
            
            // PRETTY BAD
            61889, // daredevil (name in title, but not obviously)
            62715, // dragon ball super
            67335, // sin senos si hay paraiso (title not in english at all)
            
        ]
    }
}


