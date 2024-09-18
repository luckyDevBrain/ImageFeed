//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Kirill on 14.08.2024.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            guard let response = response as? HTTPURLResponse else {
                print("Error: No valid response received.")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
                return
            }
            
            if let data = data, 200 ..< 300 ~= response.statusCode {
                fulfillCompletionOnTheMainThread(.success(data))
            } else if let error = error {
                print("Error: \(error.localizedDescription)")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                print("Error: \(NetworkError.httpStatusCode(response.statusCode))")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(response.statusCode)))
            }
        })
        return task
    }
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedObject = try decoder.decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    print("Decoding error: \(error.localizedDescription), Data: \(String(data: data, encoding: .utf8) ?? "nil")")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("Data fetching failed with error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}
