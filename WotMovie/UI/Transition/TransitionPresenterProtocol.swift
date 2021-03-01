//
//  TransitionPresenterProtocol.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-01-30.
//

import Foundation

protocol TransitionPresenterProtocol: NSObject {
    func setEntityAsRevealed(id: Int, isCorrect: Bool)
    func setEntityAsFavorite(id: Int, entityWasAdded: Bool)
    func presentNextQuestion(currentQuestionID: Int)
}
