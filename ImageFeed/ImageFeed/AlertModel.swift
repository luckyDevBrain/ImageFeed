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
    let firstActionButton: String
    let firstActionCompletion: (() -> Void)
    let secondActionButton: String?
    let secondActionCompletion: (() -> Void)?
}
