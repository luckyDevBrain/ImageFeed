//
//  ProfilePresenterSpy.swift
//  ImageFeed
//
//  Created by Kirill on 29.09.2024.
//

import UIKit
@testable import ImageFeed

final class ProfilePresenterSpy: ProfileViewControllerProtocol {
    var view: ProfileViewControllerProtocol?
    var isLogoutButtonTapped: Bool = false
    var isViewDidLoadCalled: Bool = false
    
    func viewDidLoad() {
        isViewDidLoadCalled = true
    }
    
    func didTapLogout() {
        isLogoutButtonTapped = true
    }
    
    func getProfile() -> Profile? {
        return nil
    }
    
    func getAvatarUrl() -> URL? {
        return nil
    }
}
