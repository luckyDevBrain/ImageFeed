//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Kirill on 01.08.2024.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    private let oauth2TokenStorage = OAuth2TokenStorage()
    
    private var avatarImageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "avatar"))
        view.layer.cornerRadius = 35
        view.clipsToBounds = true
        return view
    }()
    
    private var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Кузнецова"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        return label
    }()
    
    private var loginNameLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_kuz"
        label.textColor = UIColor(named: "subTextColor")
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.textColor = .white
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
        button.tintColor = UIColor(named: "colorRed")
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBlack
        
        setupConstraints()
        
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
    }
    
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
    
    @objc private func didTapLogoutButton() {
        if descriptionLabel.text == "Hello, world!" {
            descriptionLabel.text = "Ура, теперь у меня миллион подписчиков!"
        } else {
            descriptionLabel.text = "Hello, world!"
        }
        performLogout()
        print("Logout tapped")
    }
    
    private func performLogout() {
        // Реальная логика выхода из аккаунта
        // Например, удаление токена из хранилища и переход на экран входа
        oauth2TokenStorage.token = nil
        switchToLoginScreen()
    }
    
    private func switchToLoginScreen() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let loginViewController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "SplashViewController")
        window.rootViewController = loginViewController
    }
}
