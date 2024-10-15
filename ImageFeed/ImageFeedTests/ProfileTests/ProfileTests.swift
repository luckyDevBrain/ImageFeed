//
//  ProfileTests.swift
//  ImageFeed
//
//  Created by Kirill on 27.09.2024.
//

import XCTest
@testable import ImageFeed

final class ProfileTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        
        let profileViewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        presenter.view = profileViewController
        
        profileViewController.presenter = presenter
        
        _ = profileViewController.view
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterUpdatesAvatar() {
        
        let profileViewController = ProfileViewControllerDummy()
        let presenter = ProfileViewPresenter(view: profileViewController)
        
        profileViewController.presenter = presenter
        
        presenter.viewDidLoad()
        
        XCTAssertTrue(profileViewController.updateAvatarCalled)
    }
}
