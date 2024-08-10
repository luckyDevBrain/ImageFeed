//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Kirill on 01.08.2024.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    // UI Elements
    private var avatarImageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "avatar"))
        view.layer.cornerRadius = 35
        view.clipsToBounds = true
        return view
    }()
    
    // Name Label
    private var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Кузнецова"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    // Login Name Label
    private var loginNameLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_kuz"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    // Description Label
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    // Logout Button
    private var logoutButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "logout_button")!, for: .normal)
        button.tintColor = .red
        return button
    }()
    
    // Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupConstraints()
        
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
    }
    
    // Constraints Setup
    private func setupConstraints() {
        // Add subviews and set translatesAutoresizingMaskIntoConstraints
        [avatarImageView, nameLabel, loginNameLabel, descriptionLabel, logoutButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
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
