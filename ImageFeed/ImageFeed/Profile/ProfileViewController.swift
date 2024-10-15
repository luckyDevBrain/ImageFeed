//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Kirill on 01.08.2024.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    // MARK: - Public Properties
    
    var presenter: ProfileViewOutput?
    
    // MARK: - Private Properties
    
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
        let button = UIButton()
        button.setImage(UIImage(named: "logout_button"), for: .normal)
        button.tintColor = UIColor(named: "ypRed")
        button.accessibilityIdentifier = "LogoutButton"
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.viewDidLoad()
        
        updateLabelText()
        setup()
    }
    
    // MARK: - Public Methods
    
    func updateLabelText() {
        if let profile = presenter?.profile {
            nameLabel.text = profile.name
            loginNameLabel.text = profile.loginName
            descriptionLabel.text = profile.bio
        } else {
            print("profile was not found")
        }
    }
    
    // MARK: - Private Methods
    
    private func setup() {
        setupView()
        setupConstraints()
        setupActions()
    }
    
    private func setupView() {
        view.backgroundColor = .ypBlack
        
        [avatarImageView, nameLabel, loginNameLabel, descriptionLabel, logoutButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        setupUserImageConstraints()
        setupLogoutButtonConstraints()
        setupUserNameLabelConstraints()
        setupUserLoginLabelConstraints()
        setupUserDescriptionLabelConstraints()
    }
    
    private func setupActions() {
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
    }
    
    private func setupUserImageConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 76)
        ])
    }
    
    private func setupLogoutButtonConstraints() {
        NSLayoutConstraint.activate([
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
        ])
    }
    
    private func setupUserNameLabelConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8)
        ])
    }
    
    private func setupUserLoginLabelConstraints() {
        NSLayoutConstraint.activate([
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)
        ])
    }
    
    private func setupUserDescriptionLabelConstraints() {
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: loginNameLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func didTapLogoutButton() {
        showLogoutAlert()
    }
    
    func showLogoutAlert() {
        let alertModel = AlertModel(
            title: "Пока, пока!",
            message: "Уверены что хотите выйти?",
            buttons: [.yesButton, .noButton],
            identifier: "Logout",
            completion: { [weak self] in
                self?.presenter?.logOut()
            }
        )
        AlertPresenter.showAlert(on: self, model: alertModel)
    }
}

// MARK: - Extensions

extension ProfileViewController: ProfileViewInput {
    func updateAvatar(_ avatarURL: URL?) {
        avatarImageView.kf.setImage(with: avatarURL)
    }
}
