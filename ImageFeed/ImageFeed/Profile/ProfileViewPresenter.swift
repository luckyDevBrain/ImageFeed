//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Kirill on 30.09.2024.
//

import Foundation

// MARK: - Protocol

protocol ProfileViewInput: AnyObject {
    var presenter: ProfileViewOutput? { get set }
    func updateAvatar(_ avatarURL: URL?)
}

protocol ProfileViewOutput: AnyObject {
    var view: ProfileViewInput? { get set }
    var profile: Profile? { get }
    
    func viewDidLoad()
    func logOut()
}

class ProfileViewPresenter {
    
    // MARK: - Singleton
    
    private let profileService = ProfileService.shared
    private let profileLogoutService = ProfileLogoutService.shared
    
    // MARK: - Public Properties
    
    weak var view: ProfileViewInput?
    var avatarURL: URL? {
        guard let profileImageURL = ProfileImageService.shared.avatarURL
        else { return nil }
        return URL(string: profileImageURL)
    }
    
    init(view: ProfileViewInput?) {
        self.view = view
    }
    
    // MARK: - Private Properties
    
    private let tokenStorage = OAuth2TokenStorage()
    private var profileImageServiceObserver: NSObjectProtocol?
}

// MARK: - Extensions

extension ProfileViewPresenter: ProfileViewOutput {
    
    func viewDidLoad() {
        
        view?.updateAvatar(avatarURL)
        
        addAvatarObserver { [weak self] in
            guard let self else { return }
            self.view?.updateAvatar(self.avatarURL)
        }
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
