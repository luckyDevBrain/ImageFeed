//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Kirill on 11.08.2024.
//

import UIKit
import WebKit

final class WebViewViewController: UIViewController {
    
    //MARK: - Properties
    weak var delegate: WebViewViewControllerDelegate?
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    //MARK: - Outlets
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        view.backgroundColor = .white
        loadAuthView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            setNeedsStatusBarAppearanceUpdate()
            
            estimatedProgressObservation = webView.observe(
                \.estimatedProgress,
                options: [],
                changeHandler: { [weak self] _, _ in
                    self?.updateProgress()
                })
        }
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: Constants.unsplashAuthorizeURLString) else {
            print("Error: Unable to create URLComponents for authorization.")
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            print("Error: Unable to create URL from URLComponents. Components: \(urlComponents)")
            return
        }
        
        print("Loading URL:", url.absoluteString)
        
        let request = URLRequest(url: url)
        webView.load(request)
        
    }
}
/*
 @IBAction private func didTapBackButton(_ sender: Any?) {
 delegate?.webViewViewControllerDidCancel(WebViewViewController())
 }
 */

//MARK: - Extensions
extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            decisionHandler(.cancel)
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            print("DEBUG:", "WebViewViewController Delegate called with code: \(code)")
        } else {
            decisionHandler(.allow)
            print("Error: No code found in URL.")
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url,
           let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == Constants.path,
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == Constants.code })
        {
            return codeItem.value
        } else {
            print("Error: Unable to extract code from URL: \(String(describing: navigationAction.request.url))")
            return nil
        }
    }
}
