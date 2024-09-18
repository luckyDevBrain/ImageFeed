//
//  Constants.swift
//  ImageFeed
//
//  Created by Kirill on 11.08.2024.
//

import Foundation

enum Constants {
    static  let accessKey = "nVfXTJMJtzNl0VD5sbctnSDXz3yg8Imzj205X4lxKcw"
    static  let secretKey = "h7imQS1BJ6AI8kzYSW_ZRouqCfMA7Zpty855DjppoSc"
    static  let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static  let accessScope = "public+read_user+write_likes"
    static  let defaultBaseURL = URL(string: "https://api.unsplash.com/")
    static let defaultURL = URL(string: "https://unsplash.com/")
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let reuseIdentifier = "ImagesListCell"
    static let code = "code"
    static let path = "/oauth/authorize/native"
}

enum AuthServiceError: Error {
    case invalidRequest
}

