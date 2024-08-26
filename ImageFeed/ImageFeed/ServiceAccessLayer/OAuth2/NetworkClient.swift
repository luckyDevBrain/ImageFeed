//
//  NetworkClient.swift
//  ImageFeed
//
//  Created by Kirill on 25.08.2024.
//

import Foundation

protocol NetworkRouting {
    func fetch(request: URLRequest, handler: @escaping (Result<Data, Error>) -> Void)
}

struct NetworkClient: NetworkRouting {
    
    private enum NetworkError: Error {
        case codeError
    }
    
    func fetch(request: URLRequest, handler: @escaping (Result<Data, Error>) -> Void) {
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error in network request: \(error.localizedDescription)")
                handler(.failure(error))
                return
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                print("HTTP error with status code: \(response.statusCode)")
                handler(.failure(NetworkError.codeError))
                return
            }
            
            guard let data = data else {
                print("No data received from the server")
                return
            }
            handler(.success(data))
        }
        
        task.resume()
    }
}
