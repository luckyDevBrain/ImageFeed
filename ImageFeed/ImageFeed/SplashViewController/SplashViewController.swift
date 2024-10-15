//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Kirill on 14.08.2024.
//

import Foundation
import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Singleton
    
    let oAuth2Service = OAuth2Service.shared
    private let profileService = ProfileService.shared
    let profileImageService = ProfileImageService.shared
    
    // MARK: - Private Properties
    
    private let storage = OAuth2TokenStorage()
    
    // MARK: - Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = storage.token {
            fetchProfile(token)
        } else {
            print("[SplashViewController: viewDidAppear]: ERROR: the token was not found")
        }
        setUpSplashScreen()
        showAuthViewController()
    }
    
    // MARK: - Navigation
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        window.rootViewController = TabBarController()
    }
    
    private func showAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            print("[SplashViewController: showAuthViewController]: ERROR: with AuthViewController")
            return
        }
        authViewController.delegate = self
        
        let navigationController = UINavigationController(rootViewController: authViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    
    private func setUpSplashScreen() {
        let splashImageView = UIImageView()
        splashImageView.translatesAutoresizingMaskIntoConstraints = false
        splashImageView.image = UIImage.splashScreenLogo
        splashImageView.backgroundColor = UIColor.ypBlack
        view.addSubview(splashImageView)
        splashImageView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        splashImageView.widthAnchor.constraint(equalToConstant: 75).isActive = true
        splashImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        splashImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success(let profile):
                self?.profileImageService.fetchProfileImageURL(username: profile.username) {_ in }
                self?.switchToTabBarController()
                print("[SplashViewController: fetchProfile]: Profile fetched successfully")
            case .failure(let error):
                print("[SplashViewController: fetchProfile]: Failed to fetch profile: \(error)")
                break
            }
        }
    }
}

// MARK: - Extensions

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        
        guard let token = storage.token else {
            return
        }
        
        fetchProfile(token)
    }
}
