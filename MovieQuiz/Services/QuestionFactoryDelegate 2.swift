//
//  QuestionFactoryDelegate 2.swift
//  MovieQuiz
//
//  Created by Leo Gabuev on 03.01.2026.
//


protocol QuestionFactoryDelegate: AnyObject {               
    func didReceiveNextQuestion(question: QuizQuestion?)
}