//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Kirill on 14.08.2024.
//

import UIKit

final class SplashViewController: UIViewController {
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let oauth2TokenStorage = OAuth2TokenStorage()
    let oauth2Service = OAuth2Service.shared
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if oauth2TokenStorage.token != nil {
            switchToTabBarController()
        } else {
            performSegue(withIdentifier: ShowAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { assertionFailure("Invalid Configuration")
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController else {
                assertionFailure("Failed to prepare for \(ShowAuthenticationScreenSegueIdentifier)")
                return
            }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true) // { [weak self] in
        }
    }
    /* guard let self = self else { return }
     // self.fetchOAuthToken(code)
     }
     }
     
     private func fetchOAuthToken(_ code: String) {
     oauth2Service.fetchOAuthToken(code) { [weak self] result in
     guard let self = self else { return }
     switch result {
     case .success:
     self.switchToTabBarController()
     case .failure(let error):
     print("Failed to fetch OAuth token: \(error)")
     // TODO [Sprint 11]: Add proper error handling
     }
     }
     }
     }
     */
