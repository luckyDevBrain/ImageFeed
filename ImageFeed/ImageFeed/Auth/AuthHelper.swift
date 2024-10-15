//
//  AuthHelper.swift
//  ImageFeed
//
//  Created by Kirill on 27.09.2024.
//

import Foundation

// MARK: - Protocol

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
}

final class AuthHelper: AuthHelperProtocol {
    
    // MARK: - Public Properties
    
    let configuration: AuthConfiguration
    
    var authURL: URL? {
        guard var urlComponents = URLComponents(string: configuration.authURLString) else {
            assertionFailure("Invalid authorization URL string: \(configuration.authURLString)")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: configuration.accessScope)
        ]
        
        return urlComponents.url
    }
    
    // MARK: - Public Methods
    
    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }
    
    func authRequest() -> URLRequest? {
        guard let authURL else {
            return nil
        }
        
        return URLRequest(url: authURL)
    }
    
    func code(from url: URL) -> String? {
        if let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == "/oauth/authorize/native",
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}
