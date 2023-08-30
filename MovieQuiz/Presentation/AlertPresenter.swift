//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Анастасия on 22.08.2023.
//

import Foundation
import UIKit

class AlertPresenter {
    static func showAlert(alertModel: AlertModel, delegate: UIViewController) {
        let alert = UIAlertController(title: alertModel.title,
                                      message: alertModel.text,
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
            alertModel.completion?()
        }
        alert.addAction(action)
        delegate.present(alert, animated: true, completion: nil)
    }
}
