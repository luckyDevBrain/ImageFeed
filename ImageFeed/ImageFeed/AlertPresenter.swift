//
//  AlertPresenter.swift
//  ImageFeed
//
//  Created by Kirill on 17.09.2024.
//

import UIKit

protocol AlertPresenterProtocol {
    func showAlert(result: AlertModel)
}

struct AlertModel {
    let title: String
    let message: String
    let button: String
    let completion: (() -> Void)
    var secondButton: String?
    var secondCompletion: (() -> Void)?
}

final class AlertPresenter: UIAlertController, AlertPresenterProtocol {
    
    weak var delegate: UIViewController?
    
    func showAlert(result: AlertModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.button, style: .default) { _ in
            result.completion()
        }
        
        alert.addAction(action)
        
        if let secondButton = result.secondButton,
           let secondCompletion = result.secondCompletion {
            let secondAction = UIAlertAction(title: secondButton,
                                             style: .default) { _ in
                secondCompletion()
            }
            alert.addAction(secondAction)
        }
        
        delegate?.present(alert, animated: true)
    }
}
