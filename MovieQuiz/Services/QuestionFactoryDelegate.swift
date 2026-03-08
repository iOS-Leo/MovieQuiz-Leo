//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Leo Gabuev on 02.01.2026.
//

import Foundation
protocol QuestionFactoryDelegate: AnyObject {               
    func didReceiveNextQuestion(question: QuizQuestion?)
}
