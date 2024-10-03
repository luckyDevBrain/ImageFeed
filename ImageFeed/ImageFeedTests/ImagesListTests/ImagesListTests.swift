//
//  ImagesListTests.swift
//  ImageFeed
//
//  Created by Kirill on 27.09.2024.
//


import XCTest
@testable import ImageFeed

final class ImagesListTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        
        let presenter = ImagesListPresenterSpy()
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier:"ImagesListViewController")
        if let view = imagesListViewController as? ImagesListInput {
            view.presenter = presenter
        }
        
        _ = imagesListViewController.view
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterFetchsPhotos() {
        
        let imagesListService = ImagesListServiceStubs()
        let presenter = ImagesListPresenter(view: ImagesListViewControllerDummy())
        presenter.imagesListService = imagesListService
        
        presenter.viewDidLoad()
        
        XCTAssertTrue(imagesListService.fetchCalled)
    }
}
