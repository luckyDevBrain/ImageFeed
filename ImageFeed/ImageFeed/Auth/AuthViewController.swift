//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Kirill on 11.08.2024.
//

import UIKit
import ProgressHUD

    // MARK: - Protocol

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    
    // MARK: - Singletone
    
    let oauth2Service = OAuth2Service.shared
    
    // MARK: - Properties
    
    private let ShowWebViewSegueIdentifier: String = "ShowWebView"
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBackButton()
    }
    
    // MARK: - Private Methods
    
    private func configureBackButton() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor.ypBlack
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else { fatalError("Failed to prepare for \(ShowWebViewSegueIdentifier)") }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

    // MARK: - Extension

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        navigationController?.popToRootViewController(animated: true)
        
        UIBlockingProgressHUD.show()
        
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case .success(let token):
                OAuth2TokenStorage().token = token
                print("[AuthViewController: webViewViewController]: Authorization success, actual token: \(token)")
                delegate?.didAuthenticate(self, didAuthenticateWithCode: code)
            case .failure:
                print("[AuthViewController: webViewViewController]: Authorization erro")
                showNetworkError()
            }
            
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
    
    func showNetworkError() {
        
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Ок",
                                   style: .default) { _ in }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
}
