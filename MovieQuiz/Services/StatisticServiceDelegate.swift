//
//  StatisticServiceDelegate.swift
//  MovieQuiz
//
//  Created by Leo Gabuev on 08.01.2026.
//

import Foundation
protocol StatisticServiceDelegate: AnyObject {
    func didEndGame(correct: Int, total: Int)
    func getStatisticText(currentCorrect: Int, totalQuestions: Int) -> String
}
