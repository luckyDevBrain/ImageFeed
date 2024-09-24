//
//  DateFormatterAdd.swift
//  ImageFeed
//
//  Created by Kirill on 24.09.2024.
//

import Foundation

final class DateFormatterAdd {
    static let shared = DateFormatterAdd()
    private init() {}
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    lazy var iso8601DateFormatter = ISO8601DateFormatter()
}
