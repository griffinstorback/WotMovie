//
//  StatsPresenter.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-02-14.
//

import Foundation

protocol StatsPresenterProtocol {
    func setViewDelegate(_ statsViewDelegate: StatsViewDelegate?)
    func loadStats()
    func getNumberOfSections() -> Int
    func getTextForHeaderInSection(_ section: Int) -> String
    func getNumberOfItemsInSection(_ section: Int) -> Int
    func getTextForItemAt(_ indexPath: IndexPath) -> String
    func getIndentLevelForItemAt(_ indexPath: IndexPath) -> Int
    func getCountForStatTypeAt(_ indexPath: IndexPath) -> Int
    func didSelectItemAt(_ indexPath: IndexPath)
}

class StatsPresenter: StatsPresenterProtocol {
    let coreDataManager: CoreDataManager
    weak var statsViewDelegate: StatsViewDelegate?
    
    var sections: [EntityStats] = [
        EntityStats(type: .movie),
        EntityStats(type: .tvShow),
        EntityStats(type: .person)
    ]
    
    init(coreDataManager: CoreDataManager = CoreDataManager.shared) {
        self.coreDataManager = coreDataManager
    }
    
    func setViewDelegate(_ statsViewDelegate: StatsViewDelegate?) {
        self.statsViewDelegate = statsViewDelegate
    }
    
    func loadStats() {
        // Load each entity types stats
        if let movieStatsIndex = sections.firstIndex(where: { $0.type == .movie }) {
            sections[movieStatsIndex].totalGuessed = coreDataManager.getNumberGuessedFor(category: .movie)
            //sections[movieStatsIndex].guessedWithoutHint = coreDataManager.getNumberGuessedWithoutHintFor(category: .movie)
            //sections[movieStatsIndex].guessedWithHint = coreDataManager.getNumberGuessedWithHintFor(category: .movie)
            sections[movieStatsIndex].totalRevealed = coreDataManager.getNumberRevealedFor(category: .movie)
        }
        if let tvShowStatsIndex = sections.firstIndex(where: { $0.type == .tvShow }) {
            sections[tvShowStatsIndex].totalGuessed = coreDataManager.getNumberGuessedFor(category: .tvShow)
            //sections[tvShowStatsIndex].guessedWithoutHint = coreDataManager.getNumberGuessedWithoutHintFor(category: .tvShow)
            //sections[tvShowStatsIndex].guessedWithHint = coreDataManager.getNumberGuessedWithHintFor(category: .tvShow)
            sections[tvShowStatsIndex].totalRevealed = coreDataManager.getNumberRevealedFor(category: .tvShow)
        }
        if let personStatsIndex = sections.firstIndex(where: { $0.type == .person }) {
            sections[personStatsIndex].totalGuessed = coreDataManager.getNumberGuessedFor(category: .person)
            //sections[personStatsIndex].guessedWithoutHint = coreDataManager.getNumberGuessedWithoutHintFor(category: .person)
            //sections[personStatsIndex].guessedWithHint = coreDataManager.getNumberGuessedWithHintFor(category: .person)
            sections[personStatsIndex].totalRevealed = coreDataManager.getNumberRevealedFor(category: .person)
        }
        
        statsViewDelegate?.reloadData()
    }
    
    func getNumberOfSections() -> Int {
        return sections.count
    }
    
    func getTextForHeaderInSection(_ section: Int) -> String {
        guard section < sections.count else { return "" }
        
        return sections[section].getEntityTypeName()
    }
    
    func getNumberOfItemsInSection(_ section: Int) -> Int {
        guard section < sections.count else { return 0 }
        
        return sections[section].numberOfStatRows
    }
    
    func getTextForItemAt(_ indexPath: IndexPath) -> String {
        guard indexPath.section < sections.count else { return "" }
        let section = sections[indexPath.section]
        
        let row = indexPath.row
        guard row < section.numberOfStatRows else { return "" }
        
        return section.getNameForStatTypeAtIndex(index: row)
    }
    
    func getIndentLevelForItemAt(_ indexPath: IndexPath) -> Int {
        guard indexPath.section < sections.count else { return 0 }
        let section = sections[indexPath.section]
        
        let row = indexPath.row
        guard row < section.numberOfStatRows else { return 0 }
        
        return section.getIndentLevelForStatTypeAt(index: row)
    }
    
    func getCountForStatTypeAt(_ indexPath: IndexPath) -> Int {
        guard indexPath.section < sections.count else { return 0 }
        let section = sections[indexPath.section]
        
        let row = indexPath.row
        guard row < section.numberOfStatRows else { return 0 }
        
        return section.getCountForStatTypeAt(index: row)
    }
    
    func didSelectItemAt(_ indexPath: IndexPath) {
        guard indexPath.section < sections.count else { return }
        let section = sections[indexPath.section]
        
        let row = indexPath.row
        guard row < section.numberOfStatRows else { return }
        
        print("** DO SOMETHING?")
    }
}
