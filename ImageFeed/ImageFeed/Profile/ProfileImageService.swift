//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Kirill on 01.09.2024.
//

import UIKit
 
enum ProfileImageServiceError: Error {
    case invalidRequest
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
}

final class ProfileImageService {
    static let shared = ProfileImageService()
    private init() {}
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private(set) var avatarURL: String?
    
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private var lastUsername: String?
    
    func fetchProfileImageURL(token: String, username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.fetchProfileImageURL(token: token, username: username, completion)
            }
            return
        }
        
        guard task == nil else {
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        
        guard let request = makeUserProfileImageRequest(token: token, username: username) else {
            completion(.failure(ProfileImageServiceError.invalidRequest))
            print("Invalid profile image request")
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let image):
                    let profileImageURL = image.profileImage.small
                    self.avatarURL = profileImageURL
                    NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": profileImageURL])
                    print("Profile image URL fetched successfully")
                case .failure(let error):
                    completion(.failure(error))
                    print("Profile image URL could not be fetched successfully: \(error)")
                }
                self.task = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeUserProfileImageRequest(token: String, username: String) -> URLRequest? {
        guard let url = URL(string: "/users/\(username)", relativeTo: Constants.defaultBaseURL) else {
            assertionFailure("Не удалось создать URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

extension ProfileImageService {
    func cleanAvatar() {
        self.avatarURL = nil
    }
}
