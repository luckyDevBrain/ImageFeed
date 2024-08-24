//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Kirill on 14.08.2024.
//

import Foundation

struct NetworkClient {
    private enum NetworkError: Error {
        case httpStatusCode(Int)
        case urlRequestError(Error)
        case urlSessionError
        case badRequest
        case unauthorized
        case forbidden
        case notFound
        case serverError
    }
    
    var task: URLSessionTask?
    
    mutating func data(for request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    print("URL request error: \(error.localizedDescription)")
                    completion(.failure(NetworkError.urlRequestError(error)))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    print("Failed to cast response to HTTPURLResponse")
                    completion(.failure(NetworkError.urlSessionError))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    print("No data received from the request")
                    completion(.failure(NetworkError.urlSessionError))
                }
                return
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                DispatchQueue.main.async {
                    completion(.success(data))
                }
            case 400:
                DispatchQueue.main.async {
                    print("Bad request: HTTP status code 400")
                    completion(.failure(NetworkError.badRequest))
                }
            case 401:
                DispatchQueue.main.async {
                    print("Unauthorized: HTTP status code 401")
                    completion(.failure(NetworkError.unauthorized))
                }
            case 403:
                DispatchQueue.main.async {
                    print("Forbidden: HTTP status code 403")
                    completion(.failure(NetworkError.forbidden))
                }
            case 404:
                DispatchQueue.main.async {
                    print("Not Found: HTTP status code 404")
                    completion(.failure(NetworkError.notFound))
                }
            case 500, 503:
                DispatchQueue.main.async {
                    print("Server error: HTTP status code \(httpResponse.statusCode)")
                    completion(.failure(NetworkError.serverError))
                }
            default:
                DispatchQueue.main.async {
                    print("Unexpected HTTP status code: \(httpResponse.statusCode)")
                    completion(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)))
                }
            }
        }
        
        self.task = task
        task.resume()
    }
}
