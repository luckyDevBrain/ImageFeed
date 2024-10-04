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
    
    var presenter: ImagesListOutput!
    
    private let imagesListCell = ImagesListCell()
    
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
        
        presenter?.viewDidLoad()
    }
    
    // MARK: - Navigation
    
    private func openSingleImageViewController(for indexPath: IndexPath) {
        
        let singleImageViewController = SingleImageViewController()
        
        //Проверяем корректность URL для картинки
        guard let largeImageURL = presenter?.largeImageURL(at: indexPath.row) else {
            //Если URL некорректен, показываем алерт с ошибкой
            let alertModel = AlertModel(
                title: "Ошибка",
                message: "Не удалось загрузить изображение. Пожалуйста, попробуйте позже.",
                buttons: [.okButton],
                identifier: "imageLoadError"
            ) {
                //Можно добавить логику по необходимости (перезагрузка страницы или др.)
            }
            AlertPresenter.showAlert(on: self, model: alertModel)
            return
        }
        
        singleImageViewController.largeImageURL = largeImageURL
        singleImageViewController.modalPresentationStyle = .fullScreen
        present(singleImageViewController, animated: true)
    }
}

// MARK: - Extension

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let presenter, let photo = presenter.photos[safeIndex: indexPath.row]
        else { return }
        
        let dateCreated = photo.createdAt ?? Date()
        let dateCreatedString = dateFormatter.string(from: dateCreated)
        cell.setText(dateCreatedString)
        
        cell.setIsLiked(photo.isLiked)  // Установка состояния лайка
        
        cell.cellImage.kf.indicatorType = .activity
        
        cell.cellImage.kf.setImage(
            with: URL(string: photo.thumbImageURL),
            placeholder: UIImage(named: "stub"),
            options: [.transition(.fade(1))]) { result in
                switch result {
                case .success(let value):
                    cell.setImage(value.image)
                case .failure(_):
                    guard let placeholder = UIImage(named: "stub") else {return}
                    cell.setImage(placeholder)
                }
            }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.photos.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell {
            
            cell.delegate = self
            cell.selectionStyle = .none // Отключаем выделение ячейки при нажатии
            configCell(for: cell, with: indexPath)
            return cell
        } else {
            return UITableViewCell()
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let imagesCount = presenter?.photos.count else { return }
        
        if indexPath.row == (imagesCount - 1) {
            presenter?.loadImages()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openSingleImageViewController(for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let photo = presenter?.photos[indexPath.row] else { return 0 }
        
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
        
        UIBlockingProgressHUD.show()
        
        presenter?.toggleLike(at: indexPath.row, success: { isLiked in
            cell.setIsLiked(isLiked)
        }, completion: {
            UIBlockingProgressHUD.dismiss()
        })
    }
}

extension ImagesListViewController: ImagesListInput {
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func checkTableViewForUpdates(at indexPaths: [IndexPath]) {
        tableView.performBatchUpdates {
            self.tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in }
    }
}
