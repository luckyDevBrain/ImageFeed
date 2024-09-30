//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Kirill on 30.09.2024.
//

import Foundation

protocol ProfileViewInput: AnyObject {
    var presenter: ProfileViewOutput? { get set }
}

protocol ProfileViewOutput: AnyObject {
    var view: ProfileViewInput? { get set }
    var avatarURL: URL? { get }
    var profile: Profile? { get }
    
    func addAvatarObserver(with block: @escaping () -> Void)
    func logOut()
}

class ProfileViewPresenter {
    
    weak var view: ProfileViewInput?
    
    // MARK: - Singleton
    
    private let profileService = ProfileService.shared
    private let profileLogoutService = ProfileLogoutService.shared
    
    // MARK: - Properties
    
    private let tokenStorage = OAuth2TokenStorage()
    private var profileImageServiceObserver: NSObjectProtocol?
    
    init(view: ProfileViewInput?) {
        self.view = view
    }
}

extension ProfileViewPresenter: ProfileViewOutput {
    
    var avatarURL: URL? {
        guard let profileImageURL = ProfileImageService.shared.avatarURL
        else { return nil }
        return URL(string: profileImageURL)
    }
    
    var profile: Profile? {
        profileService.profile
    }
    
    func addAvatarObserver(with block: @escaping () -> Void) {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { _ in
                block()
            }
    }
    
    func logOut() {
        profileLogoutService.logout()
    }
}
