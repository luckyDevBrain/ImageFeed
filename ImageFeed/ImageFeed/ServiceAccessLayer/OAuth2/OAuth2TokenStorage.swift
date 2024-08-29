//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Kirill on 14.08.2024.
//

import Foundation

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    var token: String? {
        get {
            let token = storage.string(forKey: Keys.tokenStorage.rawValue)
            print("Token read: \(String(describing: token))")
            return token
        }
        set {
            storage.set(newValue, forKey: Keys.tokenStorage.rawValue)
            print("Token write: \(String(describing: token))")
        }
    }
    
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case tokenStorage
    }
}
