//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Kirill on 24.09.2024.
//

import Foundation

private enum PhotosResponseError: Error {
    case defaultError
}

struct UrlsResult: Codable {
    let full: String
    let thumb: String
}

struct PhotoResult: Codable {
    let id: String
    let createdAt: String
    let width: Int
    let height: Int
    let likedByUser: Bool
    let description: String?
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case likedByUser = "liked_by_user"
        case description
        case urls
    }
}

class ImagesListService {
    static let shared = ImagesListService()
    private init() {}
    
    private(set) var photos: [Photo] = []
    private let urlSession = URLSession.shared
    private let tokenStorage = OAuth2TokenStorage()
    private var changeLikeTask: URLSessionTask?
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private var isFetching = false
    private var currentPage = 0
    
    // MARK: - Network request for photos
    
    func fetchPhotosNextPage(completion: @escaping (Error?) -> Void) {
        guard !isFetching else { return }
        
        isFetching = true
        currentPage += 1
        
        let completionOnMainTheard:(Error?) -> Void = { error in
            DispatchQueue.main.async {
                completion(error)
                self.isFetching = false
            }
        }
        
        guard let token = tokenStorage.token else { return }
        
        guard let request = makeFetchPhotosRequest(nextPage: currentPage, token: token) else {
            isFetching = false
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let photoResult):
                    self?.processServerResponse(photoResult: photoResult)
                    completionOnMainTheard(nil)
                case .failure:
                    self?.currentPage -= 1
                    completionOnMainTheard(PhotosResponseError.defaultError)
                }
            }
        }
        task.resume()
    }
    
    private func makeFetchPhotosRequest(nextPage: Int, token: String) -> URLRequest? {
        guard let url = URL(string: Constants.defaultPhotos + "?page=\(nextPage)"),
              let token = tokenStorage.token else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func processServerResponse(photoResult: [PhotoResult]) {
        let newPhotos = photoResult.map { Photo(from: $0) }
        photos.append(contentsOf: newPhotos)
        NotificationCenter.default.post(name: Self.didChangeNotification, object: self)
    }
    
    // MARK: - Network request for likes
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if changeLikeTask != nil {
            print("DEBUG",
                  "[\(String(describing: self)).\(#function)]:",
                  "Change like task is already in progress!",
                  separator: "\n")
            changeLikeTask?.cancel()
        }
        
        guard let token = tokenStorage.token else { return }
        
        guard let request = makeFetchLikeRequest(isLiked: isLike, photoID: photoId, token: token) else { return }
        
        let task = urlSession.dataTask(with: request) { [weak self] (data, response, error) in
            
            guard let self else { return }
            
            if let error = error {
                self.changeLikeTask = nil
                completion(.failure(error))
                print("DEBUG",
                      "[\(String(describing: self)).\(#function)]:",
                      "Error while changing like:",
                      error.localizedDescription,
                      separator: "\n")
                return
            }
            
            if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                let photo = self.photos[index]
                let newPhoto = Photo(photo: photo, isLiked: !photo.isLiked)
                DispatchQueue.main.async {
                    self.photos = self.photos.withReplaced(itemAt: index, newValue: newPhoto)
                    print("фото заменено")
                }
                
                completion(.success(Void()))
                self.changeLikeTask = nil
            }
        }
        changeLikeTask = task
        task.resume()
    }
    
    private func makeFetchLikeRequest(isLiked: Bool, photoID: String, token: String) -> URLRequest? {
        guard let url = URL(string: Constants.defaultPhotos + "\(photoID)/like"),
              let token = tokenStorage.token else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLiked ? "POST" : "DELETE"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func cleanImagesList() {
        photos.removeAll()
    }
}

// MARK: - Extension

extension Array {
    
    public subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }
        
        return self[index]
    }
    
    func withReplaced(itemAt index: Int, newValue: Element) -> [Element] {
        var array = self
        array[index] = newValue
        return array
    }
}
