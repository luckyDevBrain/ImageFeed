//
//  WebViewDoubles.swift
//  ImageFeed
//
//  Created by Kirill on 29.09.2024.
//

import UIKit
@testable import ImageFeed

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    
    var viewDidLoadCalled: Bool = false
    
    var view: (any ImageFeed.WebViewViewControllerProtocol)?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {}
    func code(from url: URL) -> String? { nil }
}

final class WebViewViewControllerDummy: WebViewViewControllerProtocol {
    
    var presenter: (any ImageFeed.WebViewPresenterProtocol)?
    
    var loadRequestDidCall: Bool = false
    
    func load(request: URLRequest) {
        loadRequestDidCall = true
    }
    
    func setProgressValue(_ newValue: Float) {}
    func setProgressHidden(_ isHidden: Bool) {}
}
