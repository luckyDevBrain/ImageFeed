//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Kirill on 24.09.2024.
//

import Foundation
import WebKit

final class ProfileLogoutService {
   static let shared = ProfileLogoutService()
  
   private init() { }
    
    let imageListService = ImagesListService.shared
   func logout() {
      cleanCookies()
      cleanUserData()
      switchToRootViewController()
   }

   private func cleanCookies() {
      HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
      WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
         records.forEach { record in
            WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
         }
      }
   }
    
    private func cleanUserData() {
        OAuth2TokenStorage().token = nil
        ProfileService.shared.cleanProfile()
        ProfileImageService.shared.cleanAvatar()
        imageListService.cleanImagesList()
    }
    
    private func switchToRootViewController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        window.rootViewController = SplashViewController()
        window.makeKeyAndVisible()
        UIView.transition(with: window, duration: 0.3,options: [.transitionCrossDissolve], animations: nil, completion: nil)
    }
}
