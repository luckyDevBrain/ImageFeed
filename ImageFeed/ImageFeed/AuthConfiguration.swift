//
//  AuthConfiguration.swift
//  ImageFeed
//
//  Created by Kirill on 11.08.2024.
//

import Foundation

enum Constants {
    static let accessKey = "nVfXTJMJtzNl0VD5sbctnSDXz3yg8Imzj205X4lxKcw"
    static let secretKey = "h7imQS1BJ6AI8kzYSW_ZRouqCfMA7Zpty855DjppoSc"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL: URL = {
        guard let url = URL(string: "https://api.unsplash.com") else {
            fatalError("Invalid URL string")
        }
        return url
    }()
    static let defaultPhotos = "https://api.unsplash.com/photos/"
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: Constants.accessKey,
                                 secretKey: Constants.secretKey,
                                 redirectURI: Constants.redirectURI,
                                 accessScope: Constants.accessScope,
                                 defaultBaseURL: (Constants.defaultBaseURL),
                                 authURLString: Constants.unsplashAuthorizeURLString)
    }
}
