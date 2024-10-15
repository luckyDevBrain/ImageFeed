//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Kirill on 27.09.2024.
//

import Foundation

    // MARK: - Enums

enum WebViewConstants {
    static let unsplashAuthorizeURLString = Constants.unsplashAuthorizeURLString
}

    // MARK: - Protocl

protocol WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}

final class WebViewPresenter: WebViewPresenterProtocol {
    weak var view: WebViewViewControllerProtocol?
    private let authHelper: AuthHelperProtocol
    
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }
    
    // MARK: - Lifecycle
    
    func viewDidLoad() {
        guard let request = authHelper.authRequest() else {
            assertionFailure("Failed to construct authorization URLRequest")
            return
        }
        view?.load(request: request)
        didUpdateProgressValue(0)
    }
    
    // MARK: - Public Methods
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        view?.setProgressHidden(shouldHideProgress(newProgressValue))
    }
    
    func shouldHideProgress(_ value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
    
    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
}
