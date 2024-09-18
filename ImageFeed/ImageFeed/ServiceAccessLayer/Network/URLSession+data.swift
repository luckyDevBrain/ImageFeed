//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Kirill on 14.08.2024.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    
    var errorDescription: String? {
        switch self {
        case .httpStatusCode(let code):
            return "HTTP Status Code Error - code \(code)"
        case .urlRequestError(let error):
            return "Request Error - \(error.localizedDescription)"
        case .urlSessionError:
            return "URL Session Error"
        }
    }
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async{
                completion(result)
            }
        }
        let task = dataTask(with: request) { data, response, error in
            guard let error else {
                guard let data,
                      let response,
                      let statusCode = (response as? HTTPURLResponse)?.statusCode
                else {
                    print(NetworkError.urlSessionError.localizedDescription)
                    return fulfillCompletionOnMainThread(
                        .failure(NetworkError.urlSessionError))
                }
                guard 200..<300 ~= statusCode
                else {
                    print(NetworkError.httpStatusCode(statusCode).localizedDescription)
                    print(String(data: data, encoding: .utf8) as Any)
                    return fulfillCompletionOnMainThread(
                        .failure(NetworkError.httpStatusCode(statusCode)))
                }
                return fulfillCompletionOnMainThread(.success(data))
            }
            print(NetworkError.urlRequestError(error).localizedDescription)
            fulfillCompletionOnMainThread(.failure(NetworkError.urlRequestError(error)))
        }
        return task
    }
    
    func objectTask<T: Decodable>(
            for request: URLRequest,
            completion: @escaping (Result<T, Error>) -> Void
        ) -> URLSessionTask {
            let task = data(for: request) { (result: Result<Data, Error>) in
                switch result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let resultValue = try decoder.decode(T.self, from: data)
                        completion(.success(resultValue))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            return task
        }
}
