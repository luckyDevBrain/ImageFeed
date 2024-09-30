//
//  WebViewControllerSpy.swift
//  ImageFeed
//
//  Created by Kirill on 29.09.2024.
//

import ImageFeed
import Foundation

final class WebViewControllerSpy: WebViewControllerProtocol {
    var presenter: WebViewPresenterProtocol?
    var loadCalled: Bool = false
    
    func load(request: URLRequest) {
        loadCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {
        
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        
    }
}
