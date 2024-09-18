//
//  ProfileModels.swift
//  ImageFeed
//
//  Created by Kirill on 17.09.2024.
//

import Foundation

struct ProfileResult: Codable {
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?
}

struct Profile {
    let profileResult: ProfileResult
    var username: String { profileResult.username }
    var name: String { profileResult.firstName + " " + (profileResult.lastName ?? "")}
    var loginName: String { "@" + username}
    var bio: String { profileResult.bio ?? ""}
}

struct UserResult: Codable {
    let profileImage: UserImage
}

struct UserImage: Codable {
    let small: String
    let medium: String
    let large: String
}
