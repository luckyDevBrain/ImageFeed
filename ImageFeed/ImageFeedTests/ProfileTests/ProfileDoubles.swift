//
//  ProfileDoubles.swift
//  ImageFeed
//
//  Created by Kirill on 29.09.2024.
//

import UIKit
@testable import ImageFeed

final class ProfileViewControllerDummy: ProfileViewInput {
    
    var presenter: (any ImageFeed.ProfileViewOutput)?
    
    var updateAvatarCalled: Bool = false
    
    func updateAvatar(_ avatarURL: URL?) {
        updateAvatarCalled = true
    }
}

final class ProfilePresenterSpy: ProfileViewOutput {
    
    var view: (any ImageFeed.ProfileViewInput)?
    
    var profile: ImageFeed.Profile? = nil
    
    var viewDidLoadCalled: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func logOut() {}
}
