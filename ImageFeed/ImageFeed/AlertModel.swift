//
//  AlertModel.swift
//  ImageFeed
//
//  Created by Kirill on 21.09.2024.
//

import Foundation

enum AlertButton: String {
    case okButton = "OK"
    case yesButton = "Да"
    case noButton = "Нет"
    case cancelButton = "Не надо"
    case retryButton = "Повторить"
    
    var accessibilityIdentifier: String {
        return self.rawValue
    }
    
    var title: String {
        return self.rawValue
    }
}

struct AlertModel {
    let title: String
    let message: String
    let buttons: [AlertButton]
    let identifier: String
    let completion: () -> Void
}
