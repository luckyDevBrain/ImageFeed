//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Kirill on 18.07.2024.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    // MARK: - Properties
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListCell = ImagesListCell()
    private let imagesListService = ImagesListService.shared
    private var imageListServiceObserver: NSObjectProtocol?
    private var photos: [Photo] = []
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    // MARK: - Outlets
    
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        if photos.count == 0 {
            loadImages()
        }
        
        imagesListServiceObserverAdd()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("[ImagesListViewController: prepare]: Invalid segue destination")
                return
            }
            guard let largeImageURL = URL(string: photos[indexPath.row].largeImageURL) else { return }
            viewController.largeImageURL = largeImageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Private Methods
    
    private func loadImages() {
        imagesListService.fetchPhotosNextPage(completion: { [weak self] error in
            if let error {
                print(error.localizedDescription)
            } else {
                self?.tableView.reloadData()
                print("[ImagesListViewController: loadImages]: Перезагрузка экрана")
            }
        })
    }
    
    private func imagesListServiceObserverAdd() {
        imageListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            
            self.updateTableViewAnimated()
        }
    }
    
    private func updateTableViewAnimated() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let oldCount = self.photos.count
            let newCount = self.imagesListService.photos.count
            if oldCount != newCount {
                self.photos = self.imagesListService.photos
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                self.tableView.performBatchUpdates {
                    self.tableView.insertRows(at: indexPaths, with: .automatic)
                } completion: { _ in }
            }
        }
    }
}

// MARK: - Extension

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
            guard let photo = photos[safeIndex: indexPath.row] else { return }
            
            let imageURLString = photo.thumbImageURL
            
            cell.cellImage.kf.indicatorType = .activity
            cell.cellImage.kf.setImage(
                with: URL(string: imageURLString),
                placeholder: UIImage(named: "stub"),
                options: [.transition(.fade(1))]) { [weak self] result in
                    guard let self else { return }
                    
                    switch result {
                    case .success(let value):
                        cell.configure(image: value.image, text: dateFormatter.string(from: Date()), isLiked: photo.isLiked)
                        
                    case .failure(let error):
                        guard let placeholder = UIImage(named: "Stub") else {return}
                        cell.configure(
                            image: placeholder,
                            text: dateFormatter.string(from: Date()),
                            isLiked: photo.isLiked
                        )
                    }
                    
                }
        }
    }

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return photos.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell {
                cell.delegate = self
                
                configCell(for: cell, with: indexPath)
                return cell
            } else {
                return UITableViewCell()
            }
        }
    }

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            let imagesCount = photos.count
            
            if indexPath.row == (imagesCount - 1) {
                loadImages()
            }
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            let photo = photos[indexPath.row]
            
            let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
            let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
            let imageWidth = photo.size.width
            let scale = imageViewWidth / imageWidth
            let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
            return cellHeight
        }
    }

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.photos = self.imagesListService.photos
                    cell.setIsLiked(self.photos[indexPath.row].isLiked)
                    print("изменение лайка в imageListViewController")
                }
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                print("DEBUG",
                      "[\(String(describing: self)).\(#function)]:",
                      error.localizedDescription,
                      separator: "\n")
                // добавить алерт
            }
        }
    }
}
