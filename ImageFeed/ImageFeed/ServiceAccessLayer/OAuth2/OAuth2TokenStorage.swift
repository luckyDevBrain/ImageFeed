//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Kirill on 14.08.2024.
//

import Foundation
import SwiftKeychainWrapper


final class OAuth2TokenStorage {
    
    //MARK: - Singletone
    
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    //MARK: - Properties

    private let storage = KeychainWrapper.standard
    enum StorageKeys: String {
        case token
    }

    var token: String? {
        get {
            storage.string(forKey: StorageKeys.token.rawValue)
        }
        set {
            guard let newValue else {
                return
            }
            storage.set(newValue, forKey: StorageKeys.token.rawValue)
        }
    }
}

//MARK: - Extension
extension OAuth2TokenStorage {
    func cleanToken() {
        storage.removeObject(forKey: StorageKeys.token.rawValue)
    }
}
    
