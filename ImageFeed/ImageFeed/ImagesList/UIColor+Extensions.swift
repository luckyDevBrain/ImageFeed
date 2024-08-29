//
//  UIColor+Extensions.swift
//  ImageFeed
//
//  Created by Kirill on 29.07.2024.
//

import UIKit

// Расширение для UIColor для работы с HEX значениями
extension UIColor {
    convenience init(hex: String) {
        // Удаление всех символов, кроме шестнадцатеричных
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            // Некорректное значение HEX, устанавливаем цвет по умолчанию (черный)
            (a, r, g, b) = (255, 0, 0, 0)
            print("Invalid HEX string, setting color to default (black).")
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
