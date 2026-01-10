//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Leo Gabuev on 03.01.2026.
//

import Foundation
import UIKit

final class ResultAlertPresenter  {
    func show(in viewController : UIViewController , model :  AlertModel) {
        let alert = UIAlertController (
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
                    model.completion()
                }
        alert.addAction(action)

                viewController.present(alert, animated: true, completion: nil)
            }
    
    }
    
   
