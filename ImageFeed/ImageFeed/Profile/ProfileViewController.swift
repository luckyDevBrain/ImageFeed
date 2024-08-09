//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Kirill on 01.08.2024.
//

import UIKit

final class ProfileViewController: UIViewController {
    // Outlets
    private var avatarImageView: UIImageView!
    private var nameLabel: UILabel!
    private var loginNameLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var logoutButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
    }
    
    // UI Setup
    private func setupUI() {
        // Avatar ImageView
        avatarImageView = UIImageView(image: UIImage(named: "avatar"))
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.layer.cornerRadius = 35
        avatarImageView.clipsToBounds = true
        view.addSubview(avatarImageView)
        
        // Name Label
        nameLabel = UILabel()
        nameLabel.text = "Екатерина Кузнецова"
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        // Login Name Label
        loginNameLabel = UILabel()
        loginNameLabel.text = "@ekaterina_kuz"
        loginNameLabel.textColor = .gray
        loginNameLabel.font = UIFont.systemFont(ofSize: 14)
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
        
        // Description Label
        descriptionLabel = UILabel()
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.textColor = .white
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        // Logout Button
        logoutButton = UIButton.systemButton(with: UIImage(named: "logout_button")!, target: self, action: #selector(didTapLogoutButton))
        logoutButton.tintColor = .red
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
    }
    
    // Constraints Setup
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Avatar ImageView
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            
            // Name Label
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            
            // Login Name Label
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            loginNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            
            // Description Label
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            
            // Logout Button
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
    
    // Logout Button Action
    @objc private func didTapLogoutButton() {
        // Implement logout functionality
        if descriptionLabel.text == "Hello, world!" {
                    descriptionLabel.text = "Ура, теперь у меня миллион подписчиков!"
                } else {
                    descriptionLabel.text = "Hello, world!"
                }
        print("Logout tapped")
    }
}
