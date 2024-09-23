//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Kirill on 14.08.2024.
//

import UIKit

final class OAuth2Service {
    
    // MARK: - Enum + Struct
    
    private enum JSONError: Error {
        case decodingError
    }
    
    private enum AuthServiceError: Error {
        case invalidRequest
    }
    
    struct OAuthTokenResponseBody: Decodable {
        let accessToken: String
        let tokenType: String
        
        private enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case tokenType = "token_type"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            accessToken = try container.decode(String.self, forKey: .accessToken)
            tokenType = try container.decode(String.self, forKey: .tokenType)
        }
    }
    
    // MARK: - Singleton
    
    static let shared = OAuth2Service()
    
    // MARK: - Properties
    
    private let tokenStorage = OAuth2TokenStorage()
    let urlSession = URLSession.shared
    private var lastCode: String?
    private var task: URLSessionTask?
    
    private init() {}
    
    private(set) var authToken: String? {
        get {
            return tokenStorage.token
        }
        set {
            tokenStorage.token = newValue
        }
    }
    
    // MARK: - Public Methods
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
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
        request.httpMethod = HTTPMethods.post
        return request
    }
    
    func fetchOAuthToken(_ code: String, handler: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            handler(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            handler(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(let tokenResponse):
                    self.tokenStorage.token = tokenResponse.accessToken
                    handler(.success(tokenResponse.accessToken))
                case .failure(let error):
                    if let networkError = error as? NetworkError {
                        switch networkError {
                        case .httpStatusCode(let statusCode):
                            print("HTTP status code error: \(statusCode)")
                        case .urlRequestError(let requestError):
                            print("URL request error: \(requestError)")
                        case .urlSessionError:
                            print("URL session error: \(error)")
                        }
                    } else {
                        print("Other network error: \(error)")
                    }
                    handler(.failure(error))
                }
                self.task = nil
                self.lastCode = nil
            }
        }
        self.task = task
        task.resume()
        self.lastCode = nil
    }
}
