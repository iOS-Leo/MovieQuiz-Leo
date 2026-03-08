//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Leo Gabuev on 03.01.2026.
//

import Foundation
struct AlertModel {
    let title : String
    let message : String
    let buttonText : String
    let completion : () -> Void
}
