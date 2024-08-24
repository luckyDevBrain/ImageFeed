//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Kirill on 11.08.2024.
//

import UIKit
import WebKit

fileprivate let UnsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController {
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        return webView
    }()
    
    weak var delegate: WebViewViewControllerDelegate?
    
    private let progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = UIColor(red: 0.1, green: 0.11, blue: 0.13, alpha: 1.0)
        progressView.progress = 0.5
        return progressView
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .custom)
        if let image = UIImage(named: "nav_back_button") {
            button.setImage(image, for: .normal)
        } else {
            print("Error: Image 'nav_back_button' not found")
        }
        return button
    }()
    
    override func viewDidLoad() {
            super.viewDidLoad()
            webView.navigationDelegate = self
            
            view.backgroundColor = .white
            
            setupWebView()
            setupNavigationBar()
            loadAuthView()
            
            backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
            
        }
        
        private func setupWebView() {
            webView = WKWebView()
            webView.navigationDelegate = self
            
            // Добавляем webView на экран
            view.addSubview(webView)
            webView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
        
        // Настройка навигационной панели
        private func setupNavigationBar() {
            // Создаем контейнер для кнопки и прогресс-бара
            let containerView = UIView()
            
            containerView.addSubview(backButton)
            containerView.addSubview(progressView)
            
            backButton.translatesAutoresizingMaskIntoConstraints = false
            progressView.translatesAutoresizingMaskIntoConstraints = false
            
            // Добавляем constraints для backButton и progressView внутри контейнера
            NSLayoutConstraint.activate([
                backButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                backButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4),
                
                progressView.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
                progressView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                progressView.centerYAnchor.constraint(equalTo: backButton.centerYAnchor)
            ])
            
            // Настройка размеров контейнера
            containerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
            containerView.heightAnchor.constraint(equalToConstant: 44).isActive = true
            
            // Добавляем контейнер в `navigationItem`
            let customBarButtonItem = UIBarButtonItem(customView: containerView)
            navigationItem.leftBarButtonItem = customBarButtonItem
        }
    
    enum WebViewConsants{
        static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    }
    
    @objc private func didTapBackButton() {
        delegate?.webViewViewControllerDidCancel(self)
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        webView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil)
        updateProgress()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.removeObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            context: nil)
    }
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?) {
            
            if keyPath == #keyPath(WKWebView.estimatedProgress) {
                updateProgress()
            } else {
                super.observeValue(
                    forKeyPath: keyPath,
                    of: object,
                    change: change,
                    context: context)
            }
        }
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: UnsplashAuthorizeURLString) else {
            print("Error: Unable to create URLComponents")
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            print("Error: Unable to create URL from URLComponents")
            return
        }
        
        print("Loading URL:", url.absoluteString)
        
        let request = URLRequest(url: url)
        webView.load(request)
        
       // updateProgress()
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            print("DEBUG:", "WebViewViewController Delegate called with code: \(code)")
            decisionHandler(.cancel)
            dismiss(animated: true)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}


