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
            10766, // Soap (for some reason, its just filled with Spanish drama shows)
        ]
    }
    
    // Same as bad categories defined above, but for individual items. This should be reviewed each release of
    // the app, especially those listed under PRETTY BAD.
    struct BadDescriptions { // these are for ENGLISH
        // TODO??: Convert this to a list on TMDB under my account, which each user would query, to allow updates without updating the app?
        //          note: this would require adhering to the v4 api, which would mean slightly rethinking how networking is done.
        
        // CONSIDER MAKING PRETTY BAD MOVIES/TV SHOWS SEPARATE  FROM TERIBLE, AND SHOW THEM ONCE USER HAS SEEN ENOUGH OTHERS
        
        static let movies: Set<Int> = [
            // TERRIBLE (name is in description)
            17478, // the adventures of tin tin (name in desc)
            
            
            
            
            // PRETTY BAD (a lot of these are just semi obvious sequels which aren't so fun to guess)
            299534, // Avengers: endame (pretty obvious by description, also, ENOUGH marvel spam i.e everyone knows this movie already)
            99861, // Avengers: age of ultron (same as endgame - too many avengers movies
            1771, // Captain america: the first avenger (pretty obvious, and again, enough marvel spam)
            12445, // Harry potter and the deathly hallows: Part 2 (need to prune some of these HP movies)
            12444, // harry potter and the deathly hallows: part 1 (begone, young potter)
            10138, // Iron man 2 (iron man 1 and 3 are enough, this one is more obvious)
            315635, // Spider-man homecoming (enough marvel)
            674, // Harry potter and the goblet of fire (enough Potter spam)
            672, // harry potter and the chamber of secrets (enough Potter spam)
            675, // harry potter and the order of the phoenix (enough Potter spam)
            100402, // captain america the winter soldier (Enough marvel spam, also long desc., also obvious)
            76338, // thor: the dark world (enough marvel spam)
            1865, // pirates of the caribbean: on stranger tides (enough Captain Jack spam)
            122917, // the hobbit: the battle of the five armies (enough filthy Hobbitses spam)
            558, // spider-man 2 (obvious)
            559, // spider-man 3 (obvious)
            246655, // x-men apocalypse (obvious)
            863, // toy story 2 (enough)
            131634, // the hunger games mockingjay part 2 (obvious)
            166426, // pirates of the caribbean: dead men tell no tales (obvious - and enough capn jack spam)
            102382, // the amazing spider-man 2 (my spidey senses are tingling - and telling me OBVIOUS),
            206647, // spectre (bond movies kind of just suck, and this one is slightly obvious)
            168259, // furious 7 (don't think i need to explain)
            45243, // the hangover part II (obvious)
            337339, // the fate of the furious (enough toretto spam)
            196, // back to the future part III (name in desc, obvious)
            604, // the matrix reloaded (obvious, and long desc)
            950, // ice age: the meltdown (obvious)
            76170, // the wolverine (enough wolverine spam - also sort of obvious)
            36668, // x-men the last stand (obvious, and enough x men spam)
            82702, // how to train your dragon 2 (obvious, and long desc)
            301528, // toy story 4
            24021, // the twilight saga: eclipse (enough of twilight)
            50619, // the twilight saga: breaking dawn part 1
            50620, // the twilight saga: breaking dawn part 2
            810, // shrek the third
            87, // indiana jones and the temple of doom
            177677, // mission impossible: rogue nation (boring)
            281338, // war for the planet of the apes (the third one, vague description)
            458156, // john wick 3 parabellum (obvious, also boring movie)
            38356, // transformers dark of the moon (third one)
            1979, // fantastic four rise of the silver surfer (obvious, and bad movie)
            337167, // fifty shades freed (third one)
            330, // the lost world: jurassic park (third one)
            51497, // fast five (need i say?)
            91314, // transformers age of extinction
            57800, // ice age continental drift (holy shit how many ice age movies are there)
            353081, // mission impossible fallout (enough tom cruise spam)
            10764, // quantum of solace (who even cares about james bond anymore)
            2503, // the bourne ultimatum (most sequels are bad for this app)
            512200, // jumanji: the next level (i'm pretty sure i left the first new jumanji film in, so get atta here)
            408, // snow white and the seven dwarfs (pretty obvious)
            2502, // the bourne supremacy (sequel)
            336843, // maze runner: the death cure (third)
            324852, // despicable me 3
            76163, // the expendables 2
            49444, // kung fu panda 2 (long desc kinda obv)
            464052, // wonder woman 1984 (obvious)
            7191, // cloverfield (just a bad description, telling nothing of value)
            13804, // fast & furious (enough f&f)
            956, // mission impossible III
            414, // batman forever (bad movie, and enough batman)
            138103, // the expendables 3 (too long desc)
            1996, // lara croft tomb raider the cradle of life
            71679, // resident evil: retribution (too long)
            140300, // kung fu panda 3 (nuff said)
            10192, // shrek forever after
            278154, // ice age collision course
            260514, // cars 3
            16290, // jackass 3d (name in desc)
            335988, // transformers: the last knight
            47971, // xXx: return of xander cage
            
        ]
        static let tvShows: Set<Int> = [
            // TERRIBLE (name is in description)
            31910, // naruuto shippuden
            62104, // the seven deadly sins
            43348, // pablo escobar the drug lord
            65334, // miraculous: tales of ladybug & cat noir
            16286, // yo soy betty, la fea (terribly long desc with name in it too)
            67915, // Goblin - too longof description (also, name is in it)
            11250, // Pasion de gavilanes (name in description, also not in english)
            44953, // the lord of the skies (name in description)
            18350, // atrevete a sonar (name in desc)
            42910, // love & hip hop atlanta (name in desc)
            
            
            
            // PRETTY BAD
            61889, // daredevil (name in title, but not obviously)
            62715, // dragon ball super
            67335, // sin senos si hay paraiso (title not in english at all)
            73055, // attack on titan: no regrets (description too long)
            12697, // dragon ball GT (boring, slightly too long, and sort of obvious)
            76121, // darling in the franxx (too long description)
            58450, // bad description
            66398, // (mexican)
            7842, // the tom and jerry show (name in desc sorta)
        ]
    }
}


