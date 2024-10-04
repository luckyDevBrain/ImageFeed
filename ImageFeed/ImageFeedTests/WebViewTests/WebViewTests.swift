//
//  WebViewTests.swift
//  ImageFeed
//
//  Created by Kirill on 03.10.2024.
//

import XCTest
@testable import ImageFeed

final class WebViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        
        let presenter = WebViewPresenterSpy()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let webViewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController")
        
        if let view = webViewController as? WebViewViewControllerProtocol {
            view.presenter = presenter
            presenter.view = view
        }
        
        _ = webViewController.view
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsLoadRequest() {
        
        let webViewController = WebViewViewControllerDummy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        
        webViewController.presenter = presenter
        presenter.view = webViewController
        
        presenter.viewDidLoad()
        
        XCTAssertTrue(webViewController.loadRequestDidCall)
    }
    
    func testProgressDoesntHide() {
        
        let presenter = WebViewPresenter(authHelper: AuthHelper())
        let progress: Float = 0.7
        
        let shouldHideProgress = presenter.shouldHideProgress(progress)
        
        XCTAssertFalse(shouldHideProgress)
    }
    
    func testProgressHides() {
        
        let presenter = WebViewPresenter(authHelper: AuthHelper())
        let progress: Float = 1
        
        let shouldHideProgress = presenter.shouldHideProgress(progress)
        
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthURL() {
        
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        
        let urlString = authHelper.authURL?.absoluteString ?? ""
        
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
        XCTAssertTrue(urlString.contains(configuration.authURLString))
    }
    
    func testCodeFromURL() {
        
        let authHelper = AuthHelper()
        let codeValue = "code value"
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        urlComponents.queryItems = [URLQueryItem(name: "code", value: codeValue)]
        let authURL = urlComponents.url!
        
        let code = authHelper.code(from: authURL)
        
        XCTAssertEqual(code, codeValue)
    }
}
