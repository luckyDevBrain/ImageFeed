//
//  ImagesListPresenterSpy.swift
//  ImageFeed
//
//  Created by Kirill on 29.09.2024.
//

@testable import ImageFeed
import UIKit

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var imagesListService = ImagesListService.shared
    
    var view: ImagesListViewControllerProtocol?
    
    var photos: [Photo] = []
    
    var isViewDidLoadCalled: Bool = false
    
    func viewDidLoad() {
        isViewDidLoadCalled = true
    }
    
    func getCellHeight(indexPath: IndexPath, tableView: UITableView) -> CGFloat {
        return 0
    }
    
    func didTapLike(_ cell: ImageFeed.ImagesListCell, tableView: UITableView) {

    }
    
    func didUpdatePhotos() {
        
    }
    
    
}
