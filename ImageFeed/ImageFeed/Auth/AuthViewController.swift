//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Kirill on 11.08.2024.
//

import UIKit
import ProgressHUD

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class AuthViewController: UIViewController {
    
    //MARK: - Singletone
    private let oAuth2Service = OAuth2Service.shared
    private let oAuth2TokenStorage = OAuth2TokenStorage.shared
    
    // MARK: - Properties
    private let ShowWebViewSegueIdentifier = "ShowWebView"
    var delegate: AuthViewControllerDelegate?
    private var alertPresenter: AlertPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        self.alertPresenter = alertPresenter
        
        configureBackButton()
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
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "goBackButton")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "goBackButton")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "ypDark") // 4
    }
}

// MARK: - Extension
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        navigationController?.popToRootViewController(animated: true)
        UIBlockingProgressHUD.show()
        DispatchQueue.global().async {
            self.oAuth2Service.fetchOAuthToken(with: code) { [weak self] result in
                UIBlockingProgressHUD.dismiss()
                guard let self else { preconditionFailure("Couldn't load AuthViewController") }
                switch result {
                case .success(let token):
                    oAuth2TokenStorage.token = token
                    print("Token fetched successfully: \(token)")
                    delegate?.didAuthenticate(self)
                case .failure(let error):
                    let completion = { [weak self] in
                        guard let self else { return }
                        self.navigationController?.popViewController(animated: true)
                    }
                    let viewModel = AlertModel(title: "Что-то пошло не так(",
                                               message: "Не удалось войти в систему",
                                               button: "Ok",
                                               completion: completion)
                    alertPresenter?.showAlert(result: viewModel)
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}
