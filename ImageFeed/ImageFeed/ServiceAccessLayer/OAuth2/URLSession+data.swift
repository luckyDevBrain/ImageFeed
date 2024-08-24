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
        
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                switch statusCode {
                    case 200...299:
                        print("Received success HTTP status code: \(statusCode)")
                        fulfillCompletionOnTheMainThread(.success(data))
                    case 400:
                        print("Bad request \(statusCode)")
                        fulfillCompletionOnTheMainThread(.failure(NetworkError.badRequest))
                    case 401:
                        print("Unauthorized \(statusCode) - Invalid Access Token")
                        fulfillCompletionOnTheMainThread(.failure(NetworkError.unauthorized))
                    case 403:
                        print("Forbidden \(statusCode)")
                        fulfillCompletionOnTheMainThread(.failure(NetworkError.forbidden))
                    case 404:
                        print("Not Found \(statusCode)")
                        fulfillCompletionOnTheMainThread(.failure(NetworkError.notFound))
                        
                    case 500, 503:
                        print("Internal Server Error \(statusCode)")
                        fulfillCompletionOnTheMainThread(.failure(NetworkError.serverError))
                    default:
                        print("HTTP status code: \(statusCode)")
                        fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                    }
            } else if let error = error {
                print(error.localizedDescription)
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                print("Unknown error")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        }
        self.task = task
        task.resume()
    }
}
