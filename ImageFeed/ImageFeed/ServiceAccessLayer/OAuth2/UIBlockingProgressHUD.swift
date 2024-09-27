//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Kirill on 31.08.2024.
//

import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {

    //MARK: - Properties
    
    private static var window: UIWindow? {
        var window: UIWindow?
        DispatchQueue.main.async {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            window = windowScene?.windows.first
        }
        return window
    }
    
    //MARK: - Methods
    
    static func show() {
        DispatchQueue.main.async {
            window?.isUserInteractionEnabled = false
            ProgressHUD.animate()
        }
    }
    
    static func dismiss() {
        DispatchQueue.main.async {
            window?.isUserInteractionEnabled = true
            ProgressHUD.dismiss()
        }
    }
}
