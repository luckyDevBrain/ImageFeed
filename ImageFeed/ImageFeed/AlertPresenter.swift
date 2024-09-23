//
//  AlertPresenter.swift
//  ImageFeed
//
//  Created by Kirill on 21.09.2024.
//

import UIKit

protocol AlertPresenterProtocol {
    func showAlert(result: AlertModel)
}

final class AlertPresenter: UIAlertController, AlertPresenterProtocol {
    
    weak var delegate: UIViewController?
    
    func showAlert(result: AlertModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert)
        
        let firstAction = UIAlertAction(title: result.firstActionButton, style: .default) { _ in
            result.firstActionCompletion()
        }
        
        alert.addAction(firstAction)
        
        if let secondActionButton = result.secondActionButton,
           let secondActionCompletion = result.secondActionCompletion {
            let secondAction = UIAlertAction(title: secondActionButton,
                                             style: .default) { _ in
                secondActionCompletion()
            }
            alert.addAction(secondAction)
        }
        
        delegate?.present(alert, animated: true)
    }
}
