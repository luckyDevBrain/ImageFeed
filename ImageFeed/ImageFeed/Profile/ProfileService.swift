//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Kirill on 31.08.2024.
//

import UIKit

final class ProfileService {
    
    //MARK: - Singletone
    static let shared = ProfileService()
    private init() {}
    
    //MARK: - Properties
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    private(set) var profile: Profile?

    
    private enum ProfileServiceError: Error {
        case invalidRequest
        case decodingFailed
    }
    
    //MARK: - Methods
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
    guard Thread.isMainThread else {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.fetchProfile(token, completion: completion)
        }
        return
    }
    
    guard task == nil else {
        completion(.failure(ProfileServiceError.invalidRequest))
        return
    }
    
    guard let request = makeUserProfileRequest(token: token) else {
        completion(.failure(ProfileServiceError.invalidRequest))
        print("invalid profile data request")
        return
    }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    let profile = Profile(profileResult: data)
                    self.profile = profile
                    completion(.success(profile))
                    print("[ProfileService: fetchProfile]: Successed to decode Profile")
                case .failure(let error):
                    completion(.failure(ProfileServiceError.decodingFailed))
                    print("[ProfileService: fetchProfile]: Profile load error \(error)")
                }
                self.task = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeUserProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "/me", relativeTo: Constants.defaultBaseURL) else {
                    assertionFailure("[ProfileService: makeProfileDataRequest]: Unable to create URL")
                    return nil
                }
    
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print("URL Request: \(request)")
        return request
    }
}

extension ProfileService {
    func cleanProfile() {
        self.profile = nil
    }
}
