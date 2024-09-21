//
//  AlertModel.swift
//  ImageFeed
//
//  Created by Kirill on 21.09.2024.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let button: String
    let completion: (() -> Void)
    var secondButton: String?
    var secondCompletion: (() -> Void)?
}
