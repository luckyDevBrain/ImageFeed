//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Kirill on 14.08.2024.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private let tokenKey = "BearerToken"
    
    init() {
        KeychainWrapper.standard.removeObject(forKey: tokenKey)
    }
    
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let token = newValue {
                _ = KeychainWrapper.standard.set(token, forKey: tokenKey)
            } else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
        }
    }
}
