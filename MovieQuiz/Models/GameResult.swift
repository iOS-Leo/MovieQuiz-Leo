//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Leo Gabuev on 08.01.2026.
//

import Foundation
struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan (_ another : GameResult) -> Bool {
        correct > another.correct
    }
}
