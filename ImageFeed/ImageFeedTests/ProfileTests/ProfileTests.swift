//
//  ProfileTests.swift
//  ImageFeed
//
//  Created by Kirill on 27.09.2024.
//

import XCTest
@testable import ImageFeed

final class ProfileTests: XCTestCase {
    
    func testViewControllerDidTapLogOut() {
        // Given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenterSpy()
        
        viewController.presenter = presenter
        presenter.view = viewController
        
        // When
        presenter.didTapLogout()
        
        // Then
        XCTAssertTrue(presenter.isLogoutButtonTapped)
    }
    
    func testViewControllerCallsViewDidLoad() {
        // Given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenterSpy()
        
        viewController.presenter = presenter
        presenter.view = viewController
        
        // When
        presenter.viewDidLoad()
        
        // Then
        XCTAssertTrue(presenter.isViewDidLoadCalled)
    }
}
