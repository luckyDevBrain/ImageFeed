//
//  AlertPresenter.swift
//  ImageFeed
//
//  Created by Kirill on 21.09.2024.
//

import UIKit

struct AlertPresenter {
    
    static func showAlert(on vc: UIViewController, model: AlertModel) {
        showBasicAlert(on: vc,
                       title: model.title,
                       message: model.message,
                       buttons: model.buttons,
                       identifier: model.identifier,
                       completion: model.completion)
    }
    
    private static func showBasicAlert(on vc: UIViewController,
                                       title: String,
                                       message: String,
                                       buttons: [AlertButton],
                                       identifier: String,
                                       completion: @escaping () -> ()) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = .systemBackground
        
        alert.view.accessibilityIdentifier = identifier
        
        for button in buttons {
            switch button {
            case .cancelButton, .noButton:
                let action = UIAlertAction(title: button.title, style: .default, handler: nil)
                action.accessibilityIdentifier = button.accessibilityIdentifier
                alert.addAction(action)
            default:
                let action = UIAlertAction(title: button.title, style: .default) { _ in
                    completion()
                }
                action.accessibilityIdentifier = button.accessibilityIdentifier
                alert.addAction(action)
                alert.preferredAction = action
            }
        }
        
        DispatchQueue.main.async {
            vc.present(alert, animated: true)
        }
    }
}
