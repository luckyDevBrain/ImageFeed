//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Kirill on 14.08.2024.
//

import Foundation
import WebKit

enum AuthServiceError: Error {
    case invalidRequest
}

struct OAuthTokenResponseBody: Codable {
    var accessToken: String
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    func fetchOAuthToken(code: String, completion: @escaping (_ result: Result<String, Error>) -> Void) {
        guard let tokenRequest = makeOAuthTokenRequest(code: code)
        else {
            print("Error: Unable to create token request.")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        assert(Thread.isMainThread)
        if task != nil {
            if lastCode != code {
                task?.cancel()
            } else {
                print("Error: Request with the same code already exists.")
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        } else {
            if lastCode == code {
                print("Error: Request with the same code already exists.")
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        }
        lastCode = code
        
        let task = URLSession.shared.data(for: tokenRequest) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                        
                        self.task = nil
                        self.lastCode = nil
                        
                        print("Success token: \(response.accessToken)")
                        completion(.success(response.accessToken))
                    } catch {
                        print("Error decoding token: \(completion(.failure(error)))")
                        completion(.failure(error))
                    }
                case .failure(let error):
                    print("Error: \(completion(.failure(error)))")
                    completion(.failure(error))
                }
            }
        }
        self.task = task
        task.resume()
    }
}

private func makeOAuthTokenRequest(code: String) -> URLRequest? {
    guard let baseURL = URL(string: "https://unsplash.com")
    else {
        print("Failed to create baseURL for OAuth request")
        return nil
    }
    guard let url = URL(
        string: "/oauth/token"
        + "?client_id=\(Constants.accessKey)"
        + "&&client_secret=\(Constants.secretKey)"
        + "&&redirect_uri=\(Constants.redirectURI)"
        + "&&code=\(code)"
        + "&&grant_type=authorization_code",
        relativeTo: baseURL
    ) else {
        print("Failed to construct URL for OAuth token request with baseURL: \(String(describing: baseURL)) and code: \(code)")
        preconditionFailure("Unable to construct url")
    }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    print("Token request: \(request)")
    return request
}
