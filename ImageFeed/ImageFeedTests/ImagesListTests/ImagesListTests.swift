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
        //given
        let presenter = ImagesListPresenterSpy()
        let viewController = ImagesListViewController(presenter: presenter)
        presenter.view = viewController

        //when
        _ = viewController.view

        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testViewControllerCallsViewDidDisappear() {
        //given
        let presenter = ImagesListPresenterSpy()
        let viewController = ImagesListViewController(presenter: presenter)
        presenter.view = viewController

        //when
        viewController.viewDidDisappear(true)

        //then
        XCTAssertTrue(presenter.viewDidDisappearCalled)
    }

    func testImagesListCellDidTapLike() {
        //given
        let presenter = ImagesListPresenterSpy()
        let viewController = ImagesListViewController(presenter: presenter)
        presenter.view = viewController
        let cell = ImagesListCell()
        let isLiked = presenter.isLiked

        //when
        presenter.imagesListDidTapLike(cell)

        //then
        XCTAssertNotEqual(isLiked, presenter.isLiked)
    }

    func testUpdateTableView() {
        //given
        let presenter = ImagesListPresenter(alertPresenter: AlertPresenter())
        let viewController = ImagesListViewController(presenter: presenter)
        presenter.view = viewController
        let imagesListService = ImagesListService.shared

        //when
        presenter.updateTableView()

        //then
        XCTAssertEqual(viewController.photos.count, imagesListService.photos.count)
    }
}


final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    var viewDidDisappearCalled: Bool = false
    var isLiked: Bool = false
    let imagesListService = ImagesListService.shared
    let storage = OAuth2Storage.shared

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func viewDidDisappear() {
        viewDidDisappearCalled = true
    }

    func imagesListDidTapLike(_ cell: ImagesListCell) {
        isLiked = true
    }

    func tableViewWillDisplay(indexPath: IndexPath) {

    }

    func updateTableView() {

    }
}
