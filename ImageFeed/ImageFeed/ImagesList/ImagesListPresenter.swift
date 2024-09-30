//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Kirill on 30.09.2024.
//

import Foundation

protocol ImagesListInput: AnyObject {
    var presenter: ImagesListOutput? { get set }
}

protocol ImagesListOutput: AnyObject {
    var view: ImagesListInput? { get set }
    var hasPhotos: Bool { get }
    var photos: [Photo] { get set }
    
    func largeImageURL(at row: Int) -> URL?
    func loadImages(completion: @escaping () -> Void)
    func addServiceObserver(block: @escaping () -> Void)
    func checkTableViewForUpdates(completion: @escaping ([IndexPath]) -> Void)
    func toggleLike(at index: Int, success: @escaping (Bool) -> Void, completion: @escaping () -> Void)
}

class ImagesListPresenter {
    
    // MARK: - Properties
    
    private let imagesListService = ImagesListService.shared
    private var imageListServiceObserver: NSObjectProtocol?
    
    weak var view: ImagesListInput?
    
    var photos: [Photo] = []
    
    init(view: ImagesListInput?) {
        self.view = view
    }
}

extension ImagesListPresenter: ImagesListOutput {
    
    var hasPhotos: Bool {
        !photos.isEmpty
    }
    
    // MARK: - Methods
    
    func largeImageURL(at index: Int) -> URL? {
        URL(string: photos[index].largeImageURL)
    }
    
    func loadImages(completion: @escaping () -> Void) {
        imagesListService.fetchPhotosNextPage(completion: { error in
            if let error {
                print(error.localizedDescription)
            } else {
                completion()
                print("[ImagesListViewController: loadImages]: Перезагрузка экрана")
            }
        })
    }
    
    func addServiceObserver(block: @escaping () -> Void) {
        imageListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            block()
        }
    }
    
    func checkTableViewForUpdates(completion: @escaping ([IndexPath]) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            let oldCount = self.photos.count
            let newCount = self.imagesListService.photos.count
            
            if oldCount != newCount {
                
                self.photos = self.imagesListService.photos
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                
                completion(indexPaths)
            }
        }
    }
    
    func toggleLike(at index: Int, success: @escaping (Bool) -> Void, completion: @escaping () -> Void) {
        
        let photo = photos[index]
        
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.photos = self.imagesListService.photos
                    success(self.photos[index].isLiked)
                    print("изменение лайка в imageListViewController")
                }
            case .failure(let error):
                print("DEBUG",
                      "[\(String(describing: self)).\(#function)]:",
                      error.localizedDescription,
                      separator: "\n")
                // добавить алерт (во вью)
            }
            
            completion()
        }
    }
}
