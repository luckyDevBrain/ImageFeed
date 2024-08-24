//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Kirill on 14.08.2024.
//

import UIKit

final class OAuth2Service {
    static let shared = OAuth2Service(networkClient: NetworkClient())
    
    private var networkClient: NetworkClient
    private let tokenStorage = OAuth2TokenStorage()
    
    private enum JSONError: Error {
        case decodingError
    }
    
    private init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    private(set) var authToken: String? {
        get{
            return tokenStorage.token
        }
        set{
            tokenStorage.token = newValue
        }
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        let baseURL = URL(string: "https://unsplash.com")
        guard let url = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            relativeTo: baseURL
        ) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("Failed to create URL request.")
            return
        }
        
        networkClient.data(for: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    do {
                        let response = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                        completion(.success(response.accessToken))
                        print("accessToken: \(response.accessToken) have been decoded")
                    } catch {
                        completion(.failure(JSONError.decodingError))
                        print("JSON decoding error: \(error.localizedDescription)")
                    }
                case .failure(let error):
                    completion(.failure(error))
                    print(error.localizedDescription)
                }
            }
        }
    }
}
