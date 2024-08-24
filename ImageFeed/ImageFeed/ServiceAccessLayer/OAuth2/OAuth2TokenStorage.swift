//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Kirill on 14.08.2024.
//

import Foundation

final class OAuth2TokenStorage {
    
    static let shared = OAuth2TokenStorage()
    
    private let storage = UserDefaults.standard
    private let tokenKey = "OAuthToken"
    
    var token: String? {
        get {
            return storage.string(forKey: tokenKey)
        }
        set {
            if let token = newValue {
                storage.set(token, forKey: tokenKey)
            } else {
                storage.removeObject(forKey: tokenKey)
            }
        }
    }
}
