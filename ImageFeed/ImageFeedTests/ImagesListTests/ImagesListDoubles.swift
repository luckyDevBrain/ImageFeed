//
//  ImagesListDoubles.swift
//  ImageFeed
//
//  Created by Kirill on 29.09.2024.
//

import UIKit
@testable import ImageFeed

final class ImagesListServiceStubs: ImagesListServiceProtocol {
    
    var photos: [ImageFeed.Photo] = []
    var fetchCalled: Bool = false
    
    func fetchPhotosNextPage(completion: @escaping ((any Error)?) -> Void) {
        fetchCalled = true
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, any Error>) -> Void) {}
}

final class ImagesListViewControllerDummy: ImagesListInput {
    var presenter: (any ImageFeed.ImagesListOutput)!
    
    func reloadData() {}
    func checkTableViewForUpdates(at indexPaths: [IndexPath]) {}
}

final class ImagesListPresenterSpy: ImagesListOutput {
    
    var view: (any ImageFeed.ImagesListInput)!
    
    var viewDidLoadCalled: Bool = false
    var photos: [ImageFeed.Photo] = []
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func loadImages() {}
    func largeImageURL(at row: Int) -> URL? { nil }
    func toggleLike(at index: Int, success: @escaping (Bool) -> Void, completion: @escaping () -> Void) {}
}
