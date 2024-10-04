//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Kirill on 30.09.2024.
//

import Foundation

protocol ImagesListInput: AnyObject {
    var presenter: ImagesListOutput! { get set }
    func reloadData()
    func checkTableViewForUpdates(at indexPaths: [IndexPath])
}

protocol ImagesListOutput: AnyObject {
    var view: ImagesListInput! { get set }
    var photos: [Photo] { get set }
    
    func viewDidLoad()
    func loadImages()
    func largeImageURL(at row: Int) -> URL?
    func toggleLike(at index: Int, success: @escaping (Bool) -> Void, completion: @escaping () -> Void)
}

class ImagesListPresenter {
    
    // MARK: - Properties
    
    var imagesListService: ImagesListServiceProtocol = ImagesListService.shared
    private var imageListServiceObserver: NSObjectProtocol?
    
    weak var view: ImagesListInput!
    
    var photos: [Photo] = []
    
    init(view: ImagesListInput?) {
        self.view = view
    }
}

extension ImagesListPresenter: ImagesListOutput {
    
    // MARK: - Methods
    
    func viewDidLoad() {
        
        if photos.isEmpty {
            loadImages()
        }
        
        addServiceObserver { [weak self] in
            guard let self else { return }
            self.checkTableViewForUpdates()
        }
    }
    
    func largeImageURL(at index: Int) -> URL? {
        URL(string: photos[index].largeImageURL)
    }
    
    func loadImages() {
        imagesListService.fetchPhotosNextPage(completion: { [weak self] error in
            if let error {
                print(error.localizedDescription)
            } else {
                guard let self else { return }
                self.view?.reloadData()
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
    
    func checkTableViewForUpdates() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            let oldCount = self.photos.count
            let newCount = self.imagesListService.photos.count
            
            if oldCount != newCount {
                
                self.photos = self.imagesListService.photos
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                
                self.view?.checkTableViewForUpdates(at: indexPaths)
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
