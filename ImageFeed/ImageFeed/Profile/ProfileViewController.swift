//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Kirill on 01.08.2024.
//

import UIKit
import Kingfisher
import SwiftKeychainWrapper

final class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    private let profileService = ProfileService.shared
    private let oAuth2TokenStorage = OAuth2TokenStorage.shared
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "avatar")
        imageView.layer.masksToBounds = false
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Кузнецова"
        label.textColor = UIColor(named: "ypWhite")
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        return label
    }()
    
    private var loginNameLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_kuz"
        label.textColor = UIColor(named: "ypGray")
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello world!"
        label.textColor = UIColor(named: "ypWhite")
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    private var logoutButton: UIButton = {
        let button = UIButton(type: .custom)
        if let image = UIImage(named: "logout_button") {
            button.setImage(image, for: .normal)
        } else {
            print("Error: Image 'logout_button' not found")
        }
        button.tintColor = UIColor(named: "ypRed")
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBlack
        
        setupConstraints()
        updateProfileDetails()
        setupProfileImageObserver()
        
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
    }
    
    // MARK: - Setup
    
    private func setupConstraints() {
        [avatarImageView, nameLabel, loginNameLabel, descriptionLabel, logoutButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 76),
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: loginNameLabel.leadingAnchor),
            
            
        ])
    }
    
    // MARK: - Update Profile
    
    private func updateProfileDetails() {
        guard let profile = profileService.profile else {
            print("No profile data found")
            return
        }
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
    
    private func setupProfileImageObserver() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main) { [weak self] _ in
                    self?.updateAvatar()
                }
        updateAvatar()
    }
    
    private func updateAvatar() {
        guard let profileImageURL = profileImageService.avatarURL,
              let url = URL(string: profileImageURL)
        else {
            return
        }
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(with: url, placeholder: UIImage(named: "avatarPlaceholder"), options: [.processor(processor)])
    }
    
    // MARK: - Actions
    
    @objc private func didTapLogoutButton() {
        performLogout()
    }
    
    private func performLogout() {
        oAuth2TokenStorage.token = nil
        KeychainWrapper.standard.removeObject(forKey: "Bearer Token")
        switchToLoginScreen()
    }
    
    private func switchToLoginScreen() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let loginViewController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "SplashViewController")
        window.rootViewController = loginViewController
    }
}
