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
    
    private init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    private(set) var authToken: String? {
        get { tokenStorage.token }
        set { tokenStorage.token = newValue }
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
            print("Failed to create URL from components.")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            DispatchQueue.main.async {
                let error = NSError(domain: "OAuth2Service", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create URL request."])
                print("Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
            return
        }
        
        networkClient.data(for: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    do {
                        
                        if let jsonString = String(data: data, encoding: .utf8) {
                            print("JSON Response: \(jsonString)")
                        }
                        
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                        self.authToken = response.accessToken
                        completion(.success(response.accessToken))
                    } catch {
                        print("JSON decoding error: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                case .failure(let error):
                    print("Network error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
    }
}
