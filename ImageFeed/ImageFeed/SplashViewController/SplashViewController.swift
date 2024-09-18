//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Kirill on 14.08.2024.
//

import UIKit
import SwiftKeychainWrapper

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class SplashViewController: UIViewController {
    
    //MARK: - Singletone
    private let oAuth2TokenStorage = OAuth2TokenStorage.shared
    private let oAuth2Service = OAuth2Service.shared
    private let profileImageService = ProfileImageService.shared
    private let profileService = ProfileService.shared
    
    // MARK: - Properties
    
    private var logoImageView: UIImageView?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addLogoImageView()
        view.backgroundColor = .ypBlack
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = oAuth2TokenStorage.token {
            fetchProfile(token)
        } else {
            showAuthViewController()
        }
    }
    
    // MARK: - Private Methods
    private func addLogoImageView() {
        let logoImageView = UIImage(named: "splash_screen_logo")
        let imageView = UIImageView(image: logoImageView)
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        self.logoImageView = imageView
    }
    
    private func showAuthViewController() {
        let authViewController = UIStoryboard(name: "Main",
                                              bundle: .main
        ).instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController
        guard let authViewController else { return }
        authViewController.delegate = self
        
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true, completion: nil)
    }
    
    private func showTabBarController() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first
        else {
            assertionFailure("Invalid Configuration")
            return }
        
        window.rootViewController = UIStoryboard(name: "Main",
                                                 bundle: .main
        ).instantiateViewController(withIdentifier: "TabBarViewController")
    }
}

// MARK: - Extensions
extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        
        guard let token = oAuth2TokenStorage.token else {
            print("token error ")
            return
        }
        fetchProfile(token)
    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self else { return }
            
            switch result {
            case .success(let profile):
                self.profileImageService.fetchProfileImageURL(token: token, username: profile.username) { _ in }
                self.showTabBarController()
            case .failure:
                print("Load profile error")
                break
            }
        }
    }
}
